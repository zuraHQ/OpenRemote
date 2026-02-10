const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('clawRemote', {
  getStatus: () => ipcRenderer.invoke('get-status'),
  getQRCode: () => ipcRenderer.invoke('get-qr-code'),
  regenerateToken: () => ipcRenderer.invoke('regenerate-token'),

  onLog: (callback) => {
    ipcRenderer.on('log', (_event, entry) => callback(entry));
  },
  onTunnelUrl: (callback) => {
    ipcRenderer.on('tunnel-url', (_event, url) => callback(url));
  },
  onSessions: (callback) => {
    ipcRenderer.on('sessions', (_event, sessions) => callback(sessions));
  },
  onTerminalOutput: (callback) => {
    ipcRenderer.on('terminal-output', (_event, data) => callback(data));
  },
});
