#!/usr/bin/env node
//
// Usage:
//   node test-client.js --token YOUR_TOKEN
//   node test-client.js --url ws://localhost:9876 --token YOUR_TOKEN
//   node test-client.js --tunnel https://xxx.trycloudflare.com --token YOUR_TOKEN
//
// Find the token in the dashboard or: cat ~/.config/claw-remote/config.json

const WebSocket = require('ws');

const args = {};
for (let i = 2; i < process.argv.length; i += 2) {
  args[process.argv[i].replace(/^--/, '')] = process.argv[i + 1];
}

let wsUrl = args.url || 'ws://localhost:9876';
if (args.tunnel) {
  wsUrl = args.tunnel.replace('https://', 'wss://').replace('http://', 'ws://');
}

const token = args.token || null;

const CYAN = '\x1b[36m';
const GREEN = '\x1b[32m';
const YELLOW = '\x1b[33m';
const RED = '\x1b[31m';
const DIM = '\x1b[2m';
const RESET = '\x1b[0m';

function info(msg)  { console.log(`${CYAN}[info]${RESET} ${msg}`); }
function ok(msg)    { console.log(`${GREEN}[ok]${RESET} ${msg}`); }
function warn(msg)  { console.log(`${YELLOW}[warn]${RESET} ${msg}`); }
function err(msg)   { console.log(`${RED}[error]${RESET} ${msg}`); }

info(`Connecting to ${wsUrl}...`);

if (!token) {
  warn('No --token provided. Find it in the Claw Remote dashboard.');
  warn('Usage: node test-client.js --token YOUR_TOKEN');
  process.exit(1);
}

const ws = new WebSocket(wsUrl);
let sessionId = null;

ws.on('open', () => {
  ok('Connected! Sending auth...');
  ws.send(JSON.stringify({ type: 'auth', token, name: 'test-client' }));
});

ws.on('message', (raw) => {
  const msg = JSON.parse(raw.toString());

  switch (msg.type) {
    case 'auth_ok':
      ok('Authenticated!');
      info('Creating terminal session...');
      ws.send(JSON.stringify({ type: 'create_session', cols: 80, rows: 24 }));
      break;

    case 'session_created':
      sessionId = msg.sessionId;
      ok(`Session created: ${sessionId}`);
      info(`Type commands below. ${DIM}Ctrl+C${RESET} to quit.\n`);
      startInteractiveMode();
      break;

    case 'output':
      process.stdout.write(msg.data);
      break;

    case 'session_ended':
      warn(`Session ended (exit code: ${msg.exitCode})`);
      process.exit(0);
      break;

    case 'sessions':
      info(`Active sessions: ${msg.sessions.length > 0 ? msg.sessions.join(', ') : 'none'}`);
      break;

    case 'pong':
      break;

    case 'error':
      err(msg.message);
      if (msg.message === 'Bad token') process.exit(1);
      break;

    default:
      info(`Received: ${JSON.stringify(msg)}`);
  }
});

ws.on('close', () => { warn('Disconnected'); process.exit(0); });
ws.on('error', (e) => { err(`Connection error: ${e.message}`); process.exit(1); });

function startInteractiveMode() {
  if (process.stdin.isTTY) process.stdin.setRawMode(true);
  process.stdin.resume();
  process.stdin.setEncoding('utf8');

  process.stdin.on('data', (key) => {
    if (key === '\x03') {
      info('\nClosing session...');
      if (sessionId) ws.send(JSON.stringify({ type: 'kill', sessionId }));
      setTimeout(() => process.exit(0), 500);
      return;
    }

    if (sessionId && ws.readyState === WebSocket.OPEN) {
      ws.send(JSON.stringify({ type: 'input', sessionId, data: key }));
    }
  });

  setInterval(() => {
    if (ws.readyState === WebSocket.OPEN) {
      ws.send(JSON.stringify({ type: 'ping' }));
    }
  }, 30000);
}
