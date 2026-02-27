"use client";

import { useState } from "react";
import { Ticket, GraduationCap, Target } from "lucide-react";
import { cn } from "@/lib/utils";

// Mock data for point-to-point bookings
const MOCK_P2P_BOOKINGS = [
    { id: "BKG-9428", user: "أحمد محمد", from: "التجمع الخامس", to: "جامعة المستقبل", date: "2024-03-20 08:30", status: "مكتملة", price: 25 },
    { id: "BKG-9429", user: "سارة خالد", from: "المعادي", to: "القرية الذكية", date: "2024-03-20 09:00", status: "قيد المراجعة", price: 35 },
    { id: "BKG-9430", user: "عمر عبدالله", from: "الشروق", to: "الرحاب", date: "2024-03-21 10:15", status: "مؤكدة", price: 20 },
];

// Mock data for university subscriptions
const MOCK_UNI_SUBSCRIPTIONS = [
    { id: "SUB-101", user: "كريم سامي", university: "الجامعة الألمانية بالكاھرة (GUC)", plan: "فصل دراسي كامل", startDate: "2024-02-15", status: "نشط", price: 4500 },
    { id: "SUB-102", user: "نور علي", university: "جامعة بدر (BUC)", plan: "شهري", startDate: "2024-03-01", status: "نشط", price: 1200 },
    { id: "SUB-103", user: "يوسف حسن", university: "الجامعة الكندية (CIC)", plan: "سنوي", startDate: "2023-09-01", status: "منتهي", price: 8000 },
];

export default function BookingsPage() {
    const [activeTab, setActiveTab] = useState<'p2p' | 'university'>('p2p');

    return (
        <div className="space-y-8 animate-fade-up h-[calc(100vh-8rem)] flex flex-col">
            {/* Header */}
            <div className="flex items-end justify-between shrink-0">
                <div>
                    <h2 className="text-3xl font-black italic mb-2">سجل الحجوزات</h2>
                    <p className="text-[10px] text-text-dim uppercase tracking-widest">
                        Bookings & Subscriptions Management
                    </p>
                </div>
            </div>

            {/* Tabs */}
            <div className="flex gap-4 border-b border-white/5 pb-4 shrink-0">
                <button
                    onClick={() => setActiveTab('p2p')}
                    className={cn(
                        "flex items-center gap-2 px-6 py-3 font-black text-xs uppercase tracking-widest transition-all",
                        activeTab === 'p2p'
                            ? "bg-primary-gold text-bg-black"
                            : "bg-surface-dark text-text-dim hover:text-text-main border border-white/5"
                    )}
                >
                    <Target size={16} />
                    من موقف لموقف
                </button>
                <button
                    onClick={() => setActiveTab('university')}
                    className={cn(
                        "flex items-center gap-2 px-6 py-3 font-black text-xs uppercase tracking-widest transition-all",
                        activeTab === 'university'
                            ? "bg-primary-gold text-bg-black"
                            : "bg-surface-dark text-text-dim hover:text-text-main border border-white/5"
                    )}
                >
                    <GraduationCap size={16} />
                    اشتراكات الجامعات
                </button>
            </div>

            {/* Content Area */}
            <div className="flex-1 min-h-0 bg-surface-dark border border-white/5 p-6 overflow-hidden flex flex-col">
                {activeTab === 'p2p' ? (
                    <div className="flex flex-col h-full space-y-6">
                        <div className="flex items-center justify-between shrink-0">
                            <h3 className="font-black text-lg flex items-center gap-2">
                                <Target size={18} className="text-primary-gold" />
                                حجوزات الرحلات الفردية
                            </h3>
                        </div>

                        <div className="overflow-x-auto flex-1 border border-white/5 rounded-sm">
                            <table className="w-full text-right text-sm">
                                <thead className="text-[10px] uppercase font-black text-text-dim bg-black/40 border-b border-white/5 tracking-widest leading-none">
                                    <tr>
                                        <th className="px-6 py-4">رقم الحجز</th>
                                        <th className="px-6 py-4">المستخدم</th>
                                        <th className="px-6 py-4">من</th>
                                        <th className="px-6 py-4">إلى</th>
                                        <th className="px-6 py-4">التاريخ والوقت</th>
                                        <th className="px-6 py-4">المبلغ</th>
                                        <th className="px-6 py-4">الحالة</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {MOCK_P2P_BOOKINGS.map((booking) => (
                                        <tr key={booking.id} className="border-b border-white/5 hover:bg-white/2 transition-colors">
                                            <td className="px-6 py-4 font-mono text-xs">{booking.id}</td>
                                            <td className="px-6 py-4 font-bold">{booking.user}</td>
                                            <td className="px-6 py-4">{booking.from}</td>
                                            <td className="px-6 py-4">{booking.to}</td>
                                            <td className="px-6 py-4 text-xs font-mono">{booking.date}</td>
                                            <td className="px-6 py-4 font-black">{booking.price} EGP</td>
                                            <td className="px-6 py-4">
                                                <span className={cn(
                                                    "px-3 py-1 text-[10px] uppercase font-black tracking-wider",
                                                    booking.status === "مكتملة" ? "bg-state-success/10 text-state-success border border-state-success/20" :
                                                        booking.status === "مؤكدة" ? "bg-state-info/10 text-state-info border border-state-info/20" :
                                                            "bg-primary-gold/10 text-primary-gold border border-primary-gold/20"
                                                )}>
                                                    {booking.status}
                                                </span>
                                            </td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        </div>
                    </div>
                ) : (
                    <div className="flex flex-col h-full space-y-6">
                        <div className="flex items-center justify-between shrink-0">
                            <h3 className="font-black text-lg flex items-center gap-2">
                                <GraduationCap size={18} className="text-primary-gold" />
                                اشتراكات الجامعات
                            </h3>
                        </div>

                        <div className="overflow-x-auto flex-1 border border-white/5 rounded-sm">
                            <table className="w-full text-right text-sm">
                                <thead className="text-[10px] uppercase font-black text-text-dim bg-black/40 border-b border-white/5 tracking-widest leading-none">
                                    <tr>
                                        <th className="px-6 py-4">رقم الاشتراك</th>
                                        <th className="px-6 py-4">الطالب</th>
                                        <th className="px-6 py-4">الجامعة</th>
                                        <th className="px-6 py-4">خطة الاشتراك</th>
                                        <th className="px-6 py-4">تاريخ البدء</th>
                                        <th className="px-6 py-4">المبلغ</th>
                                        <th className="px-6 py-4">الحالة</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {MOCK_UNI_SUBSCRIPTIONS.map((sub) => (
                                        <tr key={sub.id} className="border-b border-white/5 hover:bg-white/2 transition-colors">
                                            <td className="px-6 py-4 font-mono text-xs">{sub.id}</td>
                                            <td className="px-6 py-4 font-bold">{sub.user}</td>
                                            <td className="px-6 py-4">{sub.university}</td>
                                            <td className="px-6 py-4 font-bold text-primary-gold">{sub.plan}</td>
                                            <td className="px-6 py-4 text-xs font-mono">{sub.startDate}</td>
                                            <td className="px-6 py-4 font-black">{sub.price} EGP</td>
                                            <td className="px-6 py-4">
                                                <span className={cn(
                                                    "px-3 py-1 text-[10px] uppercase font-black tracking-wider",
                                                    sub.status === "نشط" ? "bg-state-success/10 text-state-success border border-state-success/20" :
                                                        "bg-state-error/10 text-state-error border border-state-error/20"
                                                )}>
                                                    {sub.status}
                                                </span>
                                            </td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        </div>
                    </div>
                )}
            </div>
        </div>
    );
}
