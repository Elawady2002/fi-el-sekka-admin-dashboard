"use client";

import { useEffect, useState } from "react";
import { Plus, GraduationCap, Search, Edit2, Trash2, MapPin, Loader2, CheckCircle2, XCircle, X, School } from "lucide-react";
import { cn } from "@/lib/utils";
import { db } from "@/lib/database";
import { University, Route } from "@/types/database";

export default function UniversityLinesPage() {
    const [universities, setUniversities] = useState<University[]>([]);
    const [routes, setRoutes] = useState<Route[]>([]);
    const [loading, setLoading] = useState(true);
    const [searchQuery, setSearchQuery] = useState("");

    // Modal States
    const [modal, setModal] = useState<{ open: boolean; university?: University }>({ open: false });

    async function fetchData() {
        try {
            const [uniData, routesData] = await Promise.all([
                db.getUniversities(),
                db.getRoutes()
            ]);
            setUniversities(uniData);
            setRoutes(routesData);
        } catch (error) {
            console.error("Error fetching data:", error);
        } finally {
            setLoading(false);
        }
    }

    useEffect(() => {
        fetchData();
    }, []);

    const filteredUniversities = universities.filter(uni =>
        uni.name_ar.includes(searchQuery) ||
        uni.name_en.toLowerCase().includes(searchQuery.toLowerCase())
    );

    const getRouteCount = (uniId: string) => {
        return routes.filter(r => r.university_id === uniId).length;
    };

    const handleDelete = async (id: string) => {
        if (!confirm("هل أنت متأكد من حذف هذه الجامعة؟ قد يؤثر ذلك على المسارات المرتبطة بها.")) return;
        try {
            // Logic to delete university (would need db.deleteUniversity)
            alert("خاصية الحذف سيتم تفعيلها قريباً");
        } catch (error) {
            alert("حدث خطأ");
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
            {/* Header */}
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-text-primary">خطوط الجامعات</h1>
                    <p className="text-sm text-text-secondary">إدارة وجهات الجامعات الشريكة وتتبع المسارات المخصصة لكل جامعة</p>
                </div>
                <button
                    onClick={() => setModal({ open: true })}
                    className="btn-primary"
                >
                    <Plus size={18} />
                    <span>إضافة جامعة جديدة</span>
                </button>
            </div>

            {/* Search */}
            <div className="relative">
                <Search className="absolute right-3 top-1/2 -translate-y-1/2 text-text-muted" size={18} />
                <input
                    type="text"
                    placeholder="بحث عن جامعة..."
                    className="w-full bg-surface-dark border border-border-dark rounded-xl py-2.5 pr-10 pl-4 text-right text-sm focus:border-primary-green transition-colors outline-none"
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                />
            </div>

            {/* Universities Grid */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {filteredUniversities.map((uni) => (
                    <div key={uni.id} className="card p-5 group hover:border-primary-green/30 transition-all hover:shadow-lg hover:shadow-primary-green/5">
                        <div className="flex items-start justify-between mb-4">
                            <div className="w-12 h-12 rounded-2xl bg-accent-purple/10 flex items-center justify-center text-accent-purple group-hover:scale-110 transition-transform">
                                <School size={24} />
                            </div>
                            <div className={cn(
                                "px-3 py-1 rounded-full text-[10px] font-bold flex items-center gap-1.5",
                                uni.is_active ? "bg-accent-green/10 text-accent-green" : "bg-accent-red/10 text-accent-red"
                            )}>
                                <div className={cn("w-1.5 h-1.5 rounded-full animate-pulse", uni.is_active ? "bg-accent-green" : "bg-accent-red")} />
                                {uni.is_active ? 'نشط' : 'متوقف'}
                            </div>
                        </div>

                        <div className="space-y-1.5 mb-6">
                            <h3 className="font-bold text-text-primary text-lg">{uni.name_ar}</h3>
                            <p className="text-xs text-text-secondary font-mono">{uni.name_en}</p>
                            <div className="flex items-center gap-2 mt-3">
                                <span className="text-[10px] bg-white/5 border border-border-dark px-2.5 py-1 rounded-lg font-bold text-text-primary">
                                    {getRouteCount(uni.id)} مسارات
                                </span>
                            </div>
                        </div>

                        <div className="flex items-center justify-between pt-4 border-t border-border-dark/30">
                            <div className="flex items-center gap-1.5 text-text-muted text-xs hover:text-primary-green cursor-pointer transition-colors">
                                <MapPin size={14} />
                                <span>الموقع الجغرافي</span>
                            </div>
                            <div className="flex items-center gap-2">
                                <button
                                    onClick={() => setModal({ open: true, university: uni })}
                                    className="p-2 hover:bg-white/5 rounded-lg text-text-secondary hover:text-primary-green transition-colors"
                                >
                                    <Edit2 size={16} />
                                </button>
                                <button
                                    onClick={() => handleDelete(uni.id)}
                                    className="p-2 hover:bg-white/5 rounded-lg text-text-secondary hover:text-accent-red transition-colors"
                                >
                                    <Trash2 size={16} />
                                </button>
                            </div>
                        </div>
                    </div>
                ))}
            </div>

            {/* University Modal */}
            {modal.open && (
                <div className="fixed inset-0 z-100 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm">
                    <div className="bg-surface-dark border border-border-dark rounded-2xl w-full max-w-md p-6 space-y-6 shadow-2xl text-right">
                        <div className="flex items-center justify-between">
                            <button onClick={() => setModal({ open: false })} className="text-text-muted hover:text-white">
                                <X size={20} />
                            </button>
                            <h2 className="text-xl font-bold text-white">{modal.university ? 'تعديل بيانات الجامعة' : 'إضافة جامعة جديدة'}</h2>
                        </div>

                        <form className="space-y-4" onSubmit={async (e) => {
                            e.preventDefault();
                            alert("خاصية التعديل والإضافة سيتم تفعيلها قريباً");
                            setModal({ open: false });
                        }}>
                            <div className="space-y-1.5">
                                <label className="text-xs text-text-secondary">اسم الجامعة بالعربية</label>
                                <input name="name_ar" required defaultValue={modal.university?.name_ar} className="w-full bg-white/5 border border-border-dark rounded-xl py-2 px-4 text-right outline-none focus:border-primary-green" placeholder="مثال: الجامعة الألمانية" />
                            </div>
                            <div className="space-y-1.5">
                                <label className="text-xs text-text-secondary italic">University Name (English)</label>
                                <input name="name_en" required defaultValue={modal.university?.name_en} className="w-full bg-white/5 border border-border-dark rounded-xl py-2 px-4 text-left outline-none focus:border-primary-green font-mono" placeholder="Ex: GUC" />
                            </div>
                            <button className="btn-primary w-full py-3 mt-4">حفظ البيانات</button>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}
