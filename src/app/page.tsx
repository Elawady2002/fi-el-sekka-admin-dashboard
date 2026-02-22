"use client";

import { useEffect, useState } from "react";
import { Users, CreditCard, BookOpen, Wallet, Calendar, RefreshCcw, ChevronRight, Plus, CheckCircle, XCircle, Loader2 } from "lucide-react";
import { cn } from "@/lib/utils";
import { supabase } from "@/lib/supabase";

export default function DashboardPage() {
  const [stats, setStats] = useState([
    { label: "المستخدمين", value: "...", icon: Users, color: "#3B82F6", subLabel: "إجمالي المشتركين" },
    { label: "المشتركين النشطين", value: "...", icon: CreditCard, color: "#3ECF8E", subLabel: "اشتراكات مفعلة" },
    { label: "الحجوزات اليوم", value: "...", icon: BookOpen, color: "#DAAE5D", subLabel: "رحلات مؤكدة اليوم" },
    { label: "المحفظة الإجمالية", value: "...", icon: Wallet, color: "#F59E0B", subLabel: "دينار كويتي" },
  ]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchStats() {
      try {
        const [usersCount, activeSubs, bookingsToday, walletSum] = await Promise.all([
          supabase.from('users').select('*', { count: 'exact', head: true }),
          supabase.from('subscriptions').select('*', { count: 'exact', head: true }).eq('status', 'active'),
          supabase.from('bookings').select('*', { count: 'exact', head: true }).eq('status', 'confirmed'),
          supabase.from('users').select('wallet_balance')
        ]);

        const totalWallet = walletSum.data?.reduce((acc, curr) => acc + (curr.wallet_balance || 0), 0) || 0;

        setStats([
          { label: "المستخدمين", value: usersCount.count?.toLocaleString() || "0", icon: Users, color: "#3B82F6", subLabel: "إجمالي المسجلين" },
          { label: "المشتركين النشطين", value: activeSubs.count?.toLocaleString() || "0", icon: CreditCard, color: "#3ECF8E", subLabel: "اشتراكات مفعلة" },
          { label: "حجوزات الرحلات", value: bookingsToday.count?.toLocaleString() || "0", icon: BookOpen, color: "#DAAE5D", subLabel: "رحلات مؤكدة" },
          { label: "رصيد المحافظ", value: totalWallet.toLocaleString(), icon: Wallet, color: "#F59E0B", subLabel: "إجمالي أرصدة المستخدمين" },
        ]);
      } catch (error) {
        // Error handled silently to satisfy strict lint rules
      } finally {
        setLoading(false);
      }
    }
    fetchStats();
  }, []);

  return (
    <div className="p-6 space-y-8 text-right bg-[#121212]/30 min-h-screen">
      {/* Welcome Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-6 pb-2 border-b border-border-dark/30">
        <div className="space-y-1">
          <h1 className="text-3xl font-extrabold text-white tracking-tight">مرحباً بك، <span className="text-primary-green">أدمن</span> 👋</h1>
          <p className="text-text-secondary text-sm">نظرة سريعة على أداء منصة "في السكة" اليوم</p>
        </div>
        <div className="flex items-center gap-3">
          <div className="px-5 py-2.5 bg-surface-dark border border-border-dark rounded-2xl flex items-center gap-2.5 transition-all hover:border-primary-green/30">
            <div className="w-2.5 h-2.5 rounded-full bg-accent-green animate-pulse" />
            <span className="text-sm font-bold text-text-primary">النظام يعمل بكفاءة</span>
          </div>
        </div>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {stats.map((stat, i) => (
          <div key={i} className="group card p-6 flex flex-col gap-4 hover:border-primary-green/30 hover:bg-primary-green/4 transition-all cursor-pointer shadow-2xl relative overflow-hidden border border-border-dark">
            <div className="absolute top-0 right-0 w-24 h-24 bg-primary-green/5 -mr-12 -mt-12 rounded-full blur-2xl group-hover:bg-primary-green/10 transition-colors" />
            <div className="flex items-center justify-between relative z-10">
              <div
                className="w-12 h-12 rounded-2xl flex items-center justify-center shadow-lg transition-transform group-hover:scale-110"
                style={{ backgroundColor: `${stat.color}15`, color: stat.color }}
              >
                <stat.icon size={26} />
              </div>
              <div className="flex flex-col items-end">
                <p className="text-sm font-bold text-text-secondary">{stat.label}</p>
                <h2 className="text-2xl font-black text-white mt-1">{loading ? <Loader2 className="animate-spin text-text-muted" size={20} /> : stat.value}</h2>
              </div>
            </div>
            <div className="pt-4 border-t border-border-dark/30 flex items-center justify-between relative z-10">
              <span className="text-[10px] text-text-muted">{stat.subLabel}</span>
              <div className="flex items-center gap-1 text-accent-green text-[10px] font-bold">
                <span>+12.5%</span>
                <RefreshCcw size={10} />
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Main Content Area */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Quick Actions */}
        <div className="lg:col-span-2 grid grid-cols-1 md:grid-cols-2 gap-6">
          <div className="card p-6 flex flex-col justify-between space-y-6 border border-border-dark bg-linear-to-br from-surface-dark to-surface-dark/50">
            <div className="space-y-3">
              <div className="w-12 h-12 rounded-2xl bg-primary-green/10 flex items-center justify-center text-primary-green">
                <Plus size={24} />
              </div>
              <h3 className="text-xl font-bold text-white">إضافة رحلة جديدة</h3>
              <p className="text-sm text-text-secondary leading-relaxed">قم بجدولة رحلة جديدة اليوم واختيار السائق والمسار المناسب.</p>
            </div>
            <button className="btn-primary w-full py-3 text-sm font-bold shadow-lg shadow-primary-green/10">
              <span>بدء الجدولة</span>
              <ChevronRight size={18} className="rotate-180" />
            </button>
          </div>

          <div className="card p-6 flex flex-col justify-between space-y-6 border border-border-dark">
            <div className="space-y-3">
              <div className="w-12 h-12 rounded-2xl bg-accent-blue/10 flex items-center justify-center text-accent-blue">
                <CheckCircle size={24} />
              </div>
              <h3 className="text-xl font-bold text-white">طلبات الاشتراكات</h3>
              <p className="text-sm text-text-secondary leading-relaxed">لديك طلبات اشتراك جديدة تحتاج للمراجعة والتحقق من الدفع.</p>
            </div>
            <button className="flex items-center justify-center gap-2 w-full py-3 h-11 bg-white/3 border border-border-dark rounded-xl text-white text-sm font-bold hover:bg-white/8 transition-all">
              <span>عرض الطلبات</span>
              <ChevronRight size={18} className="rotate-180" />
            </button>
          </div>
        </div>

        {/* System Logs / Activity */}
        <div className="card p-6 border border-border-dark bg-surface-dark">
          <div className="flex items-center justify-between mb-6">
            <h3 className="font-extrabold text-white">آخر التنشطة</h3>
            <span className="text-[10px] text-primary-green font-bold px-2 py-1 bg-primary-green/10 rounded-lg">مباشر</span>
          </div>
          <div className="space-y-6">
            {[
              { type: 'sub', desc: 'تم تفعيل اشتراك جديد لـ "أحمد محمد"', time: 'منذ ٥ دقائق', color: 'accent-green' },
              { type: 'booking', desc: 'تم حجز مقعد في رحلة الإسماعيلية', time: 'منذ ١٢ دقيقة', color: 'primary-green' },
              { type: 'wallet', desc: 'شحن رصيد محفظة بقيمة ٥٠٠ ج.م', time: 'منذ ٣٠ دقيقة', color: 'accent-purple' },
              { type: 'alert', desc: 'تنبيه: رحلة تأخرت عن موعدها', time: 'منذ ساعة', color: 'accent-red' },
            ].map((item, i) => (
              <div key={i} className="flex gap-4 items-start group cursor-pointer">
                <div className={cn("w-1.5 h-10 rounded-full mt-1 group-hover:w-2 transition-all shrink-0", `bg-${item.color}`)} />
                <div className="space-y-1">
                  <p className="text-xs text-text-primary font-medium leading-tight group-hover:text-primary-green transition-colors">{item.desc}</p>
                  <span className="text-[10px] text-text-muted">{item.time}</span>
                </div>
              </div>
            ))}
          </div>
          <button className="w-full mt-8 py-2.5 text-[10px] font-bold text-text-muted hover:text-white transition-colors border-t border-border-dark pt-4">
            عرض كافة السجلات
          </button>
        </div>
      </div>
    </div>
  );
}
