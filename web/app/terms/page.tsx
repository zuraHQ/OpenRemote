import Image from "next/image";
import Link from "next/link";
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Terms of Service - OpenRemote",
};

export default function Terms() {
  return (
    <div className="min-h-screen flex flex-col">
      <nav className="flex items-center justify-between px-6 py-5 max-w-6xl mx-auto w-full">
        <Link href="/" className="flex items-center gap-2.5">
          <Image src="/logo.png" alt="OpenRemote" width={28} height={28} className="rounded-md" />
          <span className="font-semibold text-[15px] tracking-[-0.01em]">OpenRemote</span>
        </Link>
      </nav>

      <main className="flex-1 max-w-2xl mx-auto px-6 py-12 w-full">
        <h1 className="text-3xl font-bold tracking-[-0.02em] mb-2">Terms of Service</h1>
        <p className="text-sm text-neutral-500 mb-10">Last updated: February 12, 2025</p>

        <div className="space-y-8 text-sm text-neutral-400 leading-relaxed">
          <section>
            <h2 className="text-base font-semibold text-white mb-3">1. Acceptance of Terms</h2>
            <p>
              By downloading, installing, or using OpenRemote (&quot;the App&quot;), you agree to be bound by these Terms of Service. If you do not agree to these terms, do not use the App.
            </p>
          </section>

          <section>
            <h2 className="text-base font-semibold text-white mb-3">2. Description of Service</h2>
            <p>
              OpenRemote is an open-source tool that allows you to remotely control Claude Code running on your desktop computer from your mobile device. The App facilitates communication between your phone and your computer through a secure WebSocket connection via Cloudflare tunnels.
            </p>
          </section>

          <section>
            <h2 className="text-base font-semibold text-white mb-3">3. Requirements</h2>
            <p>
              To use OpenRemote, you need a Mac computer with the OpenRemote desktop app installed, a valid Claude Code subscription from Anthropic, and an iOS device. OpenRemote does not provide access to Claude Code itself. You are responsible for maintaining your own Claude Code subscription and complying with Anthropic&apos;s terms of service.
            </p>
          </section>

          <section>
            <h2 className="text-base font-semibold text-white mb-3">4. Open Source License</h2>
            <p>
              OpenRemote is open-source software. The source code is available on GitHub at github.com/zuraHQ/OpenRemote. Your use of the source code is governed by the applicable open-source license in the repository.
            </p>
          </section>

          <section>
            <h2 className="text-base font-semibold text-white mb-3">5. User Responsibilities</h2>
            <p>
              You are solely responsible for all commands and prompts sent through the App. You are responsible for ensuring that your use of Claude Code through OpenRemote complies with all applicable laws and Anthropic&apos;s terms. You should not use OpenRemote to execute malicious commands or access unauthorized systems.
            </p>
          </section>

          <section>
            <h2 className="text-base font-semibold text-white mb-3">6. Disclaimer of Warranties</h2>
            <p>
              The App is provided &quot;as is&quot; and &quot;as available&quot; without warranties of any kind, either express or implied. We do not warrant that the App will be uninterrupted, error-free, or secure. Use the App at your own risk.
            </p>
          </section>

          <section>
            <h2 className="text-base font-semibold text-white mb-3">7. Limitation of Liability</h2>
            <p>
              To the maximum extent permitted by law, OpenRemote and its contributors shall not be liable for any indirect, incidental, special, consequential, or punitive damages, including but not limited to loss of data, loss of profits, or damages resulting from commands executed through the App.
            </p>
          </section>

          <section>
            <h2 className="text-base font-semibold text-white mb-3">8. Changes to Terms</h2>
            <p>
              We reserve the right to modify these terms at any time. Changes will be posted on this page with an updated date. Continued use of the App after changes constitutes acceptance of the new terms.
            </p>
          </section>

          <section>
            <h2 className="text-base font-semibold text-white mb-3">9. Contact</h2>
            <p>
              For questions about these Terms, please open an issue on our GitHub repository at github.com/zuraHQ/OpenRemote.
            </p>
          </section>
        </div>
      </main>

      <footer className="border-t border-neutral-900 py-8 px-6">
        <div className="max-w-6xl mx-auto flex items-center justify-center gap-6 text-xs text-neutral-600 font-mono">
          <Link href="/terms" className="text-neutral-300">Terms</Link>
          <Link href="/privacy" className="hover:text-neutral-300 transition-colors duration-300">Privacy</Link>
        </div>
      </footer>
    </div>
  );
}
