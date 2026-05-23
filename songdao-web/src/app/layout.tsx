import type { Metadata, Viewport } from "next";
import { Inter, Noto_Serif } from "next/font/google";
import "./globals.css";

const inter = Inter({
  variable: "--font-inter",
  subsets: ["latin", "latin-ext", "vietnamese"],
  weight: ["300", "400", "500", "600", "700"],
  preload: false,
});

const notoSerif = Noto_Serif({
  variable: "--font-noto-serif",
  subsets: ["latin", "latin-ext", "vietnamese"],
  weight: ["400", "500", "600", "700"],
  preload: false,
});

export const metadata: Metadata = {
  title: "Sống Đạo - Nhịp sống đức tin mỗi ngày",
  description: "Sống Đạo giúp người Công giáo sống đức tin mỗi ngày thông qua một hành động cụ thể, ngữ cảnh phụng vụ, tham chiếu bài đọc và ghi chú cá nhân bảo mật.",
  manifest: "/manifest.json",
  appleWebApp: {
    capable: true,
    statusBarStyle: "default",
    title: "Sống Đạo",
  },
  formatDetection: {
    telephone: false,
  },
  openGraph: {
    type: "website",
    siteName: "Sống Đạo",
    title: "Sống Đạo - Nhịp sống đức tin mỗi ngày",
    description: "Sống Đạo giúp người Công giáo sống đức tin mỗi ngày thông qua một hành động cụ thể.",
  },
};

export const viewport: Viewport = {
  themeColor: "#FAF8F3",
  width: "device-width",
  initialScale: 1,
  maximumScale: 1,
  userScalable: false,
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="vi" className={`${inter.variable} ${notoSerif.variable} antialiased h-full`}>
      <body className="bg-canvas text-text-primary min-h-full flex flex-col font-sans">
        {children}
      </body>
    </html>
  );
}
