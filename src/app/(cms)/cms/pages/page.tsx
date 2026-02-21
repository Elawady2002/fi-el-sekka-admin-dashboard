"use client";

import { Plus, Edit2, FileText, Globe, Loader2 } from "lucide-react";

export default function StaticPagesCMS() {
    return (
        <div className="p-6 space-y-6 text-right">
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-text-primary">الصفحات الثابتة</h1>
                    <p className="text-sm text-text-secondary">إدارة محتوى صفحات الشروط والأحكام و سياسة الخصوصية</p>
                </div>
                <button className="btn-primary">
                    <Plus size={18} />
                    <span>إنشاء صفحة جديدة</span>
                </button>
            </div>

            <div className="grid gap-4">
                {[
                    { title: "الشروط والأحكام", slug: "terms", updated: "٢٠٢٤/٠١/١٥" },
                    { title: "سياسة الخصوصية", slug: "privacy", updated: "٢٠٢٤/٠١/٢٠" },
                    { title: "عن المنصة", slug: "about", updated: "٢٠٢٣/١٢/٠٥" },
                ].map((item) => (
                    <div key={item.slug} className="card p-4 flex items-center justify-between hover:bg-white/2 transition-all">
                        <div className="flex items-center gap-4">
                            <div className="w-10 h-10 rounded-lg bg-surface-dark border border-border-dark flex items-center justify-center text-text-muted">
                                <FileText size={20} />
                            </div>
                            <div>
                                <h3 className="font-bold text-text-primary">{item.title}</h3>
                                <div className="flex items-center gap-2 text-[10px] text-text-secondary">
                                    <Globe size={10} />
                                    <span>/{item.slug}</span>
                                    <span>•</span>
                                    <span>آخر تحديث: {item.updated}</span>
                                </div>
                            </div>
                        </div>
                        <button className="p-2.5 bg-surface-dark border border-border-dark rounded-xl text-text-secondary hover:text-primary-green transition-all group">
                            <Edit2 size={18} className="group-hover:scale-110 transition-transform" />
                        </button>
                    </div>
                ))}
            </div>
        </div>
    );
}
