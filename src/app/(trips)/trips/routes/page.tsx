"use client";

import { useEffect, useState } from "react";
import { Plus, Bus, Search, Edit2, Trash2, Clock, MapPin, ChevronRight, Loader2, X, ArrowRight, ArrowLeft } from "lucide-react";
import { cn } from "@/lib/utils";
import { db } from "@/lib/database";
import { Route, Station, University } from "@/types/database";

export default function RoutesPage() {
    const [routes, setRoutes] = useState<Route[]>([]);
    const [stations, setStations] = useState<Station[]>([]);
    const [universities, setUniversities] = useState<University[]>([]);
    const [loading, setLoading] = useState(true);
    const [searchQuery, setSearchQuery] = useState("");

    // Modal States
    const [modal, setModal] = useState<{ open: boolean; route?: Route }>({ open: false });

    async function fetchData() {
        try {
            const [routesData, stationsData, uniData] = await Promise.all([
                db.getRoutes(),
                db.getStations(),
                db.getUniversities()
            ]);
            setRoutes(routesData);
            setStations(stationsData);
            setUniversities(uniData);
        } catch (error) {
            console.error("Error fetching data:", error);
        } finally {
            setLoading(false);
        }
    }

    useEffect(() => {
        fetchData();
    }, []);

    const filteredRoutes = routes.filter(route =>
        route.route_name_ar.includes(searchQuery) ||
        route.universities?.name_ar.includes(searchQuery) ||
        route.route_code.includes(searchQuery)
    );

    const getStationName = (id: string) => {
        return stations.find(s => s.id === id)?.name_ar || "محطة غير معروفة";
    };

    const handleDelete = async (id: string) => {
        if (!confirm("هل أنت متأكد من حذف هذا المسار؟")) return;
        try {
            await db.deleteRoute(id);
            setRoutes(prev => prev.filter(r => r.id !== id));
        } catch (error) {
            alert("حدث خطأ أثناء الحذف");
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
                    <h1 className="text-2xl font-bold text-text-primary">المسارات والخطوط</h1>
                    <p className="text-sm text-text-secondary">إدارة رحلات النقل المباشرة وبناء المسارات من محطة إلى محطة</p>
                </div>
                <button
                    onClick={() => setModal({ open: true })}
                    className="btn-primary"
                >
                    <Plus size={18} />
                    <span>إضافة مسار جديد</span>
                </button>
            </div>

            {/* Search */}
            <div className="relative">
                <Search className="absolute right-3 top-1/2 -translate-y-1/2 text-text-muted" size={18} />
                <input
                    type="text"
                    placeholder="بحث عن مسار، جامعة، أو كود..."
                    className="w-full bg-surface-dark border border-border-dark rounded-xl py-2.5 pr-10 pl-4 text-right text-sm focus:border-primary-green transition-colors outline-none"
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                />
            </div>

            {/* Routes List */}
            <div className="grid gap-6">
                {filteredRoutes.map((route) => (
                    <div key={route.id} className="card p-5 space-y-5 border-border-dark hover:border-primary-green/20 transition-all">
                        <div className="flex items-center justify-between">
                            <div className="flex items-center gap-4">
                                <div className="w-12 h-12 rounded-xl bg-primary-green/10 flex items-center justify-center text-primary-green">
                                    <Bus size={24} />
                                </div>
                                <div className="text-right">
                                    <h3 className="text-lg font-bold text-text-primary">{route.route_name_ar}</h3>
                                    <div className="flex items-center gap-2 text-xs text-text-secondary mt-1">
                                        <span className="text-primary-green font-bold bg-primary-green/5 px-1.5 py-0.5 rounded">{route.route_code}</span>
                                        <span className="text-text-muted">•</span>
                                        <span className="font-medium">{route.universities?.name_ar || 'مسار عام'}</span>
                                        <span className="text-text-muted">•</span>
                                        <span>{route.stations_order.length} محطات</span>
                                    </div>
                                </div>
                            </div>
                            <div className="flex items-center gap-2">
                                <button
                                    onClick={() => setModal({ open: true, route })}
                                    className="p-2.5 bg-surface-dark border border-border-dark rounded-xl text-text-secondary hover:text-primary-green hover:border-primary-green/30 transition-all"
                                >
                                    <Edit2 size={18} />
                                </button>
                                <button
                                    onClick={() => handleDelete(route.id)}
                                    className="p-2.5 bg-surface-dark border border-border-dark rounded-xl text-text-secondary hover:text-accent-red hover:border-accent-red/30 transition-all"
                                >
                                    <Trash2 size={18} />
                                </button>
                            </div>
                        </div>

                        {/* Stations Flow */}
                        <div className="bg-[#1a1a1a]/50 p-5 rounded-2xl border border-border-dark/30">
                            <h4 className="text-[10px] font-bold text-text-muted mb-4 uppercase tracking-widest">مسار الرحلة</h4>
                            <div className="flex items-center gap-3 overflow-x-auto pb-2 scrollbar-none scroll-smooth">
                                {route.stations_order.map((stationId, index) => (
                                    <div key={`${route.id}-${stationId}-${index}`} className="flex items-center gap-3 shrink-0">
                                        <div className="flex flex-col items-center gap-2">
                                            <div className={cn(
                                                "px-4 py-2.5 rounded-xl border border-border-dark text-xs font-bold transition-all",
                                                index === 0 ? "bg-primary-green/10 border-primary-green/30 text-primary-green" :
                                                    index === route.stations_order.length - 1 ? "bg-accent-blue/10 border-accent-blue/30 text-accent-blue" :
                                                        "bg-surface-dark text-text-primary"
                                            )}>
                                                {getStationName(stationId)}
                                            </div>
                                            {index === 0 && <span className="text-[9px] text-primary-green font-black">البداية</span>}
                                            {index === route.stations_order.length - 1 && <span className="text-[9px] text-accent-blue font-black">النهاية</span>}
                                        </div>
                                        {index < route.stations_order.length - 1 && (
                                            <ArrowLeft size={16} className="text-text-muted/30" />
                                        )}
                                    </div>
                                ))}
                                {route.stations_order.length === 0 && (
                                    <p className="text-xs text-text-muted italic">لا توجد محطات مسجلة لهذا المسار.</p>
                                )}
                            </div>
                        </div>
                    </div>
                ))}
                {filteredRoutes.length === 0 && (
                    <div className="card p-12 text-center text-text-secondary italic">
                        لم يتم العثور على مسارات مطابقة للبحث.
                    </div>
                )}
            </div>

            {/* Modal */}
            {modal.open && (
                <div className="fixed inset-0 z-100 flex items-center justify-center p-4 bg-black/70 backdrop-blur-md">
                    <div className="bg-surface-dark border border-border-dark rounded-2xl w-full max-w-2xl p-8 space-y-6 shadow-2xl text-right max-h-[90vh] overflow-y-auto">
                        <div className="flex items-center justify-between sticky top-0 bg-surface-dark pb-4 z-10 border-b border-border-dark">
                            <button onClick={() => setModal({ open: false })} className="text-text-muted hover:text-white p-2">
                                <X size={24} />
                            </button>
                            <h2 className="text-2xl font-bold text-white">{modal.route ? 'تعديل المسار' : 'إضافة مسار جديد'}</h2>
                        </div>

                        <form className="space-y-6" onSubmit={async (e) => {
                            e.preventDefault();
                            const formData = new FormData(e.currentTarget);
                            const route_name_ar = formData.get('route_name_ar') as string;
                            const route_code = formData.get('route_code') as string;
                            const university_id = formData.get('university_id') as string;

                            // Collect station IDs from inputs (simplified for this update)
                            const station_order = Array.from(e.currentTarget.querySelectorAll('select[name="station"]'))
                                .map(sel => (sel as HTMLSelectElement).value)
                                .filter(val => val !== "");

                            try {
                                if (modal.route) {
                                    await db.updateRoute(modal.route.id, {
                                        route_name_ar,
                                        route_code,
                                        university_id,
                                        stations_order: station_order
                                    });
                                } else {
                                    await db.addRoute({
                                        route_name_ar,
                                        route_code,
                                        university_id,
                                        stations_order: station_order,
                                        is_active: true
                                    });
                                }
                                setModal({ open: false });
                                fetchData();
                            } catch (err) { alert("حدث خطأ في الحفظ"); }
                        }}>
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div className="space-y-1.5">
                                    <label className="text-xs text-text-secondary">اسم المسار (بالعربية)</label>
                                    <input name="route_name_ar" required defaultValue={modal.route?.route_name_ar} className="w-full bg-white/5 border border-border-dark rounded-xl py-3 px-4 text-right outline-none focus:border-primary-green" placeholder="مثال: الشروق - الجامعة الألمانية" />
                                </div>
                                <div className="space-y-1.5">
                                    <label className="text-xs text-text-secondary">كود المسار</label>
                                    <input name="route_code" required defaultValue={modal.route?.route_code} className="w-full bg-white/5 border border-border-dark rounded-xl py-3 px-4 text-left outline-none focus:border-primary-green font-mono" placeholder="Ex: SH-GUC-01" />
                                </div>
                            </div>

                            <div className="space-y-1.5">
                                <label className="text-xs text-text-secondary">الجامعة التابع لها</label>
                                <select name="university_id" defaultValue={modal.route?.university_id} className="w-full bg-white/5 border border-border-dark rounded-xl py-3 px-4 text-right outline-none focus:border-primary-green appearance-none">
                                    <option value="">مسار عام (بدون جامعة)</option>
                                    {universities.map(uni => (
                                        <option key={uni.id} value={uni.id} className="bg-surface-dark">{uni.name_ar}</option>
                                    ))}
                                </select>
                            </div>

                            <div className="space-y-4">
                                <div className="flex items-center justify-between">
                                    <label className="text-sm font-bold text-text-primary">ترتيب المحطات (من البداية للنهاية)</label>
                                    {/* Placeholder for dynamic addition, for now we list placeholders */}
                                </div>
                                <div className="space-y-3">
                                    {[0, 1, 2, 3].map((i) => (
                                        <div key={i} className="flex items-center gap-3">
                                            <span className="text-xs text-text-muted w-16">محطة {i + 1}</span>
                                            <select name="station" defaultValue={modal.route?.stations_order[i]} className="flex-1 bg-white/5 border border-border-dark rounded-xl py-2 px-4 text-right outline-none focus:border-primary-green appearance-none text-xs">
                                                <option value="">-- اختر محطة --</option>
                                                {stations.map(s => (
                                                    <option key={s.id} value={s.id} className="bg-surface-dark">{s.name_ar} ({s.cities?.name_ar})</option>
                                                ))}
                                            </select>
                                        </div>
                                    ))}
                                </div>
                                <p className="text-[10px] text-text-muted italic">يمكنك اختيار حتى ٤ محطات حالياً، سيتم دعم المزيد قريباً.</p>
                            </div>

                            <button className="btn-primary w-full py-4 text-lg mt-6 shadow-xl shadow-primary-green/10">حفظ المسار والبيانات</button>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}
