"use client";

import { useState, useEffect, useCallback } from "react";
import {
    Check,
    X,
    Eye,
    Loader2,
    RefreshCw,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { supabase } from "@/lib/supabase";
import { sileo } from "sileo";

type WalletTransaction = {
    id: string;
    user_id: string;
    amount: number;
    type: string;
    reason: string;
    balance_after: number;
    status: 'success' | 'failed';
    created_at: string;
    users?: {
        full_name: string;
        phone: string;
        email: string;
        wallet_balance: number;
    };
};

type WalletRequest = {
    id: string;
    user_id: string;
    amount: number;
    phone_number: string;
    proof_image_url: string;
    method: string;
    type: 'topup' | 'withdraw';
    status: 'pending' | 'approved' | 'rejected';
    created_at: string;
    users?: {
        full_name: string;
        phone: string;
        wallet_balance: number;
    };
};

export default function WalletPage() {
    const [transactions, setTransactions] = useState<WalletTransaction[]>([]);
    const [requests, setRequests] = useState<WalletRequest[]>([]);
    const [activeTab, setActiveTab] = useState<'requests' | 'transactions'>('requests');
    const [loading, setLoading] = useState(true);
    const [filterType, setFilterType] = useState<'all' | 'credit' | 'debit'>('all');

    const [error, setError] = useState<string | null>(null);
    const [selectedImage, setSelectedImage] = useState<string | null>(null);

    const playNotificationSound = useCallback(() => {
        const audio = new Audio('/sounds/notification.mp3');
        audio.play().catch(e => console.warn("Audio play blocked by browser:", e));
    }, []);

    const fetchData = useCallback(async () => {
        setLoading(true);
        setError(null);
        try {
            if (activeTab === 'transactions') {
                const { data, error: queryError } = await supabase
                    .from('wallet_transactions')
                    .select('*, users(full_name, phone, email, wallet_balance)')
                    .order('created_at', { ascending: false });

                if (queryError) throw queryError;
                setTransactions(data as any || []);
            } else {
                const { data, error: queryError } = await supabase
                    .from('wallet_requests')
                    .select('*, users(full_name, phone, wallet_balance)')
                    .order('created_at', { ascending: false });

                if (queryError) {
                    const { data: simpleData, error: simpleError } = await supabase
                        .from('wallet_requests')
                        .select('*')
                        .order('created_at', { ascending: false });
                    if (simpleError) throw simpleError;
                    setRequests(simpleData as any || []);
                } else {
                    setRequests(data as any || []);
                }
            }
        } catch (err: any) {
            console.error("Fetch error:", err);
            setError(err.message || "حدث خطأ أثناء جلب البيانات");
        } finally {
            setLoading(false);
        }
    }, [activeTab]);

    useEffect(() => {
        fetchData();

        // Real-time subscription for new requests
        const channel = supabase
            .channel('wallet_requests_changes')
            .on(
                'postgres_changes',
                { event: 'INSERT', schema: 'public', table: 'wallet_requests' },
                (payload) => {
                    const newReq = payload.new as WalletRequest;
                    if (newReq.status === 'pending') {
                        playNotificationSound();
                        sileo.info({ description: `طلب شحن جديد بـ ${newReq.amount} EGP من رقم ${newReq.phone_number}` });
                        fetchData();
                    }
                }
            )
            .subscribe();

        return () => {
            supabase.removeChannel(channel);
        };
    }, [activeTab, filterType, playNotificationSound, fetchData]);

    const handleApprove = async (request: WalletRequest) => {
        if (!confirm(`هل أنت متأكد من الموافقة على العملية بمبلغ ${request.amount} EGP؟`)) return;

        setLoading(true);
        try {
            const { error: rpcError } = await supabase.rpc('approve_wallet_request', {
                req_id: request.id
            });

            if (rpcError) throw new Error(rpcError.message);

            sileo.success({ description: "تمت الموافقة على طلب الشحن بنجاح" });
            await fetchData();

        } catch (err: any) {
            console.error("Critical error in handleApprove:", err);
            sileo.error({ description: "فشلت العملية: " + err.message });
            fetchData();
        } finally {
            setLoading(false);
        }
    };

    const handleReject = async (requestId: string) => {
        if (!confirm("هل أنت متأكد من رفض هذا الطلب؟")) return;
        setLoading(true);
        try {
            const { error } = await supabase
                .from('wallet_requests')
                .update({ status: 'rejected' })
                .eq('id', requestId);
            if (error) throw error;

            sileo.warning({ description: "تم إغلاق ورفض طلب الشحن" });
            fetchData();
        } catch (err: any) {
            sileo.error({ description: "حدث خطأ أثناء الرفض: " + err.message });
        } finally {
            setLoading(false);
        }
    };

    const getProofUrl = (path: string) => {
        if (!path) return null;
        if (path.startsWith('http')) return path;
        const { data } = supabase.storage.from('recharge_proofs').getPublicUrl(path);
        return data.publicUrl;
    };

    const totalCredit = transactions.filter(t => t.type === 'credit' && t.status === 'success').reduce((acc, t) => acc + t.amount, 0);
    const totalDebit = transactions.filter(t => t.type === 'debit' && t.status === 'success').reduce((acc, t) => acc + t.amount, 0);

    return (
        <div className="space-y-8 animate-fade-up h-[calc(100vh-8rem)] flex flex-col">
            {/* Header */}
            <div className="flex items-end justify-between shrink-0">
                <div>
                    <h2 className="text-3xl font-black italic mb-2">إدارة المحفظة (الجديدة)</h2>
                    <p className="text-[10px] text-text-dim uppercase tracking-widest">
                        Unified Wallet System
                    </p>
                </div>
                <div className="flex items-center gap-3">
                    {loading && <Loader2 className="animate-spin text-primary-gold" size={24} />}
                    <button onClick={fetchData} className="w-10 h-10 border border-white/10 hover:bg-white/5 text-text-dim hover:text-white flex items-center justify-center transition-all shadow-lg">
                        <RefreshCw size={16} />
                    </button>
                </div>
            </div>

            {/* Main Tabs */}
            <div className="flex items-center gap-1 bg-white/5 p-1 border border-white/5 w-fit shrink-0">
                <button
                    onClick={() => setActiveTab('requests')}
                    className={cn(
                        "px-6 py-2.5 text-[10px] font-black uppercase tracking-widest transition-all",
                        activeTab === 'requests' ? "bg-primary-gold text-bg-black" : "text-text-dim hover:text-white"
                    )}
                >
                    الطلبات الجديدة ({requests.filter(r => r.status === 'pending').length})
                </button>
                <button
                    onClick={() => setActiveTab('transactions')}
                    className={cn(
                        "px-6 py-2.5 text-[10px] font-black uppercase tracking-widest transition-all",
                        activeTab === 'transactions' ? "bg-white text-bg-black" : "text-text-dim hover:text-white"
                    )}
                >
                    سجل المعاملات
                </button>
            </div>

            {/* Content Area */}
            <div className="flex-1 min-h-0 bg-surface-dark border border-white/5 overflow-hidden flex flex-col shadow-2xl">
                <div className="overflow-y-auto flex-1">
                    <table className="w-full text-right border-collapse">
                        <thead className="sticky top-0 z-10">
                            <tr className="bg-black/60 backdrop-blur-sm border-b border-white/10">
                                <th className="p-5 text-[10px] font-black uppercase tracking-widest text-text-dim text-right">المستخدم</th>
                                <th className="p-5 text-[10px] font-black uppercase tracking-widest text-text-dim text-center">النوع</th>
                                <th className="p-5 text-[10px] font-black uppercase tracking-widest text-text-dim text-center">المبلغ</th>
                                <th className="p-5 text-[10px] font-black uppercase tracking-widest text-text-dim text-center">التفاصيل</th>
                                <th className="p-5 text-[10px] font-black uppercase tracking-widest text-text-dim text-center">الحالة</th>
                                <th className="p-5 text-[10px] font-black uppercase tracking-widest text-text-dim text-center">الإجراء</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-white/5">
                            {activeTab === 'requests' ? (
                                requests.map((req) => (
                                    <tr key={req.id} className="hover:bg-white/2 transition-colors">
                                        <td className="p-5 font-black text-sm text-text-main text-right">
                                            {req.users?.full_name || 'مستخدم غير مربوط'}
                                            <div className="text-[10px] text-text-dim font-normal">{req.phone_number}</div>
                                        </td>
                                        <td className="p-5 text-center">
                                            <span className={cn(
                                                "px-2 py-0.5 text-[8px] font-black uppercase border inline-block",
                                                req.type === 'topup' ? "bg-state-success/10 text-state-success border-state-success/20" : "bg-state-error/10 text-state-error border-state-error/20"
                                            )}>
                                                {req.type === 'topup' ? 'شحن' : 'سحب'}
                                            </span>
                                        </td>
                                        <td className="p-5 font-black text-white text-center">{req.amount} EGP</td>
                                        <td className="p-5">
                                            <div className="flex items-center justify-center gap-3 text-xs text-text-dim">
                                                {req.proof_image_url && (
                                                    <button
                                                        onClick={() => setSelectedImage(getProofUrl(req.proof_image_url))}
                                                        className="w-7 h-7 bg-white/5 border border-white/10 flex items-center justify-center hover:bg-primary-gold hover:text-bg-black transition-all group/eye shrink-0"
                                                        title="عرض الإثبات"
                                                    >
                                                        <Eye size={12} className="group-hover/eye:scale-110 transition-transform" />
                                                    </button>
                                                )}
                                                <span className="font-medium whitespace-nowrap">{req.method || '—'}</span>
                                            </div>
                                        </td>
                                        <td className="p-5 text-center">
                                            <span className={cn(
                                                "px-2 py-1 text-[8px] font-black uppercase",
                                                req.status === 'pending' ? "text-primary-gold" : req.status === 'approved' ? "text-state-success" : "text-state-error"
                                            )}>
                                                {req.status === 'pending' ? 'بانتظار الموافقة' : req.status === 'approved' ? 'مقبول' : 'مرفوض'}
                                            </span>
                                        </td>
                                        <td className="p-5">
                                            {req.status === 'pending' && (
                                                <div className="flex gap-2 justify-center">
                                                    <button onClick={() => handleApprove(req)} className="w-8 h-8 bg-state-success text-bg-black flex items-center justify-center hover:bg-white transition-all shadow-lg"><Check size={16} /></button>
                                                    <button onClick={() => handleReject(req.id)} className="w-8 h-8 bg-state-error text-bg-black flex items-center justify-center hover:bg-white transition-all shadow-lg"><X size={16} /></button>
                                                </div>
                                            )}
                                        </td>
                                    </tr>
                                ))
                            ) : (
                                transactions.map((tx) => (
                                    <tr key={tx.id} className="hover:bg-white/2 transition-colors">
                                        <td className="p-5 font-black text-sm text-text-main">{tx.users?.full_name || 'مستخدم'}</td>
                                        <td className="p-5 text-[10px] uppercase font-black">{tx.type === 'credit' ? 'إيداع' : 'خصم'}</td>
                                        <td className="p-5 font-black">{tx.amount} EGP</td>
                                        <td className="p-5 text-xs text-text-dim">{tx.reason}</td>
                                        <td className="p-5 text-xs text-primary-gold font-bold">{tx.balance_after} EGP</td>
                                        <td className="p-5 text-[10px] text-text-dim">{new Date(tx.created_at).toLocaleDateString('ar-EG')}</td>
                                    </tr>
                                ))
                            )}
                        </tbody>
                    </table>
                </div>
            </div>

            {/* Proof Modal stays same if needed */}
            {selectedImage && (
                <div className="fixed inset-0 z-50 bg-black/90 backdrop-blur-md flex items-center justify-center p-10" onClick={() => setSelectedImage(null)}>
                    <img src={selectedImage} alt="Proof" className="max-w-full max-h-full object-contain shadow-2xl" />
                </div>
            )}
        </div>
    );
}
