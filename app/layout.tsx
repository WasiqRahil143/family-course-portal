import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Jungle Gymnastics Familienportal",
  description: "Kurse, Termine und Fortschritte an einem Ort.",
  other: {
    "codex-preview": "development",
  },
  icons: {
    icon: "/favicon.svg",
    shortcut: "/favicon.svg",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="de">
      <body className="antialiased">{children}</body>
    </html>
  );
}
