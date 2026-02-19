import Image from "next/image";
import Link from "next/link";
import FAQ from "./faq";

export default function Home() {
  return (
    <div className="min-h-screen flex flex-col relative">
      {/* Nav */}
      <nav className="sticky top-0 z-50 glass-nav">
        <div className="max-w-5xl mx-auto flex items-center justify-between px-6 py-3">
        <div className="flex items-center gap-2.5">
          <Image src="/logo.png" alt="OpenRemote" width={24} height={24} className="rounded-md" />
          <span className="font-semibold text-[14px] tracking-[-0.01em] text-white/90">
            OpenRemote
          </span>
        </div>
        <div className="flex items-center gap-3">
          <a
            href="https://github.com/zuraHQ/OpenRemote"
            target="_blank"
            rel="noopener noreferrer"
            className="flex items-center gap-1.5 text-xs text-white/35 hover:text-white/70 transition-colors"
          >
            <svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="currentColor">
              <path d="M12 0C5.37 0 0 5.37 0 12c0 5.31 3.435 9.795 8.205 11.385.6.105.825-.255.825-.57 0-.285-.015-1.23-.015-2.235-3.015.555-3.795-.735-4.035-1.41-.135-.345-.72-1.41-1.23-1.695-.42-.225-1.02-.78-.015-.795.945-.015 1.62.87 1.845 1.23 1.08 1.815 2.805 1.305 3.495.99.105-.78.42-1.305.765-1.605-2.67-.3-5.46-1.335-5.46-5.925 0-1.305.465-2.385 1.23-3.225-.12-.3-.54-1.53.12-3.18 0 0 1.005-.315 3.3 1.23.96-.27 1.98-.405 3-.405s2.04.135 3 .405c2.295-1.56 3.3-1.23 3.3-1.23.66 1.65.24 2.88.12 3.18.765.84 1.23 1.905 1.23 3.225 0 4.605-2.805 5.625-5.475 5.925.435.375.81 1.095.81 2.22 0 1.605-.015 2.895-.015 3.3 0 .315.225.69.825.57A12.02 12.02 0 0 0 24 12c0-6.63-5.37-12-12-12z" />
            </svg>
            <span className="hidden sm:inline">GitHub</span>
          </a>
          <a
            href="https://github.com/zuraHQ/OpenRemote/releases"
            target="_blank"
            rel="noopener noreferrer"
            className="text-xs font-medium text-white bg-white/10 hover:bg-white/15 px-4 py-1.5 rounded-full transition-colors"
          >
            Download
          </a>
        </div>
        </div>
      </nav>

      {/* Hero */}
      <main className="relative z-10 flex-1 flex flex-col items-center justify-center px-6 text-center max-w-5xl mx-auto pt-24 sm:pt-32 pb-36">
        <div className="mb-6">
          <span className="glass-pill inline-flex items-center gap-2 px-4 py-1.5 rounded-full text-[11px] text-white/50 tracking-wide uppercase">
            <span className="w-1.5 h-1.5 rounded-full bg-emerald-400" />
            Open Source
          </span>
        </div>

        <h1 className="hero-headlinetext-[clamp(2.5rem,8vw,7rem)] font-bold tracking-[-0.05em] leading-[0.9] mb-6">
          Claude Code
          <br />
          <span className="font-light tracking-[-0.03em] text-white/70">in your pocket</span>
        </h1>

        <p className="hero-subtext-sm sm:text-base max-w-md mb-10 leading-relaxed">
          Send prompts, watch tool activity in real time, and preview
          dev servers. All from your couch.
        </p>

        <div className="flex flex-col sm:flex-row gap-3 w-full sm:w-auto">
          <a
            href="https://github.com/zuraHQ/OpenRemote/releases"
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center justify-center gap-2.5 bg-white text-black text-sm font-semibold px-7 py-3.5 rounded-full hover:bg-white/90 hover:scale-[1.02] transition-all duration-200"
          >
            <svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
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
            className="glass-pill inline-flex items-center justify-center gap-2.5 text-sm font-medium px-7 py-3.5 rounded-full text-white/80 hover:text-white hover:bg-white/[0.08] transition-all duration-200"
          >
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
              <rect x="5" y="2" width="14" height="20" rx="2" ry="2" />
              <line x1="12" y1="18" x2="12.01" y2="18" />
            </svg>
            Download iOS App
          </a>
        </div>

        <div className="flex flex-wrap justify-center gap-2 mt-12">
          <span className="glass-pill flex items-center gap-1.5 px-3 py-1.5 rounded-full text-[11px] text-white/35">
            <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
              <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
            </svg>
            Encrypted
          </span>
          <span className="glass-pill flex items-center gap-1.5 px-3 py-1.5 rounded-full text-[11px] text-white/35">
            <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
              <circle cx="12" cy="12" r="10" />
              <polyline points="12 6 12 12 16 14" />
            </svg>
            30s setup
          </span>
          <span className="glass-pill flex items-center gap-1.5 px-3 py-1.5 rounded-full text-[11px] text-white/35">
            <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
              <path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6" />
              <polyline points="15 3 21 3 21 9" />
              <line x1="10" y1="14" x2="21" y2="3" />
            </svg>
            Open source
          </span>
        </div>
      </main>

      {/* Features */}
      <section className="relative z-10 max-w-5xl mx-auto px-6 py-24 sm:py-32 w-full">
        <p className="text-[11px] font-medium text-white/25 tracking-widest uppercase text-center mb-3">
          How it works
        </p>
        <h2 className="text-2xl sm:text-3xl font-bold tracking-[-0.03em] text-center mb-16 sm:mb-20 text-white/80">
          Three steps. That&apos;s it.
        </h2>

        <div className="space-y-20 sm:space-y-28">
          {/* Feature 1 — Install & Scan */}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-8 sm:gap-14 items-center">
            <div className="glass-card rounded-2xl aspect-[4/3] flex items-center justify-center overflow-hidden">
              {/* Replace with: <Image src="/feature-scan.png" alt="Scan QR code" fill className="object-cover" /> */}
              <span className="text-[13px] text-white/15 font-mono">feature-scan.png</span>
            </div>
            <div>
              <span className="text-[13px] font-mono text-white/15 mb-4 block">01</span>
              <h3 className="text-xl sm:text-2xl font-semibold tracking-[-0.02em] mb-3 text-white/85">
                Install & scan
              </h3>
              <p className="text-[14px] text-white/35 leading-[1.8] max-w-sm">
                Download the Mac app and the iOS app. Scan the QR code — no config, no IP addresses, no port forwarding.
              </p>
            </div>
          </div>

          {/* Feature 2 — Send Prompts */}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-8 sm:gap-14 items-center">
            <div className="order-1 sm:order-2 glass-card rounded-2xl aspect-[4/3] flex items-center justify-center overflow-hidden">
              {/* Replace with: <Image src="/feature-prompt.png" alt="Send prompts" fill className="object-cover" /> */}
              <span className="text-[13px] text-white/15 font-mono">feature-prompt.png</span>
            </div>
            <div className="order-2 sm:order-1">
              <span className="text-[13px] font-mono text-white/15 mb-4 block">02</span>
              <h3 className="text-xl sm:text-2xl font-semibold tracking-[-0.02em] mb-3 text-white/85">
                Send prompts
              </h3>
              <p className="text-[14px] text-white/35 leading-[1.8] max-w-sm">
                Type from your phone. Claude Code runs on your Mac. Watch every file read, edit, and command execute in real time.
              </p>
            </div>
          </div>

          {/* Feature 3 — Preview Live */}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-8 sm:gap-14 items-center">
            <div className="glass-card rounded-2xl aspect-[4/3] flex items-center justify-center overflow-hidden">
              {/* Replace with: <Image src="/feature-preview.png" alt="Live preview" fill className="object-cover" /> */}
              <span className="text-[13px] text-white/15 font-mono">feature-preview.png</span>
            </div>
            <div>
              <span className="text-[13px] font-mono text-white/15 mb-4 block">03</span>
              <h3 className="text-xl sm:text-2xl font-semibold tracking-[-0.02em] mb-3 text-white/85">
                Preview live
              </h3>
              <p className="text-[14px] text-white/35 leading-[1.8] max-w-sm">
                Your dev server tunnels securely to your phone via Cloudflare. See changes as they happen — no public hosting.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* FAQ */}
      <FAQ />

      {/* Footer */}
      <footer className="relative z-10 border-t border-white/[0.04] py-8 px-6">
        <div className="max-w-5xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-4">
          <div className="flex items-center gap-2">
            <Image src="/logo.png" alt="OpenRemote" width={16} height={16} className="rounded-sm opacity-40" />
            <span className="text-[11px] text-white/20">OpenRemote</span>
          </div>
          <div className="flex items-center gap-5 text-[11px] text-white/20">
            <a href="https://github.com/zuraHQ/OpenRemote" target="_blank" rel="noopener noreferrer" className="hover:text-white/50 transition-colors">
              GitHub
            </a>
            <a href="https://github.com/zuraHQ/OpenRemote/releases" target="_blank" rel="noopener noreferrer" className="hover:text-white/50 transition-colors">
              Releases
            </a>
            <Link href="/terms" className="hover:text-white/50 transition-colors">
              Terms
            </Link>
            <Link href="/privacy" className="hover:text-white/50 transition-colors">
              Privacy
            </Link>
          </div>
        </div>
      </footer>
    </div>
  );
}
