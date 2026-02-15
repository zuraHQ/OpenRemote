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
          <span className="font-semibold text-[15px] tracking-[-0.01em]">
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
      <main className="relative z-10 flex-1 flex flex-col items-center justify-center px-6 text-center max-w-3xl mx-auto pt-12 pb-24">
        <h1 className="text-5xl sm:text-7xl font-bold tracking-[-0.04em] leading-[1.15] mb-6">
          Control{" "}
          <span className="inline-flex items-center gap-2 sm:gap-3 bg-[#C15F3C]/10 border border-[#C15F3C]/20 rounded-2xl px-4 sm:px-5 py-1.5 align-middle">
            <svg viewBox="0 0 16 16" fill="#C15F3C" className="w-7 h-7 sm:w-9 sm:h-9 shrink-0">
              <path d="m3.127 10.604 3.135-1.76.053-.153-.053-.085H6.11l-.525-.032-1.791-.048-1.554-.065-1.505-.08-.38-.081L0 7.832l.036-.234.32-.214.455.04 1.009.069 1.513.105 1.097.064 1.626.17h.259l.036-.105-.089-.065-.068-.064-1.566-1.062-1.695-1.121-.887-.646-.48-.327-.243-.306-.104-.67.435-.48.585.04.15.04.593.456 1.267.981 1.654 1.218.242.202.097-.068.012-.049-.109-.181-.9-1.626-.96-1.655-.428-.686-.113-.411a2 2 0 0 1-.068-.484l.496-.674L4.446 0l.662.089.279.242.411.94.666 1.48 1.033 2.014.302.597.162.553.06.17h.105v-.097l.085-1.134.157-1.392.154-1.792.052-.504.25-.605.497-.327.387.186.319.456-.045.294-.19 1.23-.37 1.93-.243 1.29h.142l.161-.16.654-.868 1.097-1.372.484-.545.565-.601.363-.287h.686l.505.751-.226.775-.707.895-.585.759-.839 1.13-.524.904.048.072.125-.012 1.897-.403 1.024-.186 1.223-.21.553.258.06.263-.218.536-1.307.323-1.533.307-2.284.54-.028.02.032.04 1.029.098.44.024h1.077l2.005.15.525.346.315.424-.053.323-.807.411-3.631-.863-.872-.218h-.12v.073l.726.71 1.331 1.202 1.667 1.55.084.383-.214.302-.226-.032-1.464-1.101-.565-.497-1.28-1.077h-.084v.113l.295.432 1.557 2.34.08.718-.112.234-.404.141-.444-.08-.911-1.28-.94-1.44-.759-1.291-.093.053-.448 4.821-.21.246-.484.186-.403-.307-.214-.496.214-.98.258-1.28.21-1.016.19-1.263.112-.42-.008-.028-.092.012-.953 1.307-1.448 1.957-1.146 1.227-.274.109-.477-.247.045-.44.266-.39 1.586-2.018.956-1.25.617-.723-.004-.105h-.036l-4.212 2.736-.75.096-.324-.302.04-.496.154-.162 1.267-.871z"/>
            </svg>
            <span className="text-[#C15F3C]">Claude</span>
          </span>
          <br />
          from your phone
        </h1>

        <p className="text-base sm:text-lg text-neutral-500 max-w-md mb-10 leading-relaxed">
          Send prompts, watch live tool activity, and preview dev servers. All
          from the couch.
        </p>

        <div className="flex flex-col gap-3 w-full max-w-sm">
          <a
            href="https://github.com/zuraHQ/OpenRemote/releases"
            target="_blank"
            rel="noopener noreferrer"
            className="group inline-flex items-center justify-center gap-2.5 bg-white text-black text-sm font-medium px-7 py-3 rounded-full hover:bg-neutral-100 transition-all duration-300"
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="16"
              height="16"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              strokeLinecap="round"
              strokeLinejoin="round"
              className="opacity-70 group-hover:opacity-100 transition-opacity"
            >
              <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
              <polyline points="7 10 12 15 17 10" />
              <line x1="12" y1="15" x2="12" y2="3" />
            </svg>
            Download Desktop App
          </a>

          <a
            href="https://github.com/zuraHQ/OpenRemote"
            target="_blank"
            rel="noopener noreferrer"
            className="group inline-flex items-center justify-center gap-2.5 bg-neutral-900 text-white text-sm font-medium px-7 py-3 rounded-full border border-neutral-700 hover:bg-neutral-800 transition-all duration-300"
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="16"
              height="16"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              strokeLinecap="round"
              strokeLinejoin="round"
              className="opacity-80 group-hover:opacity-100 transition-opacity"
            >
              <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
              <polyline points="7 10 12 15 17 10" />
              <line x1="12" y1="15" x2="12" y2="3" />
            </svg>
            Download iOS App
          </a>
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
            <p className="text-xs font-mono text-orange-500/60 tracking-wide uppercase mb-3">
              Real-time
            </p>
            <h3 className="text-2xl sm:text-3xl font-bold tracking-[-0.02em] mb-4">
              Live Activity
            </h3>
            <p className="text-neutral-500 leading-relaxed">
              See exactly what Claude is doing — reading files, running
              commands, editing code. Every tool call streams to your phone as it
              happens.
            </p>
          </div>
        </div>

        {/* Feature 2: Text left, phone mock right */}
        <div className="flex flex-col-reverse sm:flex-row items-center gap-16">
          <div className="flex-1">
            <p className="text-xs font-mono text-orange-500/60 tracking-wide uppercase mb-3">
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
            <p className="text-xs font-mono text-orange-500/60 tracking-wide uppercase mb-3">
              Cloudflare Tunnel
            </p>
            <h3 className="text-2xl sm:text-3xl font-bold tracking-[-0.02em] mb-4">
              Preview Servers
            </h3>
            <p className="text-neutral-500 leading-relaxed">
              Your dev server, tunneled securely to your phone. See changes live
              through Cloudflare — no public hosting, no exposure.
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
            <span className="font-mono text-xs">OpenRemote</span>
          </div>
          <div className="flex items-center gap-6 text-xs text-neutral-600 font-mono">
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
