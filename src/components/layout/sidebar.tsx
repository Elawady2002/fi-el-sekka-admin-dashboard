"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { LayoutDashboard, Target, Users, Settings, LogOut, Banknote } from "lucide-react";
import { cn } from "@/lib/utils";

const menuItems = [
    { label: "نظرة عامة", href: "/", icon: LayoutDashboard },
    { label: "من موقف لموقف", href: "/point-to-point", icon: Target },
    { label: "المستخدمين", href: "/users", icon: Users },
    { label: "المحفظة", href: "/wallet", icon: Banknote },
    { label: "الإعدادات", href: "/settings", icon: Settings },
];

export function Sidebar() {
    const pathname = usePathname();

    return (
        <aside className="w-72 h-screen bg-surface-dark border-l border-border-subtle flex flex-col sticky top-0">
            <div className="p-8 border-b border-border-subtle">
                <h1 className="text-xl font-black text-primary-gold italic">FI EL SEKKA</h1>
                <p className="text-[10px] text-text-dim tracking-[0.2em] font-display uppercase">Admin Portal</p>
            </div>

            <nav className="flex-1 py-6">
                {menuItems.map((item) => {
                    const isActive = pathname === item.href;
                    return (
                        <Link
                            key={item.href}
                            href={item.href}
                            className={cn(
                                "nav-link",
                                isActive && "active"
                            )}
                        >
                            <item.icon size={18} />
                            <span className="text-xs font-black uppercase tracking-wider">{item.label}</span>
                            {isActive && (
                                <div className="absolute left-0 w-1 h-full bg-primary-gold animate-fade-in" />
                            )}
                        </Link>
                    );
                })}
            </nav>

            <div className="p-6 border-t border-border-subtle">
                <button className="flex items-center gap-3 text-state-error/70 hover:text-state-error transition-colors w-full px-4 py-2">
                    <LogOut size={18} />
                    <span className="text-[10px] font-black uppercase">تسجيل الخروج</span>
                </button>
            </div>
        </aside>
    );
}
