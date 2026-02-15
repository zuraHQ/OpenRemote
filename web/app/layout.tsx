import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "OpenRemote - Control Claude from your phone",
  description:
    "Send prompts, see live tool activity, and preview dev servers — all from your phone. Open source.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="dark">
      <body className="antialiased bg-black text-white">
        {children}
      </body>
    </html>
  );
}
