"use client";

import { useEffect, useState } from "react";
import { Check, X, Eye, Search, Clock, CreditCard, User, Loader2, AlertCircle, CheckCircle2 } from "lucide-react";
import { cn } from "@/lib/utils";
import { db } from "@/lib/database";
import { Subscription } from "@/types/database";

export default function SubscriptionsApprovalPage() {
    const [subscriptions, setSubscriptions] = useState<Subscription[]>([]);
    const [loading, setLoading] = useState(true);
    const [processing, setProcessing] = useState<string | null>(null);

    useEffect(() => {
        async function fetchData() {
            try {
                const data = await db.getPendingSubscriptions();
                setSubscriptions(data);
            } catch (error) {
                console.error("Error fetching subscriptions:", error);
            } finally {
                setLoading(false);
            }
        }
        fetchData();
    }, []);

    const handleAction = async (id: string, status: 'active' | 'expired') => {
        setProcessing(id);
        try {
            await db.updateSubscriptionStatus(id, status);
            setSubscriptions(prev => prev.filter(s => s.id !== id));
        } catch (error) {
            console.error("Error updating subscription:", error);
            alert("حدث خطأ أثناء تحديث حالة الاشتراك.");
        } finally {
            setProcessing(null);
        }
    };

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
                    <h1 className="text-2xl font-bold text-text-primary">طلبات الاشتراكات</h1>
                    <p className="text-sm text-text-secondary">مراجعة وتفعيل اشتراكات المستخدمين بناءً على إيصالات التحويل</p>
                </div>
                <div className="flex items-center gap-2 px-4 py-2 bg-primary-green/10 text-primary-green rounded-xl border border-primary-green/20">
                    <AlertCircle size={18} />
                    <span className="text-sm font-bold">{subscriptions.length} طلبات قيد الانتظار</span>
                </div>
            </div>

            <div className="grid gap-4">
                {subscriptions.map((sub) => (
                    <div key={sub.id} className="card p-4 group hover:border-primary-green/20 transition-all">
                        <div className="flex flex-col lg:flex-row lg:items-center gap-6">
                            {/* User Info */}
                            <div className="flex items-center gap-4 lg:w-1/4">
                                <div className="w-12 h-12 rounded-full bg-surface-dark border border-border-dark flex items-center justify-center text-text-secondary">
                                    <User size={24} />
                                </div>
                                <div>
                                    <h3 className="font-bold text-text-primary">{sub.users?.full_name || 'مستخدم غير معروف'}</h3>
                                    <p className="text-xs text-text-secondary">{sub.users?.phone || sub.user_id}</p>
                                </div>
                            </div>

                            {/* Plan Details */}
                            <div className="grid grid-cols-2 md:grid-cols-3 gap-4 lg:flex-1">
                                <div className="space-y-1">
                                    <p className="text-[10px] text-text-muted">نوع الباقة</p>
                                    <div className="flex items-center gap-2 text-text-primary">
                                        <Clock size={14} className="text-primary-green" />
                                        <span className="text-xs font-bold">{sub.plan_type}</span>
                                    </div>
                                </div>
                                <div className="space-y-1">
                                    <p className="text-[10px] text-text-muted">السعر الإجمالي</p>
                                    <div className="flex items-center gap-2 text-text-primary">
                                        <CreditCard size={14} className="text-primary-green" />
                                        <span className="text-xs font-bold">{sub.total_price} ج.م</span>
                                    </div>
                                </div>
                                <div className="space-y-1">
                                    <p className="text-[10px] text-text-muted">رقم التحويل</p>
                                    <p className="text-xs font-bold text-primary-green">{sub.transfer_number || 'غير متوفر'}</p>
                                </div>
                            </div>

                            {/* Actions */}
                            <div className="flex items-center gap-3 lg:justify-end">
                                <button
                                    className="p-2.5 bg-surface-dark border border-border-dark rounded-xl text-text-primary hover:bg-white/5 transition-colors"
                                    title="عرض إيصال الدفع"
                                    onClick={() => sub.payment_proof_url && window.open(sub.payment_proof_url, '_blank')}
                                >
                                    <Eye size={18} />
                                </button>
                                <button
                                    disabled={processing === sub.id}
                                    onClick={() => handleAction(sub.id, 'active')}
                                    className="flex-1 lg:flex-none btn-primary bg-accent-green hover:bg-accent-green/80 border-accent-green/20 h-10 px-4"
                                >
                                    {processing === sub.id ? <Loader2 className="animate-spin" size={18} /> : <Check size={18} />}
                                    <span>تفعيل</span>
                                </button>
                                <button
                                    disabled={processing === sub.id}
                                    onClick={() => handleAction(sub.id, 'expired')}
                                    className="flex-1 lg:flex-none p-2.5 border border-accent-red/20 text-accent-red hover:bg-accent-red/10 rounded-xl transition-colors h-10"
                                >
                                    <X size={18} />
                                </button>
                            </div>
                        </div>
                    </div>
                ))}
                {subscriptions.length === 0 && (
                    <div className="card p-12 text-center text-text-secondary flex flex-col items-center gap-4">
                        <div className="w-16 h-16 rounded-full bg-white/5 flex items-center justify-center text-text-muted">
                            <CheckCircle2 size={32} />
                        </div>
                        <div>
                            <p className="text-lg font-bold text-text-primary">لا توجد طلبات معلقة</p>
                            <p className="text-sm">تمت معالجة جميع طلبات الاشتراكات بنجاح.</p>
                        </div>
                    </div>
                )}
            </div>
        </div>
    );
}
