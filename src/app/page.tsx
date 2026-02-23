"use client";

import { Info, ArrowUpRight, ArrowDownRight, Activity, Users, MapPin, TrendingUp } from "lucide-react";

export default function DashboardPage() {
  const stats = [
    { label: "إجمالي الحجوزات", value: "1,284", change: "+14%", icon: Activity, trend: "up" },
    { label: "المستخدمين الجدد", value: "342", change: "+8%", icon: Users, trend: "up" },
    { label: "أكثر المحطات طلباً", value: "بوابة ١", change: "شروق", icon: MapPin, trend: "info" },
    { label: "معدل الإيرادات", value: "482.5 د.ك", change: "-2%", icon: TrendingUp, trend: "down" },
  ];

  return (
    <div className="space-y-10 animate-fade-up">
      <div className="flex items-end justify-between">
        <div>
          <h2 className="text-3xl font-black italic">نظرة عامة</h2>
          <p className="text-[10px] text-text-dim uppercase tracking-widest mt-1">Operational Analytics & System Health</p>
        </div>
        <button className="btn-swiss">توليد تقرير</button>
      </div>

      <div className="grid grid-cols-4 gap-4">
        {stats.map((stat, i) => (
          <div key={i} className="glass-card p-6 flex flex-col justify-between h-44">
            <div className="flex items-start justify-between">
              <div className="w-10 h-10 bg-white/5 border border-white/5 flex items-center justify-center">
                <stat.icon size={20} className="text-primary-gold" />
              </div>
              <div className={`flex items-center gap-1 text-[10px] font-black ${stat.trend === 'up' ? 'text-state-success' :
                stat.trend === 'down' ? 'text-state-error' : 'text-state-info'
                }`}>
                {stat.change}
                {stat.trend === 'up' ? <ArrowUpRight size={12} /> :
                  stat.trend === 'down' ? <ArrowDownRight size={12} /> : <Info size={12} />}
              </div>
            </div>
            <div>
              <p className="text-[10px] font-black uppercase text-text-dim tracking-wider">{stat.label}</p>
              <h3 className="text-2xl font-black mt-1 leading-none">{stat.value}</h3>
            </div>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-3 gap-8 pt-6">
        <div className="col-span-2 glass-card p-8 min-h-[400px]">
          <div className="flex items-center justify-between mb-8">
            <h4 className="text-sm">نشاط الرحلات الأخير</h4>
            <div className="flex gap-2 text-[8px] font-bold uppercase text-text-dim">
              <span className="flex items-center gap-1"><div className="w-2 h-2 bg-state-success" /> مكتملة</span>
              <span className="flex items-center gap-1"><div className="w-2 h-2 bg-primary-gold" /> قيد المراجعة</span>
            </div>
          </div>

          <div className="space-y-6">
            {[1, 2, 3, 4].map((i) => (
              <div key={i} className="flex items-center justify-between py-4 border-b border-white/5 last:border-0 hover:bg-white/[0.02] transition-colors -mx-4 px-4">
                <div className="flex items-center gap-4">
                  <div className="w-12 h-12 bg-surface-dark flex items-center justify-center font-black">M{i}</div>
                  <div>
                    <p className="text-xs font-black uppercase">رحلة الشروق - جامعة المستقبل</p>
                    <p className="text-[9px] text-text-dim uppercase tracking-tighter">ID: TX-9428-A0{i}</p>
                  </div>
                </div>
                <div className="text-left">
                  <p className="text-xs font-black uppercase text-state-success">مكتملة</p>
                  <p className="text-[9px] text-text-dim uppercase">منذ ١٥ دقيقة</p>
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className="glass-card p-8 flex flex-col justify-between">
          <div>
            <h4 className="text-sm mb-6">الحالة التشغيلية</h4>
            <div className="space-y-8">
              <div>
                <div className="flex justify-between text-[10px] mb-2 uppercase font-bold text-text-dim">
                  <span>سعة الأسطول</span>
                  <span className="text-text-main">٨٤٪</span>
                </div>
                <div className="h-[2px] w-full bg-white/5 relative overflow-hidden">
                  <div className="absolute top-0 left-0 h-full bg-primary-gold w-[84%]" />
                </div>
              </div>
              <div>
                <div className="flex justify-between text-[10px] mb-2 uppercase font-bold text-text-dim">
                  <span>التزام المواعيد</span>
                  <span className="text-text-main">٩٦٪</span>
                </div>
                <div className="h-[2px] w-full bg-white/5 relative overflow-hidden">
                  <div className="absolute top-0 left-0 h-full bg-state-success w-[96%]" />
                </div>
              </div>
            </div>
          </div>

          <div className="p-6 bg-white/5 text-center">
            <h5 className="text-[10px] text-primary-gold mb-2">تحديث النظام التالي</h5>
            <p className="text-xs font-black uppercase">٢٤ ساعة القادمة</p>
          </div>
        </div>
      </div>
    </div>
  );
}
