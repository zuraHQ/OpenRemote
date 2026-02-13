# OpenRemote

Control Claude from your iPhone. Send prompts, see live tool activity, and preview dev servers — all from your phone.

## How it works

1. Run the **desktop app** on your Mac — it starts a WebSocket server and opens a secure tunnel
2. Scan the **QR code** with the iOS app to pair
3. Chat with Claude from your phone — commands run on your Mac

## Project structure

```
desktop/    Electron app (Mac) — terminal server + tunnel
mobile/     iOS app (SwiftUI) — chat UI + QR scanner
```

## Desktop app

Electron app that runs a WebSocket server with a terminal (node-pty). Exposes it via a secure tunnel so the iOS app can connect remotely.

### Run locally

```bash
cd desktop
npm install
npm start
```

### Build .dmg

```bash
cd desktop
npm install
npm run dist:dmg
```

The `.dmg` will be in `desktop/dist/`.

### Requirements

- Node.js 18+
- macOS (uses node-pty)
- Claude CLI installed (`claude` command available in terminal)

## iOS app

SwiftUI app targeting iOS 17+. Connects to the desktop app via WebSocket, sends prompts to Claude CLI, and displays streaming responses with live tool activity.

### Features

- QR code pairing
- Live activity display (reading files, running commands, searching, etc.)
- Syntax-highlighted code blocks with copy
- Model switching (Sonnet, Opus, Haiku)
- Localhost preview (opens in Safari)
- Session management

### Build

Open `mobile/OpenRemote/OpenRemote.xcodeproj` in Xcode and build to your device.

## License

ISC
