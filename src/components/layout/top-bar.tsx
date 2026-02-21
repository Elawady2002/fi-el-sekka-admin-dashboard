"use client";

import { Search, Bell, Settings as SettingsIcon } from "lucide-react";
import { usePathname } from "next/navigation";

export function TopBar() {
    const pathname = usePathname();

    const getPageTitle = (path: string) => {
        switch (path) {
            case '/': return 'الرئيسية';
            case '/users': return 'المستخدمين';
            case '/subscriptions': return 'الاشتراكات';
            case '/trips': return 'الرحلات';
            case '/bookings': return 'الحجوزات';
            case '/routes-locations': return 'المواقع والمسارات';
            case '/payments': return 'المدفوعات';
            default: return 'لوحة التحكم';
        }
    };

    return (
        <header className="h-[72px] px-6 bg-surface-dark border-b border-border-dark/50 flex items-center shrink-0">
            <h1 className="text-xl font-bold text-text-primary">
                {getPageTitle(pathname)}
            </h1>

            <div className="flex-1" />

            {/* Search Bar */}
            <div className="relative w-60">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-text-muted" size={18} />
                <input
                    type="text"
                    placeholder="ابحث..."
                    className="w-full h-10 pl-10 pr-3 bg-surface-dark border border-border-dark rounded-xl text-[13px] text-text-primary focus:border-primary-green transition-all"
                />
            </div>

            <div className="flex items-center gap-2 mr-5">
                <div className="relative group">
                    <button className="w-10 h-10 rounded-lg flex items-center justify-center text-text-secondary hover:text-accent-blue hover:bg-accent-blue/15 transition-all">
                        <Bell size={22} />
                    </button>
                    <div className="absolute top-1.5 right-1.5 min-w-[18px] h-[18px] bg-accent-red text-white text-[10px] font-bold rounded-full flex items-center justify-center p-1">
                        3
                    </div>
                </div>

                <button className="w-10 h-10 rounded-lg flex items-center justify-center text-text-secondary hover:text-accent-blue hover:bg-accent-blue/15 transition-all">
                    <SettingsIcon size={22} />
                </button>
            </div>

            <div className="mr-4 p-0.5 border-2 border-primary-green rounded-full overflow-hidden">
                <div className="w-10 h-10 bg-primary-green flex items-center justify-center text-black font-bold text-base">
                    AR
                </div>
            </div>
        </header>
    );
}
