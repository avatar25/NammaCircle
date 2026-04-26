import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "NammaCircle Admin",
  description: "Moderation and operations dashboard for NammaCircle."
};

export default function RootLayout({
  children
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
