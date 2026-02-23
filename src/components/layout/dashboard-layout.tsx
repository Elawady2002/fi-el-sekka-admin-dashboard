"use client";

import { Sidebar } from "./sidebar";

export function DashboardLayout({ children }: { children: React.ReactNode }) {
    return (
        <div className="flex min-h-screen bg-bg-black">
            <Sidebar />
            <main className="flex-1 overflow-y-auto">
                <header className="h-20 border-b border-border-subtle flex items-center justify-between px-10 sticky top-0 bg-bg-black/80 backdrop-blur-md z-40">
                    <div className="flex items-center gap-2">
                        <div className="w-2 h-2 rounded-full bg-state-success animate-pulse" />
                        <span className="text-[10px] uppercase font-black tracking-widest text-text-dim">System Live</span>
                    </div>
                    <div className="flex items-center gap-6">
                        <div className="text-left">
                            <p className="text-[10px] font-black uppercase text-text-main">Ahmed Reda</p>
                            <p className="text-[8px] uppercase text-primary-gold font-display">Super Admin</p>
                        </div>
                        <div className="w-10 h-10 bg-surface-card border border-border-subtle flex items-center justify-center font-black">A</div>
                    </div>
                </header>
                <div className="p-10">
                    {children}
                </div>
            </main>
        </div>
    );
}
