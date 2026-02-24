"use client";

import { useState, useEffect } from "react";
import {
    Users,
    Search,
    Filter,
    MoreVertical,
    UserPlus,
    Shield,
    Truck,
    Building2,
    Loader2,
    Mail,
    Phone,
    Wallet,
    Calendar,
    ArrowUpRight,
    Edit2,
    Trash2
} from "lucide-react";
import { cn } from "@/lib/utils";
import { supabase } from "@/lib/supabase";

type UserRole = 'user' | 'driver' | 'office' | 'supervisor' | 'all';

interface User {
    id: string;
    full_name: string;
    phone: string;
    email: string;
    role: UserRole;
    wallet_balance: number;
    created_at: string;
}

export default function UsersPage() {
    const [users, setUsers] = useState<User[]>([]);
    const [loading, setLoading] = useState(true);
    const [searchQuery, setSearchQuery] = useState("");
    const [activeTab, setActiveTab] = useState<UserRole>('user');
    const [error, setError] = useState<string | null>(null);

    const fetchData = async () => {
        setLoading(true);
        setError(null);
        try {
            // Start with a base query
            let query = supabase.from('users').select('*');

            // Only filter by role if it's not 'all'
            if (activeTab !== 'all') {
                query = query.eq('role', activeTab);
            }

            const { data, error: queryError } = await query.order('created_at', { ascending: false });

            if (queryError) {
                // FALLBACK: If filtering by role fails (e.g. column doesn't exist yet)
                if (queryError.message.includes('column "role" does not exist')) {
                    console.warn("Role column missing, fetching all users as fallback");
                    const { data: allData, error: allErr } = await supabase
                        .from('users')
                        .select('*')
                        .order('created_at', { ascending: false });

                    if (allErr) throw allErr;
                    setUsers(allData || []);
                    return;
                }
                throw queryError;
            }

            setUsers(data || []);
        } catch (err: any) {
            console.error("Detailed Fetch Error:", {
                message: err.message,
                details: err.details,
                hint: err.hint,
                code: err.code,
                full: err
            });
            setError(err.message || "حدث خطأ أثناء الاتصال بقاعدة البيانات");
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchData();
    }, [activeTab]);

    const filteredUsers = users.filter(user =>
        user.full_name?.toLowerCase().includes(searchQuery.toLowerCase()) ||
        user.phone?.includes(searchQuery) ||
        user.email?.toLowerCase().includes(searchQuery.toLowerCase())
    );

    const tabs = [
        { id: 'user', label: 'مستخدمي التطبيق', icon: Users },
        { id: 'driver', label: 'السائقين', icon: Truck },
        { id: 'office', label: 'المكاتب', icon: Building2 },
        { id: 'supervisor', label: 'المشرفين', icon: Shield },
        { id: 'all', label: 'الكل', icon: Filter },
    ];

    const getRoleBadge = (role: string) => {
        switch (role) {
            case 'driver': return { label: 'سائق', class: 'bg-blue-500/10 text-blue-500 border-blue-500/20' };
            case 'office': return { label: 'مكتب', class: 'bg-purple-500/10 text-purple-500 border-purple-500/20' };
            case 'supervisor': return { label: 'مشرف', class: 'bg-red-500/10 text-red-500 border-red-500/20' };
            default: return { label: 'مستخدم', class: 'bg-state-success/10 text-state-success border-state-success/20' };
        }
    };

    return (
        <div className="space-y-8 animate-fade-up">
            {/* Header */}
            <div className="flex items-end justify-between">
                <div>
                    <h2 className="text-3xl font-black italic">إدارة المستخدمين</h2>
                    <p className="text-[10px] text-text-dim uppercase tracking-widest mt-1">
                        {activeTab === 'user' ? "Application Users Management" :
                            activeTab === 'driver' ? "Fleet Drivers Management" :
                                "System Staff & Resources"}
                    </p>
                </div>
                <button className="flex items-center gap-2 px-6 py-3 bg-primary-gold text-bg-black text-[10px] font-black uppercase tracking-widest hover:bg-white transition-all shadow-[0_0_20px_rgba(234,179,8,0.2)]">
                    <UserPlus size={14} /> إضاة مستخدم جديد
                </button>
            </div>

            {/* Stats Summary (Conditional based on tab) */}
            <div className="grid grid-cols-4 gap-4">
                <div className="glass-card p-6 flex flex-col justify-between h-32">
                    <p className="text-[10px] font-black uppercase text-text-dim tracking-wider">إجمالي {tabs.find(t => t.id === activeTab)?.label}</p>
                    <div className="flex items-end justify-between">
                        <h3 className="text-3xl font-black leading-none">{filteredUsers.length}</h3>
                        <Users size={20} className="text-primary-gold opacity-50" />
                    </div>
                </div>
                <div className="glass-card p-6 flex flex-col justify-between h-32">
                    <p className="text-[10px] font-black uppercase text-text-dim tracking-wider">نشط اليوم</p>
                    <div className="flex items-end justify-between">
                        <h3 className="text-3xl font-black leading-none">{Math.floor(filteredUsers.length * 0.4)}</h3>
                        <div className="w-2 h-2 rounded-full bg-state-success animate-pulse" />
                    </div>
                </div>
                {activeTab === 'user' && (
                    <div className="glass-card p-6 flex flex-col justify-between h-32 text-primary-gold">
                        <p className="text-[10px] font-black uppercase tracking-wider opacity-70">إجمالي أرصدة المحافظ</p>
                        <h3 className="text-2xl font-black leading-none">
                            {filteredUsers.reduce((sum, u) => sum + (u.wallet_balance || 0), 0).toLocaleString()}
                            <small className="text-[10px] ml-1 opacity-50 font-bold uppercase">EGP</small>
                        </h3>
                    </div>
                )}
            </div>

            {/* Tabs & Search */}
            <div className="flex flex-col gap-6">
                <div className="flex items-center justify-between border-b border-white/5 pb-1">
                    <div className="flex gap-8">
                        {tabs.map((tab) => (
                            <button
                                key={tab.id}
                                onClick={() => setActiveTab(tab.id as UserRole)}
                                className={cn(
                                    "pb-4 text-[10px] font-black uppercase tracking-widest transition-all relative group",
                                    activeTab === tab.id ? "text-primary-gold" : "text-text-dim hover:text-white"
                                )}
                            >
                                <span className="flex items-center gap-2">
                                    <tab.icon size={14} />
                                    {tab.label}
                                </span>
                                {activeTab === tab.id && (
                                    <div className="absolute bottom-0 left-0 w-full h-[2px] bg-primary-gold shadow-[0_0_10px_#EAB308]" />
                                )}
                            </button>
                        ))}
                    </div>
                </div>

                <div className="flex items-center gap-4">
                    <div className="relative flex-1 group">
                        <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-text-dim group-focus-within:text-primary-gold transition-colors" size={18} />
                        <input
                            type="text"
                            placeholder="بحث بالاسم، رقم الهاتف أو البريد..."
                            className="w-full bg-white/5 border border-white/5 px-12 py-4 text-sm focus:outline-none focus:border-primary-gold/50 transition-all font-medium"
                            value={searchQuery}
                            onChange={(e) => setSearchQuery(e.target.value)}
                        />
                    </div>
                    <button className="w-14 h-14 flex items-center justify-center bg-white/5 border border-white/5 text-text-dim hover:text-white transition-all">
                        <Filter size={20} />
                    </button>
                </div>
            </div>

            {/* Users Table */}
            <div className="bg-surface-dark border border-white/5 min-h-[500px] relative">
                {loading ? (
                    <div className="absolute inset-0 flex items-center justify-center bg-bg-black/20 backdrop-blur-[2px]">
                        <Loader2 className="animate-spin text-primary-gold" size={32} />
                    </div>
                ) : (
                    <table className="w-full text-right">
                        <thead>
                            <tr className="bg-white/2 border-b border-white/5">
                                <th className="p-5 text-[10px] font-black uppercase tracking-widest text-text-dim">المستخدم</th>
                                <th className="p-5 text-[10px] font-black uppercase tracking-widest text-text-dim">بيانات الاتصال</th>
                                <th className="p-5 text-[10px] font-black uppercase tracking-widest text-text-dim">الرصيد</th>
                                <th className="p-5 text-[10px] font-black uppercase tracking-widest text-text-dim">تارخ الانضمام</th>
                                <th className="p-5 text-[10px] font-black uppercase tracking-widest text-text-dim">الحالة</th>
                                <th className="p-5 text-[10px] font-black uppercase tracking-widest text-text-dim"></th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-white/5">
                            {filteredUsers.map((user) => (
                                <tr key={user.id} className="hover:bg-white/2 transition-all group">
                                    <td className="p-5">
                                        <div className="flex items-center gap-4">
                                            <div className="w-10 h-10 bg-primary-gold/10 border border-primary-gold/20 flex items-center justify-center text-primary-gold font-black text-xs">
                                                {user.full_name?.split(' ').map(n => n[0]).join('').slice(0, 2).toUpperCase()}
                                            </div>
                                            <div>
                                                <p className="text-sm font-black group-hover:text-primary-gold transition-colors">{user.full_name || 'بدون اسم'}</p>
                                                <p className="text-[10px] text-text-dim uppercase tracking-tighter">ID: {user.id.slice(0, 8)}</p>
                                            </div>
                                        </div>
                                    </td>
                                    <td className="p-5">
                                        <div className="space-y-1">
                                            <div className="flex items-center gap-2 text-xs text-text-main">
                                                <Phone size={12} className="text-text-dim" /> {user.phone}
                                            </div>
                                            <div className="flex items-center gap-2 text-[10px] text-text-dim">
                                                <Mail size={12} /> {user.email || '—'}
                                            </div>
                                        </div>
                                    </td>
                                    <td className="p-5">
                                        <div className="flex items-center gap-2 font-black text-sm">
                                            <Wallet size={14} className="text-primary-gold" />
                                            {user.wallet_balance || 0}
                                            <small className="text-[8px] text-text-dim">EGP</small>
                                        </div>
                                    </td>
                                    <td className="p-5">
                                        <div className="flex items-center gap-2 text-xs text-text-dim">
                                            <Calendar size={14} />
                                            {new Date(user.created_at).toLocaleDateString('ar-EG')}
                                        </div>
                                    </td>
                                    <td className="p-5">
                                        <div className={cn(
                                            "inline-flex px-3 py-1 text-[8px] font-black uppercase border",
                                            getRoleBadge(user.role).class
                                        )}>
                                            {getRoleBadge(user.role).label}
                                        </div>
                                    </td>
                                    <td className="p-5 text-left">
                                        <div className="flex items-center justify-end gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                                            <button className="w-8 h-8 flex items-center justify-center bg-white/5 border border-white/5 hover:bg-white/20 transition-all text-white">
                                                <Edit2 size={14} />
                                            </button>
                                            <button className="w-8 h-8 flex items-center justify-center bg-state-error/10 border border-state-error/20 hover:bg-state-error text-state-error hover:text-bg-black transition-all">
                                                <Trash2 size={14} />
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            ))}
                            {!loading && filteredUsers.length === 0 && (
                                <tr>
                                    <td colSpan={6} className="p-20 text-center opacity-30">
                                        <Users size={48} className="mx-auto mb-4" />
                                        <p className="text-[10px] font-black uppercase tracking-widest">لا يوجد مستخدمين لعرضهم</p>
                                    </td>
                                </tr>
                            )}
                        </tbody>
                    </table>
                )}
            </div>
        </div>
    );
}
