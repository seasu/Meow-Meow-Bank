import type { Metadata } from "next";
import { AppProvider } from "@/lib/context";
import TabBar from "@/components/TabBar";
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
      <body className="min-h-screen antialiased pb-20">
        <AppProvider>
          {children}
          <TabBar />
        </AppProvider>
      </body>
    </html>
  );
}
