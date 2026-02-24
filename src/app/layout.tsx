import type { Metadata } from "next";
import { Cairo } from "next/font/google";
import "./globals.css";
import { DashboardLayout } from "@/components/layout/dashboard-layout";

const cairo = Cairo({
  variable: "--font-cairo",
  subsets: ["latin", "arabic"],
  weight: ["300", "400", "500", "600", "700", "800", "900"],
});


export const metadata: Metadata = {
  title: "FI EL SEKKA Dashboard",
  description: "Swiss Clean Admin Portal",
};

import { Toaster } from "sileo";

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ar" dir="rtl" className={`${cairo.variable}`}>
      <body className="antialiased font-body">
        <Toaster
          position="top-center"
          theme="dark"
          options={{
            styles: {
              description: "text-[12px] font-medium w-full mt-0.5",
              title: "font-bold"
            }
          }}
        />
        <DashboardLayout>
          {children}
        </DashboardLayout>
      </body>
    </html>
  );
}
