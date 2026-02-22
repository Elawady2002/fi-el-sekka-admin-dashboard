"use client";

import { Rocket } from "lucide-react";

export default function DashboardPage() {
  return (
    <div className="p-6 flex flex-col items-center justify-center min-h-[80vh] text-right space-y-6">
      <div className="w-24 h-24 bg-primary-green/10 rounded-3xl flex items-center justify-center text-primary-green animate-bounce">
        <Rocket size={48} />
      </div>
      <div className="space-y-2 text-center">
        <h1 className="text-4xl font-black text-white">البداية من الصفر 🚀</h1>
        <p className="text-text-secondary text-lg max-w-md mx-auto">
          تم تصفير لوحة التحكم بنجاح. المشروع الآن جاهز لاستقبال تصميماتك وميزاتك الجديدة بأساس نظيف.
        </p>
      </div>
      <div className="flex gap-4">
        <div className="px-6 py-3 bg-surface-dark border border-border-dark rounded-2xl text-text-primary text-sm font-bold">
          نظام نظيف
        </div>
        <div className="px-6 py-3 bg-surface-dark border border-border-dark rounded-2xl text-text-primary text-sm font-bold">
          جاهز للتطوير
        </div>
      </div>
    </div>
  );
}
