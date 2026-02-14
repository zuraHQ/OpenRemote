import Image from "next/image";
import Link from "next/link";
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Privacy Policy - OpenRemote",
};

export default function Privacy() {
  return (
    <div className="min-h-screen flex flex-col">
      <nav className="flex items-center justify-between px-6 py-5 max-w-6xl mx-auto w-full">
        <Link href="/" className="flex items-center gap-2.5">
          <Image src="/logo.png" alt="OpenRemote" width={28} height={28} className="rounded-md" />
          <span className="font-semibold text-[15px] tracking-[-0.01em]">OpenRemote</span>
        </Link>
      </nav>

      <main className="flex-1 max-w-2xl mx-auto px-6 py-12 w-full">
        <h1 className="text-3xl font-bold tracking-[-0.02em] mb-2">Privacy Policy</h1>
        <p className="text-sm text-neutral-500 mb-10">Last updated: February 12, 2025</p>

        <div className="space-y-8 text-sm text-neutral-400 leading-relaxed">
          <section>
            <h2 className="text-base font-semibold text-white mb-3">1. Overview</h2>
            <p>
              OpenRemote is designed with privacy as a core principle. We do not collect, store, or transmit your personal data, code, or prompts to any third-party servers.
            </p>
          </section>

          <section>
            <h2 className="text-base font-semibold text-white mb-3">2. Data Collection</h2>
            <p>
              OpenRemote does not collect any personal information. We do not use analytics, tracking, or telemetry. No account or registration is required to use the App.
            </p>
          </section>

          <section>
            <h2 className="text-base font-semibold text-white mb-3">3. How Your Data Flows</h2>
            <p>
              When you use OpenRemote, your prompts and code travel directly between your phone and your computer through a Cloudflare tunnel. The connection is a peer-to-peer WebSocket link. Your data passes through Cloudflare&apos;s network to establish the tunnel, but is not stored by Cloudflare or by us. No data is sent to OpenRemote servers because there are none.
            </p>
          </section>

          <section>
            <h2 className="text-base font-semibold text-white mb-3">4. Local Storage</h2>
            <p>
              The App stores your connection URL and authentication token locally on your device to enable automatic reconnection. This data stays on your device and is never transmitted to us. You can clear this data at any time by disconnecting from within the App.
            </p>
          </section>

          <section>
            <h2 className="text-base font-semibold text-white mb-3">5. Third-Party Services</h2>
            <p>
              OpenRemote uses Cloudflare Tunnels to establish a secure connection between your phone and computer. Cloudflare&apos;s privacy policy applies to the tunnel infrastructure. Claude Code is provided by Anthropic, and their privacy policy governs your use of Claude. OpenRemote itself does not integrate with any other third-party services or SDKs that collect user data.
            </p>
          </section>

          <section>
            <h2 className="text-base font-semibold text-white mb-3">6. Children&apos;s Privacy</h2>
            <p>
              OpenRemote is not directed at children under the age of 13. We do not knowingly collect any information from children.
            </p>
          </section>

          <section>
            <h2 className="text-base font-semibold text-white mb-3">7. Changes to This Policy</h2>
            <p>
              We may update this Privacy Policy from time to time. Changes will be posted on this page with an updated date.
            </p>
          </section>

          <section>
            <h2 className="text-base font-semibold text-white mb-3">8. Contact</h2>
            <p>
              For questions about this Privacy Policy, please open an issue on our GitHub repository at github.com/zuraHQ/OpenRemote.
            </p>
          </section>
        </div>
      </main>

      <footer className="border-t border-neutral-900 py-8 px-6">
        <div className="max-w-6xl mx-auto flex items-center justify-center gap-6 text-xs text-neutral-600 font-mono">
          <Link href="/terms" className="hover:text-neutral-300 transition-colors duration-300">Terms</Link>
          <Link href="/privacy" className="text-neutral-300">Privacy</Link>
        </div>
      </footer>
    </div>
  );
}
