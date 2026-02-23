"use client";

import { Plus, Search, MapPin, MoreVertical, ExternalLink } from "lucide-react";

export default function PointToPointPage() {
    const areas = [
        { name: "الشروق", points: 8, status: "Active" },
        { name: "القاهرة الجديدة", points: 14, status: "Active" },
        { name: "مدينتي", points: 6, status: "Restricted" },
        { name: "الرحاب", points: 10, status: "Active" },
    ];

    return (
        <div className="space-y-10 animate-fade-up">
            <div className="flex items-end justify-between">
                <div>
                    <h2 className="text-3xl font-black italic">من موقف لموقف</h2>
                    <p className="text-[10px] text-text-dim uppercase tracking-widest mt-1">Network Infrastructure & Entry Points</p>
                </div>
                <button className="btn-swiss">إضافة منطقة</button>
            </div>

            <div className="relative glass-card px-6 py-1">
                <Search className="absolute right-6 top-1/2 -translate-y-1/2 text-text-dim" size={16} />
                <input
                    type="text"
                    placeholder="بحث في الشبكة..."
                    className="w-full h-14 bg-transparent border-0 text-xs font-bold uppercase tracking-widest outline-none pr-10"
                />
            </div>

            <div className="grid grid-cols-2 gap-4">
                {areas.map((area, i) => (
                    <div key={i} className="glass-card p-0 overflow-hidden flex flex-col group">
                        <div className="p-8 flex items-center justify-between flex-1">
                            <div className="flex items-center gap-6">
                                <div className="w-16 h-16 bg-white/5 flex items-center justify-center font-black text-xl border border-white/5 group-hover:border-primary-gold transition-all">
                                    {area.name[0]}
                                </div>
                                <div>
                                    <h3 className="text-xl font-black mb-1">{area.name}</h3>
                                    <div className="flex items-center gap-4">
                                        <span className="flex items-center gap-1.5 text-[8px] font-black uppercase text-text-dim">
                                            <MapPin size={10} className="text-primary-gold" /> {area.points} نقاط توقف
                                        </span>
                                        <span className={`text-[8px] font-black uppercase ${area.status === 'Active' ? 'text-state-success' : 'text-state-warning'
                                            }`}>
                                            • {area.status}
                                        </span>
                                    </div>
                                </div>
                            </div>
                            <div className="flex gap-2">
                                <button className="w-10 h-10 flex items-center justify-center hover:bg-white/5 transition-colors border border-transparent hover:border-white/5">
                                    <ExternalLink size={16} />
                                </button>
                                <button className="w-10 h-10 flex items-center justify-center hover:bg-white/5 transition-colors border border-transparent hover:border-white/5">
                                    <MoreVertical size={16} />
                                </button>
                            </div>
                        </div>

                        <div className="h-2 w-full bg-white/5 relative">
                            <div className={`absolute h-full left-0 ${area.status === 'Active' ? 'bg-state-success' : 'bg-state-warning'
                                } opacity-20 w-full`} />
                        </div>
                    </div>
                ))}
            </div>

            <div className="bg-surface-card border border-border-subtle p-12 text-center space-y-4">
                <h4 className="text-sm">توسعة الشبكة</h4>
                <p className="text-[10px] text-text-dim uppercase tracking-widest max-w-sm mx-auto">
                    يمكنك إضافة مناطق جديدة ونقاط تحرك لربط شبكة في السكة بشكل أوسع وتغطية مناطق أكثر.
                </p>
                <div className="pt-4">
                    <button className="text-xs font-black uppercase text-primary-gold hover:underline underline-offset-8">تحميل المخطط الكامل</button>
                </div>
            </div>
        </div>
    );
}
