"use client";

import { useEffect, useState } from "react";
import { Plus, HelpCircle, Search, Edit2, Trash2, ChevronDown, ChevronUp, Save, X, Loader2 } from "lucide-react";
import { cn } from "@/lib/utils";
import { db } from "@/lib/database";
import { FAQ } from "@/types/database";

export default function FAQManagementPage() {
    const [faqs, setFaqs] = useState<FAQ[]>([]);
    const [loading, setLoading] = useState(true);
    const [isEditing, setIsEditing] = useState<number | null>(null);
    const [searchQuery, setSearchQuery] = useState("");

    useEffect(() => {
        async function fetchData() {
            try {
                const data = await db.getFAQs();
                setFaqs(data);
            } catch (error) {
                console.error("Error fetching FAQs:", error);
            } finally {
                setLoading(false);
            }
        }
        fetchData();
    }, []);

    const filteredFAQs = faqs.filter(faq =>
        faq.question.includes(searchQuery) ||
        faq.answer.includes(searchQuery) ||
        faq.category.includes(searchQuery)
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
                    <h1 className="text-2xl font-bold text-text-primary">مركز المساعدة (FAQ)</h1>
                    <p className="text-sm text-text-secondary">إدارة الأسئلة الشائعة والإجابات المقدمة للمستخدمين من قاعدة البيانات</p>
                </div>
                <button className="btn-primary">
                    <Plus size={18} />
                    <span>إضافة سؤال جديد</span>
                </button>
            </div>

            <div className="relative">
                <Search className="absolute right-3 top-1/2 -translate-y-1/2 text-text-muted" size={18} />
                <input
                    type="text"
                    placeholder="بحث في الأسئلة الشائعة..."
                    className="w-full bg-surface-dark border border-border-dark rounded-xl py-2.5 pr-10 pl-4 text-sm text-right focus:border-primary-green transition-colors outline-none"
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                />
            </div>

            <div className="grid gap-4">
                {filteredFAQs.map((faq) => (
                    <div key={faq.id} className="card p-5 space-y-4">
                        <div className="flex items-start justify-between gap-4">
                            <div className="flex items-start gap-4 flex-1">
                                <div className="w-10 h-10 rounded-xl bg-accent-purple/10 flex items-center justify-center text-accent-purple shrink-0 mt-1">
                                    <HelpCircle size={20} />
                                </div>
                                <div className="space-y-1 w-full text-right">
                                    <div className="flex items-center gap-2 justify-end">
                                        <span className="px-2 py-0.5 bg-surface-dark border border-border-dark text-[10px] text-text-secondary rounded-full">
                                            {faq.category}
                                        </span>
                                    </div>
                                    {isEditing === faq.id ? (
                                        <input
                                            type="text"
                                            className="w-full bg-black border border-primary-green/50 rounded-lg p-2 text-sm text-text-primary outline-none text-right"
                                            defaultValue={faq.question}
                                        />
                                    ) : (
                                        <h3 className="font-bold text-text-primary">{faq.question}</h3>
                                    )}
                                </div>
                            </div>

                            <div className="flex items-center gap-2">
                                {isEditing === faq.id ? (
                                    <>
                                        <button onClick={() => setIsEditing(null)} className="p-2 hover:bg-accent-green/10 text-accent-green rounded-lg transition-colors">
                                            <Save size={18} />
                                        </button>
                                        <button onClick={() => setIsEditing(null)} className="p-2 hover:bg-accent-red/10 text-accent-red rounded-lg transition-colors">
                                            <X size={18} />
                                        </button>
                                    </>
                                ) : (
                                    <>
                                        <button onClick={() => setIsEditing(faq.id)} className="p-2 hover:bg-white/5 rounded-lg text-text-secondary hover:text-primary-green transition-colors">
                                            <Edit2 size={16} />
                                        </button>
                                        <button className="p-2 hover:bg-white/5 rounded-lg text-text-secondary hover:text-accent-red transition-colors">
                                            <Trash2 size={16} />
                                        </button>
                                    </>
                                )}
                            </div>
                        </div>

                        <div className="pr-14">
                            {isEditing === faq.id ? (
                                <textarea
                                    className="w-full bg-black border border-primary-green/50 rounded-lg p-3 text-sm text-text-secondary outline-none min-h-[100px] text-right"
                                    defaultValue={faq.answer}
                                />
                            ) : (
                                <p className="text-sm text-text-secondary leading-relaxed bg-surface-dark/30 p-4 rounded-xl border border-border-dark/30 text-right">
                                    {faq.answer}
                                </p>
                            )}
                        </div>
                    </div>
                ))}
                {filteredFAQs.length === 0 && !loading && (
                    <div className="card p-12 text-center text-text-secondary italic">
                        لا توجد أسئلة شائعة مطابقة للبحث.
                    </div>
                )}
            </div>
        </div>
    );
}
