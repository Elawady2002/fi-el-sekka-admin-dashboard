"use client";

import { useEffect, useState } from "react";
import { Users, Search, Filter, MoreHorizontal, Wallet, Shield, Mail, Phone, Loader2, Plus, Minus, ArrowUpRight, ArrowDownRight } from "lucide-react";
import { cn } from "@/lib/utils";
import { db } from "@/lib/database";
import { User } from "@/types/database";

export default function UserManagementPage() {
    const [users, setUsers] = useState<User[]>([]);
    const [loading, setLoading] = useState(true);
    const [searchQuery, setSearchQuery] = useState("");
    const [editingUser, setEditingUser] = useState<User | null>(null);
    const [walletAmount, setWalletAmount] = useState<number>(0);
    const [updating, setUpdating] = useState(false);

    useEffect(() => {
        async function fetchData() {
            try {
                const data = await db.getUsers();
                setUsers(data);
            } catch (error) {
                console.error("Error fetching users:", error);
            } finally {
                setLoading(false);
            }
        }
        fetchData();
    }, []);

    const handleWalletUpdate = async (type: 'add' | 'subtract') => {
        if (!editingUser || walletAmount <= 0) return;
        setUpdating(true);
        try {
            const newBalance = type === 'add'
                ? editingUser.wallet_balance + walletAmount
                : Math.max(0, editingUser.wallet_balance - walletAmount);

            await db.updateWalletBalance(editingUser.id, newBalance);

            setUsers(prev => prev.map(u => u.id === editingUser.id ? { ...u, wallet_balance: newBalance } : u));
            setEditingUser({ ...editingUser, wallet_balance: newBalance });
            setWalletAmount(0);
        } catch (error) {
            console.error("Error updating wallet:", error);
            alert("حدث خطأ أثناء تحديث المحفظة.");
        } finally {
            setUpdating(false);
        }
    };

    const filteredUsers = users.filter(user =>
        user.full_name?.includes(searchQuery) ||
        user.email?.toLowerCase().includes(searchQuery.toLowerCase()) ||
        user.phone?.includes(searchQuery)
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
                    <h1 className="text-2xl font-bold text-text-primary">إدارة المستخدمين</h1>
                    <p className="text-sm text-text-secondary">عرض بيانات المستخدمين وتعديل أرصدة المحفظة يدوياً</p>
                </div>
                <div className="flex items-center gap-3">
                    <div className="px-4 py-2 bg-surface-dark border border-border-dark rounded-xl flex items-center gap-2">
                        <Users size={18} className="text-primary-green" />
                        <span className="text-sm font-bold text-text-primary">{users.length} مستخدم</span>
                    </div>
                </div>
            </div>

            <div className="flex flex-col md:flex-row gap-4">
                <div className="relative flex-1">
                    <Search className="absolute right-3 top-1/2 -translate-y-1/2 text-text-muted" size={18} />
                    <input
                        type="text"
                        placeholder="بحث بالاسم، البريد، أو التليفون..."
                        className="w-full bg-surface-dark border border-border-dark rounded-xl py-2.5 pr-10 pl-4 text-right text-sm focus:border-primary-green transition-colors outline-none"
                        value={searchQuery}
                        onChange={(e) => setSearchQuery(e.target.value)}
                    />
                </div>
                <button className="flex items-center gap-2 px-4 py-2.5 bg-surface-dark border border-border-dark rounded-xl text-text-secondary hover:text-primary-green transition-colors">
                    <Filter size={18} />
                    <span className="text-sm">تصفية</span>
                </button>
            </div>

            <div className="grid gap-6 lg:grid-cols-3">
                {/* User List */}
                <div className="lg:col-span-2 space-y-4">
                    {filteredUsers.map((user) => (
                        <div
                            key={user.id}
                            onClick={() => setEditingUser(user)}
                            className={cn(
                                "card p-4 flex items-center justify-between cursor-pointer transition-all border-transparent",
                                editingUser?.id === user.id ? "border-primary-green bg-primary-green/5" : "hover:bg-white/2"
                            )}
                        >
                            <div className="flex items-center gap-4">
                                <div className="w-12 h-12 rounded-full bg-surface-dark border border-border-dark flex items-center justify-center text-text-secondary overflow-hidden">
                                    {user.avatar_url ? <img src={user.avatar_url} alt="" className="w-full h-full object-cover" /> : <Users size={24} />}
                                </div>
                                <div className="text-right">
                                    <h3 className="font-bold text-text-primary">{user.full_name}</h3>
                                    <div className="flex items-center gap-2 text-[10px] text-text-secondary">
                                        <span className={cn(
                                            "px-1.5 py-0.5 rounded text-[8px] font-bold uppercase",
                                            user.user_type === 'admin' ? "bg-accent-purple/10 text-accent-purple" :
                                                user.user_type === 'driver' ? "bg-accent-blue/10 text-accent-blue" : "bg-primary-green/10 text-primary-green"
                                        )}>
                                            {user.user_type}
                                        </span>
                                        <span>•</span>
                                        <span>{user.phone}</span>
                                    </div>
                                </div>
                            </div>
                            <div className="text-right">
                                <p className="text-[10px] text-text-muted">رصيد المحفظة</p>
                                <p className="font-bold text-primary-green">{user.wallet_balance?.toLocaleString()} ج.م</p>
                            </div>
                        </div>
                    ))}
                </div>

                {/* Selected User Details & Wallet Actions */}
                <div className="space-y-6">
                    {editingUser ? (
                        <div className="card p-6 sticky top-6 space-y-6">
                            <div className="text-center space-y-3">
                                <div className="w-20 h-20 rounded-full bg-primary-green/10 border-2 border-primary-green/20 mx-auto flex items-center justify-center text-primary-green">
                                    {editingUser.avatar_url ? <img src={editingUser.avatar_url} alt="" className="w-full h-full rounded-full object-cover" /> : <Users size={40} />}
                                </div>
                                <div>
                                    <h2 className="text-xl font-bold text-text-primary">{editingUser.full_name}</h2>
                                    <p className="text-sm text-text-secondary">{editingUser.email}</p>
                                </div>
                            </div>

                            <div className="grid grid-cols-2 gap-4">
                                <div className="p-3 bg-surface-dark rounded-xl border border-border-dark text-center">
                                    <p className="text-[10px] text-text-muted mb-1">الرصيد الحالي</p>
                                    <p className="text-lg font-bold text-primary-green">{editingUser.wallet_balance} ج.م</p>
                                </div>
                                <div className="p-3 bg-surface-dark rounded-xl border border-border-dark text-center">
                                    <p className="text-[10px] text-text-muted mb-1">الحالة</p>
                                    <p className="text-sm font-bold text-accent-green">نشط</p>
                                </div>
                            </div>

                            <div className="space-y-4 pt-4 border-t border-border-dark">
                                <h4 className="text-sm font-bold text-text-primary">تعديل الرصيد يدوياً</h4>
                                <div className="relative">
                                    <Wallet className="absolute right-3 top-1/2 -translate-y-1/2 text-text-muted" size={18} />
                                    <input
                                        type="number"
                                        placeholder="أدخل المبلغ..."
                                        className="w-full bg-black border border-border-dark rounded-xl py-3 pr-10 pl-4 text-left font-mono focus:border-primary-green transition-colors outline-none"
                                        value={walletAmount || ''}
                                        onChange={(e) => setWalletAmount(Number(e.target.value))}
                                    />
                                </div>
                                <div className="grid grid-cols-2 gap-3">
                                    <button
                                        disabled={updating || walletAmount <= 0}
                                        onClick={() => handleWalletUpdate('add')}
                                        className="flex items-center justify-center gap-2 py-3 bg-accent-green/10 text-accent-green border border-accent-green/20 rounded-xl hover:bg-accent-green/20 transition-colors"
                                    >
                                        {updating ? <Loader2 className="animate-spin" size={18} /> : <Plus size={18} />}
                                        <span className="font-bold text-sm">إضافة</span>
                                    </button>
                                    <button
                                        disabled={updating || walletAmount <= 0}
                                        onClick={() => handleWalletUpdate('subtract')}
                                        className="flex items-center justify-center gap-2 py-3 bg-accent-red/10 text-accent-red border border-accent-red/20 rounded-xl hover:bg-accent-red/20 transition-colors"
                                    >
                                        {updating ? <Loader2 className="animate-spin" size={18} /> : <Minus size={18} />}
                                        <span className="font-bold text-sm">خصم</span>
                                    </button>
                                </div>
                            </div>

                            <div className="space-y-3 pt-4 border-t border-border-dark">
                                <button className="w-full flex items-center justify-between p-3 rounded-xl hover:bg-white/5 text-text-secondary transition-colors text-sm">
                                    <div className="flex items-center gap-3">
                                        <Phone size={18} />
                                        <span>اتصال هاتفي</span>
                                    </div>
                                </button>
                                <button className="w-full flex items-center justify-between p-3 rounded-xl hover:bg-white/5 text-text-secondary transition-colors text-sm">
                                    <div className="flex items-center gap-3">
                                        <Shield size={18} />
                                        <span>تغيير الصلاحيات</span>
                                    </div>
                                </button>
                            </div>
                        </div>
                    ) : (
                        <div className="card p-12 text-center text-text-secondary border-dashed border-2 border-border-dark flex flex-col items-center gap-4">
                            <Users size={48} className="text-text-muted opacity-20" />
                            <p>اختر مستخدم من القائمة لعرض التفاصيل وتعديل الرصيد</p>
                        </div>
                    )}
                </div>
            </div>
        </div>
    );
}
