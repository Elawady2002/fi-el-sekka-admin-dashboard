"use client";

import { useEffect, useState } from "react";
import { Check, X, Eye, Search, Wallet, User, Loader2, AlertCircle, Clock } from "lucide-react";
import { cn } from "@/lib/utils";
import { supabase } from "@/lib/supabase";

export default function WalletTopupsPage() {
    const [requests, setRequests] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [processing, setProcessing] = useState<string | null>(null);

    useEffect(() => {
        async function fetchData() {
            try {
                const { data, error } = await supabase
                    .from('wallet_topup_requests')
                    .select('*, users(*)')
                    .eq('status', 'pending')
                    .order('created_at', { ascending: false });

                if (error) {
                    // If table doesn't exist, don't crash, just show empty
                    console.warn("Table wallet_topup_requests might be missing:", error.message);
                    setRequests([]);
                    return;
                }
                setRequests(data || []);
            } catch (error) {
                console.error("Error fetching topups:", error);
            } finally {
                setLoading(false);
            }
        }
        fetchData();
    }, []);

    const handleAction = async (id: string, userId: string, amount: number, status: 'approved' | 'rejected') => {
        setProcessing(id);
        try {
            if (status === 'approved') {
                const { data: user } = await supabase.from('users').select('wallet_balance').eq('id', userId).single();
                const newBalance = (user?.wallet_balance || 0) + amount;
                await supabase.from('users').update({ wallet_balance: newBalance }).eq('id', userId);
            }

            await supabase.from('wallet_topup_requests').update({ status }).eq('id', id);
            setRequests(prev => prev.filter(r => r.id !== id));
        } catch (error) {
            console.error("Error processing topup:", error);
            alert("حدث خطأ أثناء معالجة الطلب.");
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
                    <h1 className="text-2xl font-bold text-text-primary">طلبات شحن المحفظة</h1>
                    <p className="text-sm text-text-secondary">مراجعة طلبات زيادة الرصيد يدوياً عبر إيصالات التحويل</p>
                </div>
                <div className="flex items-center gap-2 px-4 py-2 bg-primary-green/10 text-primary-green rounded-xl border border-primary-green/20">
                    <AlertCircle size={18} />
                    <span className="text-sm font-bold">{requests.length} طلبات معلقة</span>
                </div>
            </div>

            <div className="grid gap-4">
                {requests.map((req) => (
                    <div key={req.id} className="card p-4 hover:border-primary-green/20 transition-all">
                        <div className="flex flex-col lg:flex-row lg:items-center gap-6">
                            <div className="flex items-center gap-4 lg:w-1/4">
                                <div className="w-12 h-12 rounded-full bg-surface-dark border border-border-dark flex items-center justify-center text-text-secondary overflow-hidden">
                                    {req.users?.avatar_url ? <img src={req.users.avatar_url} className="w-full h-full object-cover" /> : <User size={24} />}
                                </div>
                                <div>
                                    <h3 className="font-bold text-text-primary">{req.users?.full_name || 'مستخدم'}</h3>
                                    <p className="text-xs text-text-secondary">{req.users?.phone}</p>
                                </div>
                            </div>

                            <div className="grid grid-cols-2 md:grid-cols-3 gap-4 lg:flex-1">
                                <div className="space-y-1">
                                    <p className="text-[10px] text-text-muted">المبلغ المطلوب</p>
                                    <p className="text-lg font-bold text-primary-green">{req.amount} ج.م</p>
                                </div>
                                <div className="space-y-1">
                                    <p className="text-[10px] text-text-muted">تاريخ الطلب</p>
                                    <div className="flex items-center gap-2 text-text-primary text-xs">
                                        <Clock size={14} className="text-text-muted" />
                                        <span>{new Date(req.created_at).toLocaleString('ar-EG')}</span>
                                    </div>
                                </div>
                                <div className="space-y-1">
                                    <p className="text-[10px] text-text-muted">وسيلة الدفع</p>
                                    <p className="text-xs font-bold text-text-primary">تحويل إلكتروني</p>
                                </div>
                            </div>

                            <div className="flex items-center gap-3 lg:justify-end">
                                <button
                                    className="p-2.5 bg-surface-dark border border-border-dark rounded-xl text-text-primary hover:bg-white/5 transition-colors"
                                    onClick={() => req.proof_url && window.open(req.proof_url, '_blank')}
                                >
                                    <Eye size={18} />
                                </button>
                                <button
                                    disabled={processing === req.id}
                                    onClick={() => handleAction(req.id, req.user_id, req.amount, 'approved')}
                                    className="flex-1 lg:flex-none btn-primary bg-accent-green hover:bg-accent-green/80 border-accent-green/20 h-10 px-4"
                                >
                                    {processing === req.id ? <Loader2 className="animate-spin" size={18} /> : <Check size={18} />}
                                    <span>موافقة</span>
                                </button>
                                <button
                                    disabled={processing === req.id}
                                    onClick={() => handleAction(req.id, req.user_id, req.amount, 'rejected')}
                                    className="flex-1 lg:flex-none p-2.5 border border-accent-red/20 text-accent-red hover:bg-accent-red/10 rounded-xl transition-colors h-10"
                                >
                                    <X size={18} />
                                </button>
                            </div>
                        </div>
                    </div>
                ))}
                {requests.length === 0 && (
                    <div className="card p-12 text-center text-text-secondary flex flex-col items-center gap-4">
                        <div className="w-16 h-16 rounded-full bg-white/5 flex items-center justify-center text-text-muted">
                            <Wallet size={32} />
                        </div>
                        <p className="text-lg font-bold text-text-primary">لا توجد طلبات شحن معلقة حالياً.</p>
                    </div>
                )}
            </div>
        </div>
    );
}
