const { app, BrowserWindow, Tray, Menu, ipcMain, nativeImage } = require('electron');

const path = require('path');
const crypto = require('crypto');
const { WebSocketServer } = require('ws');
const pty = require('node-pty');
const Store = require('electron-store');
const QRCode = require('qrcode');
const { spawn, execFile } = require('child_process');
const fs = require('fs');
const os = require('os');

const store = new Store({
  defaults: {
    port: 9876,
    authToken: null,
  }
});

const sessions = new Map();
const clients = new Set();
const logs = [];

let tray = null;
let dashboardWindow = null;
let wss = null;
let httpServer = null;
let tunnelProcess = null;
let tunnelUrl = null;
let previewPort = null; // When set, HTTP requests are proxied to localhost:previewPort

function log(message) {
  const entry = { time: new Date().toISOString(), message };
  logs.push(entry);
  if (logs.length > 200) logs.shift();
  console.log(`[OpenRemote] ${message}`);
  if (dashboardWindow && !dashboardWindow.isDestroyed()) {
    dashboardWindow.webContents.send('log', entry);
  }
}

function ensureAuthToken() {
  let token = store.get('authToken');
  if (!token) {
    token = crypto.randomBytes(16).toString('hex');
    store.set('authToken', token);
    log('Generated new pairing token');
  }
  return token;
}

// ─── Cloudflare Tunnel ──────────────────────────────────────────────────────

function getCloudflaredDir() {
  return path.join(app.getPath('userData'), 'cloudflared');
}

function getCloudflaredPath() {
  const dir = getCloudflaredDir();
  if (process.platform === 'win32') return path.join(dir, 'cloudflared.exe');
  return path.join(dir, 'cloudflared');
}

async function ensureCloudflared() {
  const binPath = getCloudflaredPath();

  if (fs.existsSync(binPath)) {
    log('cloudflared binary found');
    return binPath;
  }

  log('Downloading cloudflared...');
  const dir = getCloudflaredDir();
  fs.mkdirSync(dir, { recursive: true });

  const platform = process.platform;
  const arch = process.arch;
  let url;

  if (platform === 'darwin') {
    url = arch === 'arm64'
      ? 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-darwin-arm64.tgz'
      : 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-darwin-amd64.tgz';
  } else if (platform === 'win32') {
    url = 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe';
  } else {
    url = arch === 'arm64'
      ? 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64'
      : 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64';
  }

  const tmpPath = binPath + '.tmp';
  await downloadFile(url, tmpPath);

  if (platform === 'darwin') {
    await extractTgz(tmpPath, dir);
    fs.unlinkSync(tmpPath);
  } else {
    fs.renameSync(tmpPath, binPath);
  }

  if (platform !== 'win32') {
    fs.chmodSync(binPath, 0o755);
  }

  log('cloudflared downloaded successfully');
  return binPath;
}

function downloadFile(url, dest) {
  return new Promise((resolve, reject) => {
    function doRequest(requestUrl) {
      const proto = requestUrl.startsWith('https') ? require('https') : require('http');
      proto.get(requestUrl, (response) => {
        if (response.statusCode === 301 || response.statusCode === 302) {
          response.resume();
          doRequest(response.headers.location);
          return;
        }

        if (response.statusCode !== 200) {
          reject(new Error(`Download failed: HTTP ${response.statusCode}`));
          return;
        }

        const file = fs.createWriteStream(dest);
        response.pipe(file);
        file.on('finish', () => {
          file.close();
          resolve();
        });
        file.on('error', (err) => {
          fs.unlink(dest, () => {});
          reject(err);
        });
      }).on('error', (err) => {
        fs.unlink(dest, () => {});
        reject(err);
      });
    }

    doRequest(url);
  });
}

function extractTgz(tgzPath, destDir) {
  return new Promise((resolve, reject) => {
    const child = spawn('tar', ['xzf', tgzPath, '-C', destDir]);
    child.on('close', (code) => {
      if (code === 0) resolve();
      else reject(new Error(`tar exited with code ${code}`));
    });
    child.on('error', reject);
  });
}

async function startTunnel(port) {
  try {
    const binPath = await ensureCloudflared();
    log('Starting Cloudflare Tunnel...');

    tunnelProcess = spawn(binPath, ['tunnel', '--url', `http://localhost:${port}`], {
      stdio: ['ignore', 'pipe', 'pipe'],
    });

    // cloudflared prints the tunnel URL to stderr
    tunnelProcess.stderr.on('data', (data) => {
      const output = data.toString();
      const match = output.match(/https:\/\/[a-z0-9-]+\.trycloudflare\.com/);
      if (match && !tunnelUrl) {
        tunnelUrl = match[0];
        log(`Tunnel active: ${tunnelUrl}`);
        if (dashboardWindow && !dashboardWindow.isDestroyed()) {
          dashboardWindow.webContents.send('tunnel-url', tunnelUrl);
        }
      }
    });

    tunnelProcess.on('close', (code) => {
      log(`Cloudflare Tunnel exited (code ${code})`);
      tunnelUrl = null;
      tunnelProcess = null;
    });

    tunnelProcess.on('error', (err) => {
      log(`Tunnel error: ${err.message}`);
    });

  } catch (err) {
    log(`Failed to start tunnel: ${err.message}`);
  }
}


// ─── HTTP + WebSocket Server ────────────────────────────────────────────────

function startWebSocketServer(port) {
  const http = require('http');

  httpServer = http.createServer((req, res) => {
    // If preview port is set, proxy HTTP requests to the dev server
    if (previewPort) {
      const proxyReq = http.request(
        {
          hostname: '127.0.0.1',
          port: previewPort,
          path: req.url,
          method: req.method,
          headers: {
            ...req.headers,
            host: `localhost:${previewPort}`,
          },
        },
        (proxyRes) => {
          res.writeHead(proxyRes.statusCode, proxyRes.headers);
          proxyRes.pipe(res, { end: true });
        }
      );

      proxyReq.on('error', (err) => {
        log(`Preview proxy error: ${err.message}`);
        res.writeHead(502);
        res.end(`Preview server not reachable on port ${previewPort}`);
      });

      req.pipe(proxyReq, { end: true });
    } else {
      res.writeHead(200, { 'Content-Type': 'text/plain' });
      res.end('OpenRemote server running');
    }
  });

  wss = new WebSocketServer({ noServer: true });

  // Handle WebSocket upgrade requests
  httpServer.on('upgrade', (request, socket, head) => {
    wss.handleUpgrade(request, socket, head, (ws) => {
      wss.emit('connection', ws, request);
    });
  });

  httpServer.listen(port, () => {
    log(`HTTP + WebSocket server listening on port ${port}`);
  });

  wss.on('connection', (ws) => {
    let authenticated = false;
    let clientName = 'unknown';

    log('New connection — waiting for auth...');

    const authTimeout = setTimeout(() => {
      if (!authenticated) {
        ws.send(JSON.stringify({ type: 'error', message: 'Auth timeout' }));
        ws.close();
        log('Connection closed: auth timeout');
      }
    }, 5000);

    ws.on('message', (raw) => {
      let msg;
      try {
        msg = JSON.parse(raw.toString());
      } catch {
        ws.send(JSON.stringify({ type: 'error', message: 'Invalid JSON' }));
        return;
      }

      if (!authenticated) {
        if (msg.type === 'auth' && msg.token === store.get('authToken')) {
          authenticated = true;
          clearTimeout(authTimeout);
          clientName = msg.name || 'phone';
          clients.add(ws);
          ws.send(JSON.stringify({ type: 'auth_ok' }));
          log(`Client authenticated: ${clientName}`);
          ws.send(JSON.stringify({
            type: 'sessions',
            sessions: Array.from(sessions.keys()),
          }));
          // Send existing preview info if active
          if (previewPort && tunnelUrl) {
            ws.send(JSON.stringify({ type: 'preview_ready', url: tunnelUrl, port: previewPort }));
            log(`Sent preview URL to reconnected client: ${tunnelUrl} → localhost:${previewPort}`);
          }
          return;
        } else {
          ws.send(JSON.stringify({ type: 'error', message: 'Bad token' }));
          ws.close();
          clearTimeout(authTimeout);
          log('Connection rejected: bad token');
          return;
        }
      }

      handleClientMessage(ws, msg);
    });

    ws.on('close', () => {
      authenticated = false;
      clients.delete(ws);
      log(`Client disconnected: ${clientName}`);
    });

    ws.on('error', (err) => {
      log(`WebSocket error: ${err.message}`);
    });
  });
}

function handleClientMessage(ws, msg) {
  switch (msg.type) {
    case 'create_session': {
      const sessionId = crypto.randomBytes(4).toString('hex');
      const shell = process.platform === 'win32' ? 'powershell.exe' : process.env.SHELL || '/bin/bash';
      const cwd = msg.cwd || os.homedir();

      const term = pty.spawn(shell, [], {
        name: 'xterm-256color',
        cols: msg.cols || 80,
        rows: msg.rows || 24,
        cwd: cwd,
        env: process.env,
      });

      sessions.set(sessionId, { term, cwd });

      term.onData((data) => {
        if (ws.readyState === ws.OPEN) {
          ws.send(JSON.stringify({ type: 'output', sessionId, data }));
        }
        // Send to dashboard for live view
        if (dashboardWindow && !dashboardWindow.isDestroyed()) {
          dashboardWindow.webContents.send('terminal-output', { sessionId, data });
        }
      });

      term.onExit(({ exitCode }) => {
        sessions.delete(sessionId);
        ws.send(JSON.stringify({ type: 'session_ended', sessionId, exitCode }));
        log(`Session ${sessionId} exited (code ${exitCode})`);
        broadcastSessionList();
      });

      ws.send(JSON.stringify({ type: 'session_created', sessionId }));
      log(`Session created: ${sessionId} (shell: ${shell}, cwd: ${cwd})`);
      broadcastSessionList();
      break;
    }

    case 'input': {
      const session = sessions.get(msg.sessionId);
      if (session) {
        session.term.write(msg.data);
      } else {
        ws.send(JSON.stringify({ type: 'error', message: 'Session not found' }));
      }
      break;
    }

    case 'resize': {
      const session = sessions.get(msg.sessionId);
      if (session) {
        session.term.resize(msg.cols || 80, msg.rows || 24);
      }
      break;
    }

    case 'kill': {
      const session = sessions.get(msg.sessionId);
      if (session) {
        session.term.kill();
        sessions.delete(msg.sessionId);
        log(`Session killed: ${msg.sessionId}`);
        broadcastSessionList();
      }
      break;
    }

    case 'ping': {
      ws.send(JSON.stringify({ type: 'pong' }));
      break;
    }

    case 'start_preview': {
      const port = msg.port || 3000;
      log(`Preview requested for port ${port}`);

      if (!tunnelUrl) {
        ws.send(JSON.stringify({ type: 'preview_error', message: 'Tunnel not active yet' }));
        break;
      }

      // Check if dev server is actually running
      const http = require('http');
      const checkReq = http.get(`http://localhost:${port}`, (res) => {
        checkReq.destroy();
        log(`localhost:${port} is reachable (status ${res.statusCode})`);

        // Set the preview port — all HTTP requests through the tunnel will now proxy here
        previewPort = port;
        log(`Preview proxy active: tunnel HTTP → localhost:${port}`);
        ws.send(JSON.stringify({ type: 'preview_ready', url: tunnelUrl, port }));
      });
      checkReq.on('error', (err) => {
        log(`localhost:${port} is NOT reachable: ${err.message}`);
        ws.send(JSON.stringify({ type: 'preview_error', message: `Nothing running on port ${port}` }));
      });
      checkReq.setTimeout(3000, () => {
        checkReq.destroy();
        log(`localhost:${port} timed out`);
        ws.send(JSON.stringify({ type: 'preview_error', message: `Port ${port} timed out` }));
      });
      break;
    }

    case 'stop_preview': {
      previewPort = null;
      log('Preview proxy disabled');
      ws.send(JSON.stringify({ type: 'preview_stopped' }));
      break;
    }

    default:
      ws.send(JSON.stringify({ type: 'error', message: `Unknown message type: ${msg.type}` }));
  }
}

function broadcastSessionList() {
  const list = Array.from(sessions.keys());
  const msg = JSON.stringify({ type: 'sessions', sessions: list });
  for (const client of clients) {
    if (client.readyState === client.OPEN) {
      client.send(msg);
    }
  }
  if (dashboardWindow && !dashboardWindow.isDestroyed()) {
    dashboardWindow.webContents.send('sessions', list);
  }
}

// ─── Tray & Dashboard Window ────────────────────────────────────────────────

function createTray() {
  const iconSize = 16;
  const canvas = `
    <svg xmlns="http://www.w3.org/2000/svg" width="${iconSize}" height="${iconSize}" viewBox="0 0 16 16">
      <rect width="16" height="16" rx="3" fill="#1a1a2e"/>
      <text x="3" y="12" font-family="monospace" font-size="11" fill="#00ff88">></text>
    </svg>
  `;
  const dataUrl = `data:image/svg+xml;base64,${Buffer.from(canvas).toString('base64')}`;
  const icon = nativeImage.createFromDataURL(dataUrl).resize({ width: 16, height: 16 });

  tray = new Tray(icon);
  tray.setToolTip('OpenRemote');

  const contextMenu = Menu.buildFromTemplate([
    {
      label: 'Open Dashboard',
      click: () => showDashboard(),
    },
    {
      label: `Port: ${store.get('port')}`,
      enabled: false,
    },
    {
      label: tunnelUrl ? `Tunnel: Active` : 'Tunnel: Connecting...',
      enabled: false,
    },
    { type: 'separator' },
    {
      label: 'Copy Pairing Token',
      click: () => {
        const { clipboard } = require('electron');
        clipboard.writeText(store.get('authToken'));
      },
    },
    { type: 'separator' },
    {
      label: 'Quit OpenRemote',
      click: () => {
        cleanup();
        app.quit();
      },
    },
  ]);

  tray.setContextMenu(contextMenu);
  tray.on('click', () => showDashboard());
}

function showDashboard() {
  if (dashboardWindow && !dashboardWindow.isDestroyed()) {
    dashboardWindow.focus();
    return;
  }

  dashboardWindow = new BrowserWindow({
    width: 900,
    height: 650,
    resizable: true,
    frame: true,
    title: 'OpenRemote',
    vibrancy: 'fullscreen-ui',
    visualEffectState: 'active',
    backgroundColor: '#00000000',
    transparent: false,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
    },
  });

  dashboardWindow.loadFile(path.join(__dirname, 'index.html'));

  dashboardWindow.on('closed', () => {
    dashboardWindow = null;
  });
}

// ─── IPC Handlers ───────────────────────────────────────────────────────────

function setupIPC() {
  ipcMain.handle('get-status', () => ({
    port: store.get('port'),
    authToken: store.get('authToken'),
    tunnelUrl: tunnelUrl,
    connectedClients: clients.size,
    activeSessions: Array.from(sessions.keys()),
    logs: logs.slice(-50),
  }));

  // QR encodes { url, token } JSON for the mobile app to scan
  ipcMain.handle('get-qr-code', async () => {
    const data = JSON.stringify({
      url: tunnelUrl || `ws://localhost:${store.get('port')}`,
      token: store.get('authToken'),
    });

    try {
      return await QRCode.toDataURL(data, {
        width: 256,
        margin: 2,
        color: { dark: '#000000', light: '#ffffff' },
      });
    } catch (err) {
      log(`QR generation failed: ${err.message}`);
      return null;
    }
  });

  ipcMain.handle('regenerate-token', () => {
    const newToken = crypto.randomBytes(16).toString('hex');
    store.set('authToken', newToken);
    for (const client of clients) {
      client.send(JSON.stringify({ type: 'error', message: 'Token regenerated — reconnect required' }));
      client.close();
    }
    clients.clear();
    log('Auth token regenerated — all clients disconnected');
    return newToken;
  });
}

// ─── Cleanup ────────────────────────────────────────────────────────────────

function cleanup() {
  for (const [id, session] of sessions) {
    session.term.kill();
  }
  sessions.clear();

  if (tunnelProcess) {
    tunnelProcess.kill();
    tunnelProcess = null;
  }

  if (wss) {
    wss.close();
  }

  if (httpServer) {
    httpServer.close();
  }
}

// ─── App Lifecycle ──────────────────────────────────────────────────────────

if (process.platform === 'darwin') {
  app.dock.hide();
}

app.whenReady().then(async () => {
  ensureAuthToken();

  const port = store.get('port');
  startWebSocketServer(port);
  await startTunnel(port);
  setupIPC();
  createTray();
  showDashboard();

  log('OpenRemote is running');
});

app.on('window-all-closed', (e) => {
  e.preventDefault();
});

app.on('before-quit', () => {
  cleanup();
});
