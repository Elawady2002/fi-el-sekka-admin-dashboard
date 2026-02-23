"use client";

import { useState, useEffect } from "react";
import {
    Check,
    X,
    Clock,
    Banknote,
    Eye,
    Loader2,
    AlertCircle,
    ExternalLink,
    ArrowUpRight,
    ArrowDownRight,
    RefreshCw,
    Filter
} from "lucide-react";
import { cn } from "@/lib/utils";
import { supabase } from "@/lib/supabase";

type WalletTransaction = {
    id: string;
    user_id: string;
    amount: number;
    type: string; // 'debit' | 'credit'
    reason: string;
    balance_after: number;
    created_at: string;
    users?: {
        full_name: string;
        phone: string;
        email: string;
        wallet_balance: number;
    };
};

export default function WalletPage() {
    const [transactions, setTransactions] = useState<WalletTransaction[]>([]);
    const [loading, setLoading] = useState(true);
    const [filterType, setFilterType] = useState<'all' | 'credit' | 'debit'>('all');

    const fetchTransactions = async () => {
        setLoading(true);
        try {
            let query = supabase
                .from('wallet_transactions')
                .select(`
                    *,
                    users (
                        full_name,
                        phone,
                        email,
                        wallet_balance
                    )
                `)
                .order('created_at', { ascending: false });

            if (filterType !== 'all') {
                query = query.eq('type', filterType);
            }

            const { data, error } = await query;
            if (error) throw error;
            setTransactions(data as any || []);
        } catch (error) {
            console.error("Error fetching transactions:", error);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchTransactions();
    }, [filterType]);

    const totalCredit = transactions.filter(t => t.type === 'credit').reduce((acc, t) => acc + t.amount, 0);
    const totalDebit = transactions.filter(t => t.type === 'debit').reduce((acc, t) => acc + t.amount, 0);

    return (
        <div className="space-y-8 animate-fade-up h-[calc(100vh-8rem)] flex flex-col">
            {/* Header */}
            <div className="flex items-end justify-between shrink-0">
                <div>
                    <h2 className="text-3xl font-black italic mb-2">سجل عمليات المحفظة</h2>
                    <p className="text-[10px] text-text-dim uppercase tracking-widest">
                        Wallet Transactions History
                    </p>
                </div>
                <div className="flex items-center gap-3">
                    {loading && <Loader2 className="animate-spin text-primary-gold" size={24} />}
                    <button
                        onClick={fetchTransactions}
                        className="w-10 h-10 flex items-center justify-center border border-white/10 hover:bg-white/5 text-text-dim hover:text-white transition-all"
                        title="تحديث"
                    >
                        <RefreshCw size={16} />
                    </button>
                </div>
            </div>

            {/* Stats Cards */}
            <div className="grid grid-cols-3 gap-4 shrink-0">
                <div className="glass-card p-6 flex flex-col justify-between h-28">
                    <p className="text-[10px] font-black uppercase text-text-dim tracking-wider">إجمالي العمليات</p>
                    <h3 className="text-2xl font-black leading-none">{transactions.length}</h3>
                </div>
                <div className="glass-card p-6 flex flex-col justify-between h-28">
                    <p className="text-[10px] font-black uppercase text-state-success tracking-wider flex items-center gap-1">
                        <ArrowUpRight size={12} /> إجمالي الشحن (Credit)
                    </p>
                    <h3 className="text-2xl font-black leading-none text-state-success">{totalCredit} <small className="text-xs opacity-50">EGP</small></h3>
                </div>
                <div className="glass-card p-6 flex flex-col justify-between h-28">
                    <p className="text-[10px] font-black uppercase text-state-error tracking-wider flex items-center gap-1">
                        <ArrowDownRight size={12} /> إجمالي الخصم (Debit)
                    </p>
                    <h3 className="text-2xl font-black leading-none text-state-error">{totalDebit} <small className="text-xs opacity-50">EGP</small></h3>
                </div>
            </div>

            {/* Filter Tabs */}
            <div className="flex items-center gap-2 shrink-0">
                <Filter size={14} className="text-text-dim" />
                {(['all', 'credit', 'debit'] as const).map(type => (
                    <button
                        key={type}
                        onClick={() => setFilterType(type)}
                        className={cn(
                            "px-4 py-2 text-[10px] font-black uppercase tracking-widest border transition-all",
                            filterType === type
                                ? "bg-primary-gold text-bg-black border-primary-gold"
                                : "bg-transparent text-text-dim border-white/10 hover:border-white/30 hover:text-white"
                        )}
                    >
                        {type === 'all' ? 'الكل' : type === 'credit' ? 'شحن (Credit)' : 'خصم (Debit)'}
                    </button>
                ))}
            </div>

            {/* Table */}
            <div className="flex-1 min-h-0 bg-surface-dark border border-white/5 overflow-hidden flex flex-col">
                <div className="overflow-y-auto flex-1">
                    <table className="w-full text-right border-collapse">
                        <thead className="sticky top-0 z-10">
                            <tr className="bg-black/60 backdrop-blur-sm border-b border-white/10">
                                <th className="p-5 text-[10px] font-black uppercase tracking-widest text-text-dim">المستخدم</th>
                                <th className="p-5 text-[10px] font-black uppercase tracking-widest text-text-dim">النوع</th>
                                <th className="p-5 text-[10px] font-black uppercase tracking-widest text-text-dim">المبلغ</th>
                                <th className="p-5 text-[10px] font-black uppercase tracking-widest text-text-dim">السبب</th>
                                <th className="p-5 text-[10px] font-black uppercase tracking-widest text-text-dim">الرصيد بعد</th>
                                <th className="p-5 text-[10px] font-black uppercase tracking-widest text-text-dim">التاريخ</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-white/5">
                            {transactions.map((tx) => (
                                <tr key={tx.id} className="hover:bg-white/[0.02] transition-colors">
                                    <td className="p-5">
                                        <div className="flex flex-col">
                                            <span className="font-black text-sm text-text-main">{tx.users?.full_name || 'مستخدم غير معروف'}</span>
                                            <span className="text-[10px] text-text-dim">{tx.users?.phone || tx.users?.email || '—'}</span>
                                        </div>
                                    </td>
                                    <td className="p-5">
                                        <span className={cn(
                                            "px-3 py-1.5 text-[8px] font-black uppercase tracking-wider inline-flex items-center gap-1",
                                            tx.type === 'credit'
                                                ? "bg-state-success/10 text-state-success border border-state-success/20"
                                                : "bg-state-error/10 text-state-error border border-state-error/20"
                                        )}>
                                            {tx.type === 'credit' ? <ArrowUpRight size={10} /> : <ArrowDownRight size={10} />}
                                            {tx.type === 'credit' ? 'شحن' : 'خصم'}
                                        </span>
                                    </td>
                                    <td className="p-5">
                                        <span className={cn(
                                            "font-black text-sm",
                                            tx.type === 'credit' ? "text-state-success" : "text-state-error"
                                        )}>
                                            {tx.type === 'credit' ? '+' : '-'}{tx.amount} <small className="text-[8px] opacity-70">EGP</small>
                                        </span>
                                    </td>
                                    <td className="p-5">
                                        <span className="text-xs text-text-main">{tx.reason}</span>
                                    </td>
                                    <td className="p-5">
                                        <span className="font-black text-sm text-primary-gold">
                                            {tx.balance_after} <small className="text-[8px] opacity-50">EGP</small>
                                        </span>
                                    </td>
                                    <td className="p-5">
                                        <div className="flex flex-col">
                                            <span className="text-[10px] text-text-main font-bold">
                                                {new Date(tx.created_at).toLocaleDateString('ar-EG')}
                                            </span>
                                            <span className="text-[9px] text-text-dim">
                                                {new Date(tx.created_at).toLocaleTimeString('ar-EG')}
                                            </span>
                                        </div>
                                    </td>
                                </tr>
                            ))}
                            {transactions.length === 0 && !loading && (
                                <tr>
                                    <td colSpan={6} className="p-10 text-center">
                                        <div className="flex flex-col items-center gap-4 opacity-50">
                                            <AlertCircle size={32} />
                                            <p className="text-xs font-black uppercase tracking-widest">لا توجد عمليات في المحفظة حالياً</p>
                                        </div>
                                    </td>
                                </tr>
                            )}
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    );
}
