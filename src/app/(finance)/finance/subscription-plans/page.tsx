"use client";

import { useEffect, useState } from "react";
import { Plus, CreditCard, Search, Edit2, Trash2, Loader2, CheckCircle2, XCircle } from "lucide-react";
import { cn } from "@/lib/utils";
import { supabase } from "@/lib/supabase";

export default function SubscriptionPlansPage() {
    const [plans, setPlans] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        async function fetchData() {
            try {
                // Assuming 'schedules' or a similar table might have plan info based on DB inspection
                const { data, error } = await supabase
                    .from('schedules')
                    .select('*, routes(route_name_ar)')
                    .eq('status', 'active');
                if (error) throw error;
                setPlans(data || []);
            } catch (error) {
                console.error("Error fetching plans:", error);
            } finally {
                setLoading(false);
            }
        }
        fetchData();
    }, []);

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
                    <h1 className="text-2xl font-bold text-text-primary">باقات الاشتراك</h1>
                    <p className="text-sm text-text-secondary">إدارة خطط الأسعار والاشتراكات المتاحة للمستخدمين</p>
                </div>
                <button className="btn-primary">
                    <Plus size={18} />
                    <span>إضافة باقة جديدة</span>
                </button>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {plans.map((plan) => (
                    <div key={plan.id} className="card p-6 border border-border-dark hover:border-primary-green/30 transition-all">
                        <div className="flex items-center justify-between mb-4">
                            <div className="w-12 h-12 rounded-xl bg-primary-green/10 flex items-center justify-center text-primary-green">
                                <CreditCard size={24} />
                            </div>
                            <div className={cn(
                                "px-2 py-1 rounded text-[10px] font-bold",
                                plan.is_active ? "bg-accent-green/10 text-accent-green" : "bg-accent-red/10 text-accent-red"
                            )}>
                                {plan.is_active ? 'نشط' : 'متوقف'}
                            </div>
                        </div>
                        <h3 className="text-lg font-bold text-text-primary mb-2">{plan.routes?.route_name_ar || 'باقة عامة'}</h3>
                        <div className="flex items-end gap-2 mb-6">
                            <span className="text-3xl font-black text-white">{plan.price}</span>
                            <span className="text-sm text-text-secondary mb-1">ج.م / شهرياً</span>
                        </div>
                        <div className="space-y-3">
                            <div className="flex items-center justify-between text-xs text-text-secondary">
                                <span>سعر الرحلة:</span>
                                <span className="text-text-primary font-bold">{plan.price_per_trip} ج.م</span>
                            </div>
                            <div className="flex items-center justify-between text-xs text-text-secondary">
                                <span>السعة:</span>
                                <span className="text-text-primary font-bold">{plan.capacity} مقعد</span>
                            </div>
                        </div>
                        <div className="mt-6 flex gap-2">
                            <button className="flex-1 py-2 bg-surface-dark border border-border-dark rounded-xl text-xs font-bold hover:bg-white/5 transition-colors">تعديل</button>
                            <button className="p-2 border border-accent-red/20 text-accent-red rounded-xl hover:bg-accent-red/10 transition-colors">
                                <Trash2 size={16} />
                            </button>
                        </div>
                    </div>
                ))}
            </div>
            {plans.length === 0 && (
                <div className="card p-12 text-center text-text-secondary italic">
                    لا توجد باقات اشتراك معرفة حالياً.
                </div>
            )}
        </div>
    );
}
