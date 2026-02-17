import Image from "next/image";
import Link from "next/link";
import FAQ from "./faq";

export default function Home() {
  return (
    <div className="min-h-screen flex flex-col relative overflow-hidden">
      {/* Nav */}
      <nav className="relative z-10 flex items-center justify-between px-6 py-5 max-w-6xl mx-auto w-full">
        <div className="flex items-center gap-2.5">
          <Image src="/logo.png" alt="OpenRemote" width={28} height={28} className="rounded-md" />
          <span className="font-semibold text-[15px] tracking-[-0.02em]">
            OpenRemote
          </span>
        </div>
        <a
          href="https://github.com/zuraHQ/OpenRemote"
          target="_blank"
          rel="noopener noreferrer"
          className="flex items-center gap-2 text-sm text-neutral-500 hover:text-white transition-colors duration-300"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            width="18"
            height="18"
            viewBox="0 0 24 24"
            fill="currentColor"
          >
            <path d="M12 0C5.37 0 0 5.37 0 12c0 5.31 3.435 9.795 8.205 11.385.6.105.825-.255.825-.57 0-.285-.015-1.23-.015-2.235-3.015.555-3.795-.735-4.035-1.41-.135-.345-.72-1.41-1.23-1.695-.42-.225-1.02-.78-.015-.795.945-.015 1.62.87 1.845 1.23 1.08 1.815 2.805 1.305 3.495.99.105-.78.42-1.305.765-1.605-2.67-.3-5.46-1.335-5.46-5.925 0-1.305.465-2.385 1.23-3.225-.12-.3-.54-1.53.12-3.18 0 0 1.005-.315 3.3 1.23.96-.27 1.98-.405 3-.405s2.04.135 3 .405c2.295-1.56 3.3-1.23 3.3-1.23.66 1.65.24 2.88.12 3.18.765.84 1.23 1.905 1.23 3.225 0 4.605-2.805 5.625-5.475 5.925.435.375.81 1.095.81 2.22 0 1.605-.015 2.895-.015 3.3 0 .315.225.69.825.57A12.02 12.02 0 0 0 24 12c0-6.63-5.37-12-12-12z" />
          </svg>
          Star on GitHub
        </a>
      </nav>

      {/* Hero */}
      <main className="relative z-10 flex-1 flex flex-col items-center justify-center px-6 text-center max-w-4xl mx-auto pt-20 sm:pt-28 pb-32">
        <div className="hero-glow" />

<h1 className="animate-fade-up stagger-1 text-5xl sm:text-7xl lg:text-8xl font-bold tracking-[-0.04em] leading-[0.95] mb-8">
          Claude Code
          <br />
          <span className="hero-gradient">in your pocket</span>
        </h1>

        <p className="animate-fade-up stagger-2 text-base sm:text-lg text-neutral-500 max-w-lg mb-12 leading-relaxed">
          Send prompts, watch tool activity in real time, and preview
          dev servers. All from your couch.
        </p>

        <div className="animate-fade-up stagger-3 flex flex-col gap-3 w-full max-w-xs mx-auto">
          <a
            href="https://github.com/zuraHQ/OpenRemote/releases"
            target="_blank"
            rel="noopener noreferrer"
            className="group inline-flex items-center justify-center gap-2.5 bg-orange-500 text-white text-sm font-semibold px-8 py-4 rounded-full shadow-[0_0_20px_rgba(249,115,22,0.3)] hover:bg-orange-400 hover:shadow-[0_0_40px_rgba(249,115,22,0.4)] hover:scale-[1.03] transition-all duration-300"
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="16"
              height="16"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2.5"
              strokeLinecap="round"
              strokeLinejoin="round"
            >
              <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
              <polyline points="7 10 12 15 17 10" />
              <line x1="12" y1="15" x2="12" y2="3" />
            </svg>
            Download for Mac
          </a>

          <a
            href="https://github.com/zuraHQ/OpenRemote"
            target="_blank"
            rel="noopener noreferrer"
            className="group inline-flex items-center justify-center gap-2.5 text-sm font-semibold px-8 py-4 rounded-full border border-neutral-700 bg-neutral-900 text-white hover:bg-neutral-800 hover:border-neutral-500 hover:scale-[1.03] transition-all duration-300"
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="15"
              height="15"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2.5"
              strokeLinecap="round"
              strokeLinejoin="round"
            >
              <rect x="5" y="2" width="14" height="20" rx="2" ry="2" />
              <line x1="12" y1="18" x2="12.01" y2="18" />
            </svg>
            Download iOS App
          </a>
        </div>

        {/* Social proof / stats row */}
        <div className="animate-fade-up stagger-4 flex items-center gap-8 mt-14 text-neutral-400">
          <div className="flex items-center gap-2">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
            </svg>
            <span className="text-xs">End-to-end encrypted</span>
          </div>
          <div className="h-3 w-px bg-neutral-800" />
          <div className="flex items-center gap-2">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <circle cx="12" cy="12" r="10" />
              <polyline points="12 6 12 12 16 14" />
            </svg>
            <span className="text-xs">Setup in 30 seconds</span>
          </div>
          <div className="h-3 w-px bg-neutral-800" />
          <div className="flex items-center gap-2">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6" />
              <polyline points="15 3 21 3 21 9" />
              <line x1="10" y1="14" x2="21" y2="3" />
            </svg>
            <span className="text-xs">100% open source</span>
          </div>
        </div>
      </main>

      {/* Divider */}
      <div className="w-full max-w-5xl mx-auto px-6">
        <div className="h-px bg-gradient-to-r from-transparent via-neutral-800 to-transparent" />
      </div>

      {/* Features */}
      <section className="max-w-5xl mx-auto px-6 py-28 w-full space-y-32">
        {/* Feature 1: Terminal mock left, text right */}
        <div className="flex flex-col sm:flex-row items-center gap-16">
          <div className="flex-1 w-full">
            <div className="terminal-window">
              <div className="terminal-titlebar">
                <div className="terminal-dot" />
                <div className="terminal-dot" />
                <div className="terminal-dot" />
              </div>
              <div className="terminal-body">
                <p>
                  <span className="highlight">$</span>{" "}
                  <span className="white">claude</span>{" "}
                  <span className="dim">-p &quot;add auth&quot;</span>
                </p>
                <p className="mt-2">
                  <span className="highlight">Reading</span>{" "}
                  src/middleware.ts
                </p>
                <p>
                  <span className="highlight">Editing</span>{" "}
                  src/auth/login.tsx
                </p>
                <p>
                  <span className="highlight">Running</span>{" "}
                  npm test
                </p>
                <p className="mt-2">
                  <span className="green">&#10003;</span>{" "}
                  <span className="white">All 12 tests passed</span>
                </p>
              </div>
            </div>
          </div>
          <div className="flex-1">
            <p className="text-xs font-semibold text-orange-500/60 tracking-widest uppercase mb-3">
              Real-time
            </p>
            <h3 className="text-2xl sm:text-3xl font-bold tracking-[-0.02em] mb-4">
              Live Activity
            </h3>
            <p className="text-neutral-500 leading-relaxed">
              See exactly what Claude is doing. Reading files, running
              commands, editing code. Every tool call streams to your phone as it
              happens.
            </p>
          </div>
        </div>

        {/* Feature 2: Text left, phone mock right */}
        <div className="flex flex-col-reverse sm:flex-row items-center gap-16">
          <div className="flex-1">
            <p className="text-xs font-semibold text-orange-500/60 tracking-widest uppercase mb-3">
              Instant Setup
            </p>
            <h3 className="text-2xl sm:text-3xl font-bold tracking-[-0.02em] mb-4">
              QR Pairing
            </h3>
            <p className="text-neutral-500 leading-relaxed">
              Open the app, point at the QR code, connected. No IP addresses, no
              config files, no port forwarding. The desktop app handles the
              tunnel automatically.
            </p>
          </div>
          <div className="flex-1 flex justify-center">
            <div className="phone-mock">
              <div className="phone-screen">
                <div className="phone-notch" />
                <div className="flex flex-col items-center py-8 px-4">
                  {/* QR placeholder */}
                  <div className="w-28 h-28 border border-neutral-700 rounded-lg flex items-center justify-center mb-4">
                    <svg
                      xmlns="http://www.w3.org/2000/svg"
                      width="48"
                      height="48"
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke="#f97316"
                      strokeWidth="1"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    >
                      <rect x="2" y="2" width="8" height="8" rx="1" />
                      <rect x="14" y="2" width="8" height="8" rx="1" />
                      <rect x="2" y="14" width="8" height="8" rx="1" />
                      <rect x="5" y="5" width="2" height="2" />
                      <rect x="17" y="5" width="2" height="2" />
                      <rect x="5" y="17" width="2" height="2" />
                      <rect x="14" y="14" width="4" height="4" rx="0.5" />
                      <path d="M22 14h-2v2" />
                      <path d="M20 22h2v-2" />
                    </svg>
                  </div>
                  <p className="text-[11px] text-neutral-600 text-center">
                    Scan QR code to connect
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Feature 3: Browser mock left, text right */}
        <div className="flex flex-col sm:flex-row items-center gap-16">
          <div className="flex-1 w-full">
            <div className="terminal-window">
              <div className="terminal-titlebar">
                <div className="terminal-dot" />
                <div className="terminal-dot" />
                <div className="terminal-dot" />
                <div className="flex-1 flex justify-center">
                  <div className="bg-[#111] rounded-md px-4 py-1 text-[11px] text-neutral-600 font-mono">
                    localhost:3000
                  </div>
                </div>
              </div>
              <div className="p-6 flex flex-col items-center justify-center min-h-[160px]">
                <div className="w-full max-w-[200px] space-y-2">
                  <div className="h-3 bg-neutral-800 rounded-full w-3/4" />
                  <div className="h-3 bg-neutral-800 rounded-full w-full" />
                  <div className="h-3 bg-neutral-800 rounded-full w-1/2" />
                  <div className="mt-4 h-8 bg-orange-500/20 border border-orange-500/30 rounded-md flex items-center justify-center">
                    <span className="text-[10px] text-orange-500 font-mono">
                      Live Preview
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div className="flex-1">
            <p className="text-xs font-semibold text-orange-500/60 tracking-widest uppercase mb-3">
              Cloudflare Tunnel
            </p>
            <h3 className="text-2xl sm:text-3xl font-bold tracking-[-0.02em] mb-4">
              Preview Servers
            </h3>
            <p className="text-neutral-500 leading-relaxed">
              Your dev server, tunneled securely to your phone. See changes live
              through Cloudflare. No public hosting, no exposure.
            </p>
          </div>
        </div>
      </section>

      {/* Divider */}
      <div className="w-full max-w-5xl mx-auto px-6">
        <div className="h-px bg-gradient-to-r from-transparent via-neutral-800 to-transparent" />
      </div>

      {/* FAQ */}
      <FAQ />

      {/* Footer */}
      <footer className="border-t border-neutral-900 py-8 px-6">
        <div className="max-w-6xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-4">
          <div className="flex items-center gap-2 text-sm text-neutral-600">
            <Image src="/logo.png" alt="OpenRemote" width={16} height={16} className="rounded-sm" />
            <span className="text-xs">OpenRemote</span>
          </div>
          <div className="flex items-center gap-6 text-xs text-neutral-600">
            <a
              href="https://github.com/zuraHQ/OpenRemote"
              target="_blank"
              rel="noopener noreferrer"
              className="hover:text-neutral-300 transition-colors duration-300"
            >
              GitHub
            </a>
            <a
              href="https://github.com/zuraHQ/OpenRemote/releases"
              target="_blank"
              rel="noopener noreferrer"
              className="hover:text-neutral-300 transition-colors duration-300"
            >
              Releases
            </a>
            <Link href="/terms" className="hover:text-neutral-300 transition-colors duration-300">
              Terms
            </Link>
            <Link href="/privacy" className="hover:text-neutral-300 transition-colors duration-300">
              Privacy
            </Link>
          </div>
        </div>
      </footer>
    </div>
  );
}
