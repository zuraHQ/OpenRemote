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
        <h1 className="text-5xl sm:text-7xl font-bold tracking-[-0.04em] leading-[1.05] mb-6">
          Control Claude
          <br />
          from{" "}
          <span className="text-orange-500">your phone</span>
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
            className="group inline-flex items-center justify-center gap-2.5 bg-white text-black text-sm font-medium px-7 py-3 rounded-lg hover:bg-neutral-100 transition-all duration-300"
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="16"
              height="16"
              viewBox="0 0 24 24"
              fill="currentColor"
              className="opacity-70 group-hover:opacity-100 transition-opacity"
            >
              <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z" />
            </svg>
            Download Desktop App
          </a>

          <a
            href="https://github.com/zuraHQ/OpenRemote"
            target="_blank"
            rel="noopener noreferrer"
            className="group inline-flex items-center justify-center gap-2.5 bg-neutral-900 text-white text-sm font-medium px-7 py-3 rounded-lg border border-neutral-700 hover:bg-neutral-800 transition-all duration-300"
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="16"
              height="16"
              viewBox="0 0 24 24"
              fill="currentColor"
              className="opacity-80 group-hover:opacity-100 transition-opacity"
            >
              <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z" />
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
