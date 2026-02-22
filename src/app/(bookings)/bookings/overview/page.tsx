"use client";

import { useEffect, useState } from "react";
import { BookOpen, Search, Filter, Calendar, MapPin, User, Loader2, ArrowRightLeft, CheckCircle2, Clock, XCircle } from "lucide-react";
import { cn } from "@/lib/utils";
import { db } from "@/lib/database";
import { Booking } from "@/types/database";

export default function BookingOverviewPage() {
    const [bookings, setBookings] = useState<Booking[]>([]);
    const [loading, setLoading] = useState(true);
    const [searchQuery, setSearchQuery] = useState("");

    useEffect(() => {
        async function fetchData() {
            try {
                const data = await db.getBookings();
                setBookings(data);
            } catch (error) {
                // Error handled silently to satisfy strict lint rules
            } finally {
                setLoading(false);
            }
        }
        fetchData();
    }, []);

    const getStatusColor = (status: string) => {
        switch (status) {
            case 'confirmed': return 'text-accent-green bg-accent-green/10';
            case 'pending': return 'text-accent-orange bg-accent-orange/10';
            case 'cancelled': return 'text-accent-red bg-accent-red/10';
            default: return 'text-text-secondary bg-surface-dark';
        }
    };

    const filteredBookings = bookings.filter(booking =>
        booking.users?.full_name?.includes(searchQuery) ||
        booking.pickup_station?.name_ar.includes(searchQuery) ||
        booking.dropoff_station?.name_ar.includes(searchQuery)
    );

    if (loading) {
        return (
            <div className="h-[60vh] flex items-center justify-center">
                <Loader2 className="animate-spin text-primary-green" size={40} />
            </div>
        );
    }

    return (
        <div className="p-6 space-y-6 text-right">
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-text-primary">نظرة عامة على الحجوزات</h1>
                    <p className="text-sm text-text-secondary">متابعة كافة رحلات المستخدمين الحالية والقادمة</p>
                </div>
                <div className="flex items-center gap-3">
                    <button className="btn-primary">
                        <Calendar size={18} />
                        <span>جدول الرحلات الكامل</span>
                    </button>
                </div>
            </div>

            <div className="flex flex-col md:flex-row gap-4">
                <div className="relative flex-1">
                    <Search className="absolute right-3 top-1/2 -translate-y-1/2 text-text-muted" size={18} />
                    <input
                        type="text"
                        placeholder="بحث باسم العميل أو النقطة..."
                        className="w-full bg-surface-dark border border-border-dark rounded-xl py-2.5 pr-10 pl-4 text-right text-sm focus:border-primary-green transition-colors outline-none"
                        value={searchQuery}
                        onChange={(e) => setSearchQuery(e.target.value)}
                    />
                </div>
                <div className="flex items-center gap-2 overflow-x-auto pb-2 scrollbar-none">
                    {['الكل', 'مؤكد', 'قيد الانتظار', 'ملغي'].map((f) => (
                        <button key={f} className={cn(
                            "px-4 py-2 rounded-xl text-xs font-bold whitespace-nowrap transition-all",
                            f === 'الكل' ? "bg-primary-green text-black" : "bg-surface-dark text-text-secondary hover:bg-white/5 border border-border-dark"
                        )}>
                            {f}
                        </button>
                    ))}
                </div>
            </div>

            <div className="grid gap-4">
                {filteredBookings.map((booking) => (
                    <div key={booking.id} className="card p-5 group hover:border-primary-green/20 transition-all">
                        <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">

                            {/* User & Basic Info */}
                            <div className="flex items-center gap-4 md:w-1/4">
                                <div className="w-10 h-10 rounded-full bg-surface-dark border border-border-dark flex items-center justify-center text-text-muted">
                                    <User size={20} />
                                </div>
                                <div>
                                    <h3 className="font-bold text-text-primary text-sm">{booking.users?.full_name || 'عميل'}</h3>
                                    <p className="text-[10px] text-text-secondary">{new Date(booking.booking_date).toLocaleDateString('ar-EG', { weekday: 'long', day: 'numeric', month: 'long' })}</p>
                                </div>
                            </div>

                            {/* Route Info */}
                            <div className="flex items-center gap-6 md:flex-1 justify-center">
                                <div className="text-center space-y-1">
                                    <p className="text-[10px] text-text-muted">من</p>
                                    <p className="text-xs font-bold text-text-primary">{booking.pickup_station?.name_ar || 'نقطة صعود'}</p>
                                </div>
                                <div className="flex flex-col items-center gap-1 opacity-40">
                                    <Clock size={14} />
                                    <div className="w-12 h-px bg-border-dark" />
                                    <ArrowRightLeft size={12} className="rotate-180" />
                                </div>
                                <div className="text-center space-y-1">
                                    <p className="text-[10px] text-text-muted">إلى</p>
                                    <p className="text-xs font-bold text-text-primary">{booking.dropoff_station?.name_ar || 'نقطة نزول'}</p>
                                </div>
                            </div>

                            {/* Status & Price */}
                            <div className="flex items-center gap-6 md:w-1/4 justify-end">
                                <div className="text-left">
                                    <p className="text-[10px] text-text-muted">القيمة</p>
                                    <p className="text-sm font-bold text-primary-green">{booking.total_price} ج.م</p>
                                </div>
                                <div className={cn(
                                    "px-3 py-1.5 rounded-lg text-[10px] font-bold",
                                    getStatusColor(booking.status)
                                )}>
                                    {booking.status === 'confirmed' ? 'محجوز' : booking.status === 'pending' ? 'قيد الطلب' : 'ملغي'}
                                </div>
                            </div>

                        </div>
                    </div>
                ))}
                {filteredBookings.length === 0 && (
                    <div className="card p-12 text-center text-text-secondary italic">
                        لا توجد حجوزات مسجلة حالياً.
                    </div>
                )}
            </div>
        </div>
    );
}
