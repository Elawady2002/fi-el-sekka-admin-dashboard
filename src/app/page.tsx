"use client";

import { Users, CreditCard, BookOpen, Wallet, Calendar, RefreshCcw, ChevronRight, Plus, CheckCircle, XCircle } from "lucide-react";
import { useState } from "react";
import { cn } from "@/lib/utils";

export default function DashboardPage() {
  const userName = "احمد رضا";
  const [selectedDate, setSelectedDate] = useState(new Date());

  const stats = [
    { label: "المستخدمين", value: "1,248", icon: Users, color: "#3B82F6" },
    { label: "المشتركين النشطين", value: "856", icon: CreditCard, color: "#3ECF8E" },
    { label: "إجمالي الحجوزات", value: "12,450", icon: BookOpen, color: "#0EA5E9" },
    { label: "الإيرادات الشهرية", value: "٤٢,٥٠٠ ج.م", icon: Wallet, color: "#DAAE5D" },
  ];

  const pendingActions = [
    { id: 1, name: "محمد علي", detail: "اشتراك شهري - ٤٥٠ ج.م", time: "منذ ١٥ دقيقة" },
    { id: 2, name: "سارة محمود", detail: "اشتراك فصل دراسي - ١,٢٠٠ ج.م", time: "منذ ٤٥ دقيقة" },
    { id: 3, name: "ياسين حسن", detail: "اشتراك شهري - ٤٥٠ ج.م", time: "منذ ٢ ساعة" },
  ];

  return (
    <div className="p-6 space-y-8">
      {/* Welcome Header */}
      <div className="flex items-center justify-between">
        <div className="space-y-1">
          <h1 className="text-2xl font-bold text-text-primary">
            صباح الخير، {userName}! 👋
          </h1>
          <p className="text-sm text-text-secondary">
            نظرة عامة على نظام في السكة
          </p>
        </div>

        {/* Date Filter */}
        <button className="flex items-center gap-2 px-3.5 py-2 bg-surface-dark border border-border-dark rounded-xl text-sm font-medium hover:border-primary-green/50 hover:bg-primary-green/5 transition-all text-text-secondary hover:text-primary-green">
          <Calendar size={16} />
          <span>{selectedDate.toLocaleDateString('ar-EG')}</span>
        </button>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        {stats.map((stat, i) => (
          <div key={i} className="group card p-4 flex flex-col gap-3.5 hover:border-primary-green/30 hover:bg-primary-green/4 transition-all cursor-pointer shadow-lg shadow-black/5">
            <div className="flex items-center justify-between">
              <div
                className="w-10 h-10 rounded-xl flex items-center justify-center"
                style={{ backgroundColor: `${stat.color}1F` }}
              >
                <stat.icon size={20} style={{ color: stat.color }} />
              </div>
              <ChevronRight size={14} className="text-primary-green opacity-0 group-hover:opacity-100 transition-opacity translate-x-1" />
            </div>
            <div className="space-y-0.5">
              <div className="text-xl font-bold text-text-primary">{stat.value}</div>
              <div className="text-[11px] text-text-secondary">{stat.label}</div>
            </div>
          </div>
        ))}
      </div>

      {/* Pending Actions Section */}
      <div className="space-y-4">
        <div className="card">
          {pendingActions.map((action, i) => (
            <div key={action.id} className={cn(
              "flex items-center gap-4 p-4 hover:bg-white/2 transition-colors",
              i !== pendingActions.length - 1 && "border-b border-border-dark"
            )}>
              <div className="w-11 h-11 rounded-xl bg-accent-orange/10 flex items-center justify-center text-accent-orange">
                <CreditCard size={22} />
              </div>

              <div className="flex-1 flex flex-col gap-0.5">
                <div className="flex items-center justify-between">
                  <span className="text-sm font-semibold">{action.name}</span>
                  <span className="text-[10px] text-text-secondary">{action.time}</span>
                </div>
                <span className="text-xs text-text-secondary">{action.detail}</span>
              </div>

              <div className="flex items-center gap-2">
                <button className="w-9 h-9 rounded-lg bg-accent-green/10 text-accent-green flex items-center justify-center hover:bg-accent-green hover:text-white transition-all">
                  <CheckCircle size={18} />
                </button>
                <button className="w-9 h-9 rounded-lg bg-accent-red/10 text-accent-red flex items-center justify-center hover:bg-accent-red hover:text-white transition-all">
                  <XCircle size={18} />
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* City Passenger Section */}
      <div className="space-y-4 pt-4">
        <div className="flex items-center justify-between">
          <div />
          <button className="flex items-center gap-1 text-sm text-primary-green hover:underline">
            <RefreshCcw size={14} />
            <span>تحديث</span>
          </button>
        </div>

        <CityGroup
          name="المنصورة"
          count={145}
          stations={[
            { name: "محطة الجامعة", uni: "جامعة المنصورة", passengers: 85 },
            { name: "محطة الجيش", uni: "جامعة حورس", passengers: 60 }
          ]}
        />

        <CityGroup
          name="دمياط"
          count={92}
          stations={[
            { name: "ميدان الساعة", uni: "جامعة دمياط", passengers: 92 }
          ]}
        />
      </div>
    </div>
  );
}

function CityGroup({ name, count, stations }: any) {
  const [expanded, setExpanded] = useState(true);

  return (
    <div className="card">
      <div
        onClick={() => setExpanded(!expanded)}
        className="flex items-center gap-3 p-4 bg-primary-green/8 cursor-pointer"
      >
        <ChevronRight size={24} className={cn("text-primary-green transition-transform", expanded && "rotate-90")} />
        <div className="w-1 h-6 bg-primary-green rounded-full" />
        <span className="text-base font-bold text-primary-green">{name}</span>
        <div className="px-2.5 py-1 bg-primary-green text-black text-[11px] font-bold rounded-full">
          {count} راكب
        </div>
        <div className="flex-1" />
        <button className="w-8 h-8 flex items-center justify-center text-primary-green hover:bg-primary-green/10 rounded-full">
          <Plus size={20} />
        </button>
      </div>

      {expanded && (
        <div className="overflow-x-auto">
          <table className="w-full text-right text-sm">
            <thead className="bg-[#1a1a1a] text-text-secondary border-b border-border-dark">
              <tr>
                <th className="p-4 font-semibold text-xs">المحطة</th>
                <th className="p-4 font-semibold text-xs">الجامعة</th>
                <th className="p-4 font-semibold text-xs">عدد الركاب</th>
              </tr>
            </thead>
            <tbody>
              {stations.map((station: any, i: number) => (
                <tr key={i} className="border-b border-border-dark last:border-0 hover:bg-white/1">
                  <td className="p-4 font-medium">{station.name}</td>
                  <td className="p-4 text-text-secondary">{station.uni}</td>
                  <td className="p-4 font-bold text-primary-green">{station.passengers}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
