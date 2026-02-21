"use client";

import { useState } from "react";
import { MapPin, Phone, Mail, Instagram, Facebook, Globe, Save, Loader2 } from "lucide-react";

export default function ContactCMSPage() {
    const [loading, setLoading] = useState(false);

    return (
        <div className="p-6 space-y-6 text-right">
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-text-primary">بيانات التواصل</h1>
                    <p className="text-sm text-text-secondary">تعديل معلومات الاتصال وروابط التواصل الاجتماعي المعروضة في التطبيق</p>
                </div>
                <button
                    className="btn-primary"
                    onClick={() => {
                        setLoading(true);
                        setTimeout(() => setLoading(false), 1000);
                    }}
                >
                    {loading ? <Loader2 className="animate-spin" size={18} /> : <Save size={18} />}
                    <span>حفظ التغييرات</span>
                </button>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                <div className="card p-6 space-y-6">
                    <h3 className="font-bold text-lg text-text-primary">معلومات الاتصال الأساسية</h3>
                    <div className="space-y-4">
                        <div className="space-y-1.5">
                            <label className="text-xs text-text-secondary block">رقم الهاتف</label>
                            <div className="relative">
                                <Phone className="absolute right-3 top-1/2 -translate-y-1/2 text-text-muted" size={18} />
                                <input type="text" className="w-full bg-surface-dark border border-border-dark rounded-xl py-2.5 pr-10 pl-4 text-left font-mono text-sm" defaultValue="+20 123 456 7890" />
                            </div>
                        </div>
                        <div className="space-y-1.5">
                            <label className="text-xs text-text-secondary block">البريد الإلكتروني</label>
                            <div className="relative">
                                <Mail className="absolute right-3 top-1/2 -translate-y-1/2 text-text-muted" size={18} />
                                <input type="email" className="w-full bg-surface-dark border border-border-dark rounded-xl py-2.5 pr-10 pl-4 text-left font-mono text-sm" defaultValue="support@elsikka.com" />
                            </div>
                        </div>
                        <div className="space-y-1.5">
                            <label className="text-xs text-text-secondary block">العنوان</label>
                            <div className="relative">
                                <MapPin className="absolute right-3 top-1/2 -translate-y-1/2 text-text-muted" size={18} />
                                <input type="text" className="w-full bg-surface-dark border border-border-dark rounded-xl py-2.5 pr-10 pl-4 text-right text-sm" defaultValue="القاهرة، مصر" />
                            </div>
                        </div>
                    </div>
                </div>

                <div className="card p-6 space-y-6">
                    <h3 className="font-bold text-lg text-text-primary">روابط التواصل الاجتماعي</h3>
                    <div className="space-y-4">
                        <div className="space-y-1.5">
                            <label className="text-xs text-text-secondary block">فيسبوك</label>
                            <div className="relative">
                                <Facebook className="absolute right-3 top-1/2 -translate-y-1/2 text-text-muted" size={18} />
                                <input type="text" className="w-full bg-surface-dark border border-border-dark rounded-xl py-2.5 pr-10 pl-4 text-left text-sm" placeholder="https://facebook.com/..." />
                            </div>
                        </div>
                        <div className="space-y-1.5">
                            <label className="text-xs text-text-secondary block">إنستجرام</label>
                            <div className="relative">
                                <Instagram className="absolute right-3 top-1/2 -translate-y-1/2 text-text-muted" size={18} />
                                <input type="text" className="w-full bg-surface-dark border border-border-dark rounded-xl py-2.5 pr-10 pl-4 text-left text-sm" placeholder="https://instagram.com/..." />
                            </div>
                        </div>
                        <div className="space-y-1.5">
                            <label className="text-xs text-text-secondary block">الموقع الإلكتروني</label>
                            <div className="relative">
                                <Globe className="absolute right-3 top-1/2 -translate-y-1/2 text-text-muted" size={18} />
                                <input type="text" className="w-full bg-surface-dark border border-border-dark rounded-xl py-2.5 pr-10 pl-4 text-left text-sm" placeholder="https://elsikka.com" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}
