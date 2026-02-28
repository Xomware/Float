import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Float Merchant Portal",
  description: "Manage your deals, venues, and analytics with Float",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
