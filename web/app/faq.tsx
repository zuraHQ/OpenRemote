"use client";

import { useState } from "react";

const faqs = [
  {
    q: "What is OpenRemote?",
    a: "OpenRemote lets you control Claude Code running on your Mac from your phone. Send prompts, see live tool activity, and preview dev servers wirelessly.",
  },
  {
    q: "Is it free?",
    a: "Yes. OpenRemote is completely free and open source. You just need an existing Claude Code subscription on your desktop.",
  },
  {
    q: "How does the connection work?",
    a: "The desktop app runs a local WebSocket server and creates a secure Cloudflare tunnel. Your phone connects through this tunnel. No port forwarding or network config needed.",
  },
  {
    q: "Do I need to install anything on my Mac?",
    a: "You need the OpenRemote desktop app and Claude Code (CLI) installed. The desktop app handles everything else automatically.",
  },
  {
    q: "Is my code sent to any third-party servers?",
    a: "No. The connection goes through a Cloudflare tunnel directly to your Mac. Your code and prompts stay between your phone and your computer.",
  },
  {
    q: "Does it work on Windows or Linux?",
    a: "Currently the desktop app is Mac only. Windows and Linux support is planned for a future release.",
  },
];

export default function FAQ() {
  const [open, setOpen] = useState<number | null>(null);

  return (
    <section className="max-w-2xl mx-auto px-6 py-24 w-full">
      <p className="text-xs font-semibold text-orange-500/60 tracking-widest uppercase text-center mb-3">
        Questions
      </p>
      <h2 className="text-2xl sm:text-3xl font-bold tracking-[-0.02em] text-center mb-12">
        FAQ
      </h2>
      <div className="space-y-1">
        {faqs.map((faq, i) => (
          <button
            key={i}
            onClick={() => setOpen(open === i ? null : i)}
            className="w-full text-left group"
          >
            <div
              className={`border rounded-lg px-5 py-4 transition-all duration-300 ${
                open === i
                  ? "border-neutral-700 bg-neutral-900/50"
                  : "border-neutral-800/60 hover:border-neutral-700"
              }`}
            >
              <div className="flex items-center justify-between gap-4">
                <span className="text-sm font-medium text-neutral-300">
                  {faq.q}
                </span>
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  width="14"
                  height="14"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  className={`text-neutral-600 shrink-0 transition-transform duration-300 ${
                    open === i ? "rotate-180" : ""
                  }`}
                >
                  <path d="M6 9l6 6 6-6" />
                </svg>
              </div>
              <div
                className={`overflow-hidden transition-all duration-300 ${
                  open === i ? "max-h-40 mt-3" : "max-h-0"
                }`}
              >
                <p className="text-sm text-neutral-500 leading-relaxed">
                  {faq.a}
                </p>
              </div>
            </div>
          </button>
        ))}
      </div>
    </section>
  );
}
