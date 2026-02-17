import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";

const inter = Inter({
  subsets: ["latin"],
  variable: "--font-inter",
});

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
    <html lang="en" className={`dark ${inter.variable}`}>
      <body className="antialiased bg-black text-white font-sans">
        {children}
      </body>
    </html>
  );
}
