"use client";

import { useState, useEffect } from "react";
import {
    Check,
    X,
    Clock,
    Banknote,
    Users,
    Eye,
    Loader2,
    AlertCircle,
    ExternalLink
} from "lucide-react";
import { cn } from "@/lib/utils";
import { supabase } from "@/lib/supabase";

type RechargeRequest = {
    id: string;
    user_id: string;
    amount: number;
    screenshot_url: string;
    status: 'pending' | 'approved' | 'rejected';
    created_at: string;
    users: {
        full_name: string;
        phone: string;
        balance: number;
    };
};

export default function WalletPage() {
    const [requests, setRequests] = useState<RechargeRequest[]>([]);
    const [loading, setLoading] = useState(true);
    const [processingId, setProcessingId] = useState<string | null>(null);
    const [viewScreenshot, setViewScreenshot] = useState<string | null>(null);

    const fetchRequests = async () => {
        setLoading(true);
        try {
            const { data, error } = await supabase
                .from('wallet_recharge_requests')
                .select(`
                    *,
                    users (
                        full_name,
                        phone,
                        balance
                    )
                `)
                .order('created_at', { ascending: false });

            if (error) throw error;
            setRequests(data as any || []);
        } catch (error) {
            console.error("Error fetching requests:", error);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchRequests();
    }, []);

    const handleAction = async (requestId: string, userId: string, amount: number, action: 'approve' | 'reject') => {
        setProcessingId(requestId);
        try {
            if (action === 'approve') {
                // 1. Update request status
                const { error: reqError } = await supabase
                    .from('wallet_recharge_requests')
                    .update({ status: 'approved' })
                    .eq('id', requestId);

                if (reqError) throw reqError;

                // 2. Increment user balance
                // Note: In a production app, this should be a transaction or an RPC
                // For now we do it sequentially if RLS is disabled
                const { data: userData, error: userFetchError } = await supabase
                    .from('users')
                    .select('balance')
                    .eq('id', userId)
                    .single();

                if (userFetchError) throw userFetchError;

                const newBalance = (userData.balance || 0) + amount;
                const { error: userUpdateError } = await supabase
                    .from('users')
                    .update({ balance: newBalance })
                    .eq('id', userId);

                if (userUpdateError) throw userUpdateError;

                // 3. Record in wallet_transactions
                const { error: transError } = await supabase
                    .from('wallet_transactions')
                    .insert([{
                        user_id: userId,
                        amount: amount,
                        type: 'credit',
                        reason: 'شحن المحفظة (فودافون كاش)',
                        balance_after: newBalance
                    }]);

                if (transError) throw transError;
            } else {
                const { error } = await supabase
                    .from('wallet_recharge_requests')
                    .update({ status: 'rejected' })
                    .eq('id', requestId);
                if (error) throw error;
            }

            fetchRequests();
        } catch (error) {
            console.error(`Error ${action}ing request:`, error);
            alert(`حدث خطأ أثناء الـ ${action === 'approve' ? 'موافقة' : 'رفض'}`);
        } finally {
            setProcessingId(null);
        }
    };

    return (
        <div className="space-y-8 animate-fade-up h-[calc(100vh-8rem)] flex flex-col">
            {/* Header */}
            <div className="flex items-end justify-between shrink-0">
                <div>
                    <h2 className="text-3xl font-black italic mb-2">طلبات شحن المحفظة</h2>
                    <p className="text-[10px] text-text-dim uppercase tracking-widest">
                        Wallet Recharge Requests & Approvals
                    </p>
                </div>
                {loading && <Loader2 className="animate-spin text-primary-gold" size={24} />}
            </div>

            {/* Content */}
            <div className="flex-1 min-h-0 bg-surface-dark border border-white/5 overflow-hidden flex flex-col">
                <div className="overflow-x-auto">
                    <table className="w-full text-right border-collapse">
                        <thead>
                            <tr className="bg-black/40 border-b border-white/10">
                                <th className="p-5 text-[10px] font-black uppercase tracking-widest text-text-dim">المستخدم</th>
                                <th className="p-5 text-[10px] font-black uppercase tracking-widest text-text-dim">المبلغ</th>
                                <th className="p-5 text-[10px] font-black uppercase tracking-widest text-text-dim">التاريخ</th>
                                <th className="p-5 text-[10px] font-black uppercase tracking-widest text-text-dim">إثبات الدفع</th>
                                <th className="p-5 text-[10px] font-black uppercase tracking-widest text-text-dim">الحالة</th>
                                <th className="p-5 text-[10px] font-black uppercase tracking-widest text-text-dim text-center">الإجراءات</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-white/5">
                            {requests.map((req) => (
                                <tr key={req.id} className="hover:bg-white/2 transition-colors group">
                                    <td className="p-5">
                                        <div className="flex flex-col">
                                            <span className="font-black text-sm text-text-main">{req.users?.full_name || 'مستخدم غير معروف'}</span>
                                            <span className="text-[10px] text-text-dim">{req.users?.phone}</span>
                                        </div>
                                    </td>
                                    <td className="p-5">
                                        <span className="font-black text-state-success">{req.amount} <small className="text-[8px] opacity-70">EGP</small></span>
                                    </td>
                                    <td className="p-5">
                                        <div className="flex flex-col">
                                            <span className="text-[10px] text-text-main font-bold">
                                                {new Date(req.created_at).toLocaleDateString('ar-EG')}
                                            </span>
                                            <span className="text-[9px] text-text-dim">
                                                {new Date(req.created_at).toLocaleTimeString('ar-EG')}
                                            </span>
                                        </div>
                                    </td>
                                    <td className="p-5">
                                        {req.screenshot_url ? (
                                            <button
                                                onClick={() => setViewScreenshot(req.screenshot_url)}
                                                className="flex items-center gap-2 text-[10px] font-black uppercase text-primary-gold hover:text-white transition-colors"
                                            >
                                                <Eye size={14} /> عرض الإيصال
                                            </button>
                                        ) : (
                                            <span className="text-[10px] text-text-dim italic">لا يوجد إيصال</span>
                                        )}
                                    </td>
                                    <td className="p-5">
                                        <span className={cn(
                                            "px-2 py-1 text-[8px] font-black uppercase tracking-wider",
                                            req.status === 'pending' ? "bg-primary-gold/10 text-primary-gold border border-primary-gold/20" :
                                                req.status === 'approved' ? "bg-state-success/10 text-state-success border border-state-success/20" :
                                                    "bg-state-error/10 text-state-error border border-state-error/20"
                                        )}>
                                            {req.status === 'pending' ? 'قيد الانتظار' :
                                                req.status === 'approved' ? 'تمت الموافقة' : 'مرفوض'}
                                        </span>
                                    </td>
                                    <td className="p-5">
                                        <div className="flex items-center justify-center gap-2">
                                            {req.status === 'pending' ? (
                                                <>
                                                    <button
                                                        disabled={processingId === req.id}
                                                        onClick={() => handleAction(req.id, req.user_id, req.amount, 'approve')}
                                                        className="w-8 h-8 flex items-center justify-center bg-state-success/20 text-state-success hover:bg-state-success hover:text-bg-black transition-all rounded"
                                                        title="موافقة"
                                                    >
                                                        {processingId === req.id ? <Loader2 size={14} className="animate-spin" /> : <Check size={16} />}
                                                    </button>
                                                    <button
                                                        disabled={processingId === req.id}
                                                        onClick={() => handleAction(req.id, req.user_id, req.amount, 'reject')}
                                                        className="w-8 h-8 flex items-center justify-center bg-state-error/20 text-state-error hover:bg-state-error hover:text-bg-black transition-all rounded"
                                                        title="رفض"
                                                    >
                                                        {processingId === req.id ? <Loader2 size={14} className="animate-spin" /> : <X size={16} />}
                                                    </button>
                                                </>
                                            ) : (
                                                <span className="text-[10px] text-text-dim opacity-50 italic">لا توجد إجراءات</span>
                                            )}
                                        </div>
                                    </td>
                                </tr>
                            ))}
                            {requests.length === 0 && !loading && (
                                <tr>
                                    <td colSpan={6} className="p-10 text-center">
                                        <div className="flex flex-col items-center gap-4 opacity-50">
                                            <AlertCircle size={32} />
                                            <p className="text-xs font-black uppercase tracking-widest">لا توجد طلبات شحن حالياً</p>
                                        </div>
                                    </td>
                                </tr>
                            )}
                        </tbody>
                    </table>
                </div>
            </div>

            {/* Screenshot Modal */}
            {viewScreenshot && (
                <div
                    className="fixed inset-0 z-50 flex items-center justify-center p-10 bg-bg-black/90 backdrop-blur-sm animate-fade-in"
                    onClick={() => setViewScreenshot(null)}
                >
                    <div className="relative max-w-4xl max-h-full border border-white/10 glass-card p-2" onClick={e => e.stopPropagation()}>
                        <button
                            onClick={() => setViewScreenshot(null)}
                            className="absolute -top-12 right-0 w-10 h-10 flex items-center justify-center bg-white/5 border border-white/10 hover:bg-white hover:text-bg-black transition-all font-black"
                        >
                            <X size={20} />
                        </button>
                        <img
                            src={viewScreenshot}
                            alt="Transaction Screenshot"
                            className="max-w-full max-h-[80vh] object-contain"
                        />
                        <div className="p-4 flex items-center justify-between">
                            <p className="text-[10px] font-black uppercase tracking-widest text-text-dim">إيصال الدفع البنكي / فودافون كاش</p>
                            <a
                                href={viewScreenshot}
                                target="_blank"
                                rel="noreferrer"
                                className="flex items-center gap-2 text-[10px] font-black uppercase text-primary-gold hover:underline"
                            >
                                <ExternalLink size={12} /> فتح في نافذة جديدة
                            </a>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
}
