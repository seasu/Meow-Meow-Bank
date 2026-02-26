import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "喵喵金幣屋 Meow Meow Bank",
  description: "存出你的小夢想！Save your dreams, one meow at a time.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="zh-TW">
      <body className="min-h-screen antialiased">{children}</body>
    </html>
  );
}
