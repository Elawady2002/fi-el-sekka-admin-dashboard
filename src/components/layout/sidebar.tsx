"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import {
    LayoutDashboard,
    Users,
    CreditCard,
    Bus,
    CalendarCheck,
    MapPin,
    CreditCard as PaymentIcon,
    LogOut,
    ChevronRight
} from "lucide-react";
import { cn } from "@/lib/utils";

const navGroups = [
    {
        title: "عام",
        items: [
            { label: "الرئيسية", href: "/", icon: LayoutDashboard },
            { label: "المستخدمين", href: "/users", icon: Users },
        ],
    },
    {
        title: "العمليات",
        items: [
            { label: "الاشتراكات", href: "/subscriptions", icon: CreditCard },
            { label: "الرحلات", href: "/trips", icon: Bus },
            { label: "الحجوزات", href: "/bookings", icon: CalendarCheck },
        ],
    },
    {
        title: "الإعدادات",
        items: [
            { label: "المواقع والمسارات", href: "/routes-locations", icon: MapPin },
            { label: "المدفوعات", href: "/payments", icon: PaymentIcon },
        ],
    },
];

export function Sidebar() {
    const pathname = usePathname();

    return (
        <aside className="w-64 h-screen bg-surface-dark border-l border-border-dark/50 flex flex-col sticky top-0 z-50 overflow-hidden">
            {/* Logo Section */}
            <div className="p-5 flex items-center gap-3.5 border-b border-border-dark/50">
                <div className="w-12 h-12 flex items-center justify-center text-text-primary">
                    {/* Replace with actual logo if available */}
                    <Bus size={40} className="text-primary-green" />
                </div>
                <div className="flex flex-col">
                    <span className="text-xl font-bold text-text-primary">في السكة</span>
                    <span className="text-xs text-text-secondary">لوحة التحكم</span>
                </div>
            </div>

            {/* Navigation */}
            <nav className="flex-1 p-4 space-y-6 overflow-y-auto">
                {navGroups.map((group) => (
                    <div key={group.title} className="space-y-1.5 text-right">
                        {/* Group Label removed in Flutter code as children mapping was direct, but FIFA style often has titles */}
                        {group.items.map((item) => {
                            const isActive = pathname === item.href;
                            return (
                                <Link
                                    key={item.href}
                                    href={item.href}
                                    className={cn(
                                        "flex items-center gap-3 px-3.5 py-3 rounded-xl transition-all relative group",
                                        isActive
                                            ? "bg-primary-green text-black"
                                            : "text-text-secondary hover:text-text-primary hover:bg-primary-green/10"
                                    )}
                                >
                                    <item.icon size={20} className={cn(
                                        isActive ? "text-black" : "group-hover:text-primary-green text-text-secondary"
                                    )} />
                                    <span className={cn(
                                        "text-sm font-medium flex-1",
                                        isActive ? "font-bold" : "font-medium"
                                    )}>
                                        {item.label}
                                    </span>
                                    {isActive && (
                                        <div className="w-1.5 h-1.5 bg-black rounded-full" />
                                    )}
                                </Link>
                            );
                        })}
                    </div>
                ))}
            </nav>

            {/* User Info Section */}
            <div className="p-4 border-t border-border-dark/50 flex items-center gap-3">
                <div className="w-11 h-11 rounded-xl bg-linear-to-br from-primary-green to-accent-purple flex items-center justify-center text-white font-bold text-lg">
                    A
                </div>
                <div className="flex-1 flex flex-col">
                    <span className="text-sm font-semibold text-text-primary truncate">احمد رضا</span>
                    <span className="text-xs text-text-secondary">مدير النظام</span>
                </div>
                <button className="w-10 h-10 flex items-center justify-center rounded-lg hover:bg-accent-red/10 text-text-secondary hover:text-accent-red transition-colors">
                    <LogOut size={20} />
                </button>
            </div>
        </aside>
    );
}
