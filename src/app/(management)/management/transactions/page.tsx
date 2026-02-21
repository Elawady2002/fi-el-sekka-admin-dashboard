"use client";

import { useEffect, useState } from "react";
import { CreditCard, Search, Filter, Loader2, ArrowUpRight, ArrowDownRight, User } from "lucide-react";
import { cn } from "@/lib/utils";
import { supabase } from "@/lib/supabase";

export default function TransactionsPage() {
    const [transactions, setTransactions] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [searchQuery, setSearchQuery] = useState("");

    useEffect(() => {
        async function fetchData() {
            try {
                const { data, error } = await supabase
                    .from('wallet_transactions')
                    .select('*, users:user_id(full_name, phone)')
                    .order('created_at', { ascending: false });
                if (error) throw error;
                setTransactions(data || []);
            } catch (error) {
                console.error("Error fetching transactions:", error);
            } finally {
                setLoading(false);
            }
        }
        fetchData();
    }, []);

    const filteredTransactions = transactions.filter(tx =>
        tx.users?.full_name?.includes(searchQuery) ||
        tx.reason?.includes(searchQuery)
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
                    <h1 className="text-2xl font-bold text-text-primary">سجل العمليات</h1>
                    <p className="text-sm text-text-secondary">متابعة كافة حركات المحفظة والعمليات المالية</p>
                </div>
            </div>

            <div className="relative">
                <Search className="absolute right-3 top-1/2 -translate-y-1/2 text-text-muted" size={18} />
                <input
                    type="text"
                    placeholder="بحث باسم العميل أو سبب العملية..."
                    className="w-full bg-surface-dark border border-border-dark rounded-xl py-2.5 pr-10 pl-4 text-right text-sm focus:border-primary-green transition-colors outline-none"
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                />
            </div>

            <div className="card overflow-hidden">
                <table className="w-full text-right text-sm">
                    <thead>
                        <tr className="bg-white/5 text-text-muted border-b border-border-dark">
                            <th className="p-4 font-bold">العميل</th>
                            <th className="p-4 font-bold">النوع</th>
                            <th className="p-4 font-bold">المبلغ</th>
                            <th className="p-4 font-bold">السبب</th>
                            <th className="p-4 font-bold">التاريخ</th>
                        </tr>
                    </thead>
                    <tbody>
                        {filteredTransactions.map((tx) => (
                            <tr key={tx.id} className="border-b border-border-dark/50 hover:bg-white/2 transition-colors">
                                <td className="p-4">
                                    <div className="flex items-center gap-3">
                                        <div className="w-8 h-8 rounded-full bg-surface-dark border border-border-dark flex items-center justify-center text-text-muted">
                                            <User size={16} />
                                        </div>
                                        <div>
                                            <p className="font-bold text-text-primary">{tx.users?.full_name || 'مستخدم'}</p>
                                            <p className="text-[10px] text-text-secondary">{tx.users?.phone}</p>
                                        </div>
                                    </div>
                                </td>
                                <td className="p-4">
                                    <span className={cn(
                                        "px-2 py-1 rounded text-[10px] font-bold",
                                        tx.type === 'deposit' ? "bg-accent-green/10 text-accent-green" : "bg-accent-red/10 text-accent-red"
                                    )}>
                                        {tx.type === 'deposit' ? 'إيداع' : 'سحب'}
                                    </span>
                                </td>
                                <td className="p-4 font-bold text-text-primary">
                                    {tx.amount} ج.م
                                </td>
                                <td className="p-4 text-text-secondary text-xs">
                                    {tx.reason || 'لا يوجد'}
                                </td>
                                <td className="p-4 text-text-muted text-[10px]">
                                    {new Date(tx.created_at).toLocaleString('ar-EG')}
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
                {filteredTransactions.length === 0 && (
                    <div className="p-12 text-center text-text-secondary italic">
                        لا توجد عمليات مسجلة حالياً.
                    </div>
                )}
            </div>
        </div>
    );
}
