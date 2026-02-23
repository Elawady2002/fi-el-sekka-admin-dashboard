"use client";

import { useState } from "react";
import {
    Plus,
    MapPin,
    X,
    Edit2,
    Trash2,
    Globe,
    MapPinned,
    ChevronDown,
    Building2
} from "lucide-react";
import { cn } from "@/lib/utils";

type Entity = {
    id: string;
    nameAr: string;
    nameEn: string;
};

type DropOffPoint = Entity;
type PickupPoint = Entity & { dropOffPoints: DropOffPoint[] };
type City = Entity & { pickupPoints: PickupPoint[] };

export default function PointToPointPage() {
    const [expandedCities, setExpandedCities] = useState<Set<string>>(new Set(["1"]));
    const [expandedPickups, setExpandedPickups] = useState<Set<string>>(new Set(["p1"]));

    const [showModal, setShowModal] = useState<'city' | 'pickup' | 'dropoff' | null>(null);
    const [modalContext, setModalContext] = useState<{ cityId?: string; pickupId?: string } | null>(null);
    const [modalData, setModalData] = useState({ nameAr: "", nameEn: "" });

    const [cities, setCities] = useState<City[]>([
        {
            id: "1", nameAr: "الشروق", nameEn: "El Shorouk",
            pickupPoints: [
                {
                    id: "p1", nameAr: "بوابة ١", nameEn: "Gate 1",
                    dropOffPoints: [
                        { id: "d1", nameAr: "الجامعة البريطانية", nameEn: "BUE" },
                        { id: "d2", nameAr: "بانوراما الشروق", nameEn: "Panorama Shorouk" }
                    ]
                },
                {
                    id: "p2", nameAr: "بوابة ٢", nameEn: "Gate 2",
                    dropOffPoints: [
                        { id: "d3", nameAr: "نادي هليوبوليس", nameEn: "Heliopolis Club" }
                    ]
                }
            ]
        },
        {
            id: "2", nameAr: "القاهرة الجديدة", nameEn: "New Cairo",
            pickupPoints: [
                {
                    id: "p3", nameAr: "شارع التسعين", nameEn: "90th Street",
                    dropOffPoints: []
                }
            ]
        },
    ]);

    const toggleCity = (cityId: string) => {
        const next = new Set(expandedCities);
        if (next.has(cityId)) next.delete(cityId);
        else next.add(cityId);
        setExpandedCities(next);
    };

    const togglePickup = (pickupId: string) => {
        const next = new Set(expandedPickups);
        if (next.has(pickupId)) next.delete(pickupId);
        else next.add(pickupId);
        setExpandedPickups(next);
    };

    const openModal = (type: 'city' | 'pickup' | 'dropoff', context?: { cityId?: string; pickupId?: string }) => {
        setShowModal(type);
        setModalContext(context || null);
        setModalData({ nameAr: "", nameEn: "" });
    };

    const handleAddEntity = () => {
        if (showModal === 'city') {
            const newCity: City = {
                id: Math.random().toString(),
                nameAr: modalData.nameAr,
                nameEn: modalData.nameEn,
                pickupPoints: []
            };
            setCities([...cities, newCity]);
            // Auto-expand new city
            setExpandedCities(new Set([...expandedCities, newCity.id]));
        } else if (showModal === 'pickup' && modalContext?.cityId) {
            const newPickup: PickupPoint = {
                id: Math.random().toString(),
                nameAr: modalData.nameAr,
                nameEn: modalData.nameEn,
                dropOffPoints: []
            };
            setCities(cities.map(c =>
                c.id === modalContext.cityId
                    ? { ...c, pickupPoints: [...c.pickupPoints, newPickup] }
                    : c
            ));
            // Auto-expand parent city and new pickup
            setExpandedCities(new Set([...expandedCities, modalContext.cityId]));
            setExpandedPickups(new Set([...expandedPickups, newPickup.id]));
        } else if (showModal === 'dropoff' && modalContext?.cityId && modalContext?.pickupId) {
            const newDropoff: DropOffPoint = {
                id: Math.random().toString(),
                nameAr: modalData.nameAr,
                nameEn: modalData.nameEn
            };
            setCities(cities.map(c => {
                if (c.id === modalContext.cityId) {
                    return {
                        ...c,
                        pickupPoints: c.pickupPoints.map(p =>
                            p.id === modalContext.pickupId
                                ? { ...p, dropOffPoints: [...p.dropOffPoints, newDropoff] }
                                : p
                        )
                    };
                }
                return c;
            }));
            // Ensure parent elements are expanded
            setExpandedCities(new Set([...expandedCities, modalContext.cityId]));
            setExpandedPickups(new Set([...expandedPickups, modalContext.pickupId]));
        }
        setShowModal(null);
    };

    return (
        <div className="space-y-10 animate-fade-up">
            {/* Header */}
            <div className="flex items-end justify-between">
                <div>
                    <div className="flex items-center gap-4 mb-2">
                        <h2 className="text-3xl font-black italic">المدن والمناطق</h2>
                    </div>
                    <p className="text-[10px] text-text-dim uppercase tracking-widest">
                        Network Hubs & Regions - Hierarchical View
                    </p>
                </div>
                <button
                    onClick={() => openModal('city')}
                    className="btn-swiss flex items-center gap-2"
                >
                    <Plus size={16} />
                    إضافة مدينة
                </button>
            </div>

            {/* Accordion List */}
            <div className="space-y-4">
                {cities.map((city) => (
                    <div key={city.id} className="glass-card p-0 overflow-hidden group/city">
                        {/* City Header */}
                        <div
                            className={cn(
                                "p-6 flex items-center justify-between cursor-pointer transition-colors",
                                expandedCities.has(city.id) ? "bg-white/5" : "hover:bg-white/[0.02]"
                            )}
                            onClick={() => toggleCity(city.id)}
                        >
                            <div className="flex items-center gap-4">
                                <div className={cn(
                                    "w-12 h-12 flex items-center justify-center border transition-all",
                                    expandedCities.has(city.id) ? "bg-primary-gold text-bg-black border-transparent" : "bg-white/5 text-text-main border-white/5 group-hover/city:border-white/20"
                                )}>
                                    <Building2 size={20} />
                                </div>
                                <div>
                                    <h3 className="text-xl font-black mb-0.5 flex items-center gap-3">
                                        {city.nameAr}
                                        <span className="text-[9px] font-bold uppercase tracking-widest text-text-dim bg-white/5 px-2 py-1 flex items-center gap-1.5">
                                            <MapPin size={10} className={expandedCities.has(city.id) ? "text-bg-black" : "text-primary-gold"} />
                                            {city.pickupPoints.length} محطات
                                        </span>
                                    </h3>
                                    <p className="text-[10px] text-text-dim uppercase font-bold tracking-widest">{city.nameEn}</p>
                                </div>
                            </div>
                            <div className="flex items-center gap-4">
                                <button
                                    onClick={(e) => { e.stopPropagation(); openModal('pickup', { cityId: city.id }); }}
                                    className="px-4 py-2 text-[10px] font-black uppercase tracking-widest text-primary-gold hover:bg-primary-gold/10 border border-primary-gold/20 transition-all flex items-center gap-2 opacity-0 group-hover/city:opacity-100 focus:opacity-100"
                                >
                                    <Plus size={12} /> محطة ركوب
                                </button>
                                <div className={cn(
                                    "w-8 h-8 flex items-center justify-center transition-transform duration-300 text-text-dim",
                                    expandedCities.has(city.id) ? "rotate-180 text-primary-gold" : ""
                                )}>
                                    <ChevronDown size={20} />
                                </div>
                            </div>
                        </div>

                        {/* City Content (Pickups) */}
                        {expandedCities.has(city.id) && (
                            <div className="border-t border-white/5 bg-black/40 p-4 space-y-3">
                                {city.pickupPoints.length === 0 ? (
                                    <div className="py-8 text-center border border-dashed border-white/10 opacity-50">
                                        <p className="text-[10px] font-black text-text-dim uppercase tracking-widest">لا توجد محطات ركوب</p>
                                    </div>
                                ) : (
                                    city.pickupPoints.map(pickup => (
                                        <div key={pickup.id} className="glass-card bg-surface-dark border-white/5 p-0 overflow-hidden group/pickup">
                                            {/* Pickup Header */}
                                            <div
                                                className={cn(
                                                    "p-4 flex items-center justify-between cursor-pointer transition-colors",
                                                    expandedPickups.has(pickup.id) ? "bg-white/5" : "hover:bg-white/[0.02]"
                                                )}
                                                onClick={() => togglePickup(pickup.id)}
                                            >
                                                <div className="flex items-center gap-4">
                                                    <div className={cn(
                                                        "w-10 h-10 flex items-center justify-center border transition-all",
                                                        expandedPickups.has(pickup.id) ? "bg-text-main text-bg-black border-transparent" : "bg-primary-gold/10 text-primary-gold border-primary-gold/20"
                                                    )}>
                                                        <MapPinned size={16} />
                                                    </div>
                                                    <div>
                                                        <h4 className="text-lg font-black mb-0.5 flex items-center gap-2">
                                                            {pickup.nameAr}
                                                            <span className="text-[8px] font-bold uppercase tracking-widest text-text-dim bg-black/40 px-2 py-0.5 border border-white/5 flex items-center gap-1">
                                                                <Globe size={8} className="text-state-success" />
                                                                {pickup.dropOffPoints.length} وجهات
                                                            </span>
                                                        </h4>
                                                        <p className="text-[9px] text-text-dim uppercase font-bold tracking-widest">{pickup.nameEn}</p>
                                                    </div>
                                                </div>
                                                <div className="flex items-center gap-4">
                                                    <button
                                                        onClick={(e) => { e.stopPropagation(); openModal('dropoff', { cityId: city.id, pickupId: pickup.id }); }}
                                                        className="px-3 py-1.5 text-[9px] font-black uppercase tracking-widest text-text-main hover:bg-white/10 border border-white/10 transition-all flex items-center gap-1.5 opacity-0 group-hover/pickup:opacity-100 focus:opacity-100"
                                                    >
                                                        <Plus size={10} /> نقطة وصول
                                                    </button>
                                                    <div className={cn(
                                                        "w-6 h-6 flex items-center justify-center transition-transform duration-300 text-text-dim",
                                                        expandedPickups.has(pickup.id) ? "rotate-180 text-text-main" : ""
                                                    )}>
                                                        <ChevronDown size={16} />
                                                    </div>
                                                </div>
                                            </div>

                                            {/* Pickup Content (Drop-offs) */}
                                            {expandedPickups.has(pickup.id) && (
                                                <div className="border-t border-white/5 bg-black/60 p-4 space-y-2">
                                                    {pickup.dropOffPoints.length === 0 ? (
                                                        <div className="py-6 text-center border border-dashed border-white/5 opacity-50">
                                                            <p className="text-[9px] font-black text-text-dim uppercase tracking-widest">لا توجد نقاط وصول متاحة</p>
                                                        </div>
                                                    ) : (
                                                        <div className="grid grid-cols-2 gap-2">
                                                            {pickup.dropOffPoints.map(dropoff => (
                                                                <div key={dropoff.id} className="p-3 border border-white/5 bg-white/[0.02] flex items-center justify-between group/dropoff hover:border-white/10 transition-all">
                                                                    <div className="flex items-center gap-3">
                                                                        <div className="w-8 h-8 bg-black/50 flex items-center justify-center border border-white/5 text-state-success">
                                                                            <MapPin size={14} />
                                                                        </div>
                                                                        <div>
                                                                            <h5 className="text-sm font-black mb-0.5">{dropoff.nameAr}</h5>
                                                                            <p className="text-[8px] text-text-dim uppercase font-bold tracking-widest">{dropoff.nameEn}</p>
                                                                        </div>
                                                                    </div>
                                                                    <div className="flex gap-1 opacity-0 group-hover/dropoff:opacity-100 transition-opacity">
                                                                        <button className="w-7 h-7 flex items-center justify-center hover:bg-white/10 text-text-dim hover:text-text-main transition-all">
                                                                            <Edit2 size={12} />
                                                                        </button>
                                                                        <button className="w-7 h-7 flex items-center justify-center hover:bg-state-error/20 text-text-dim hover:text-state-error transition-all">
                                                                            <Trash2 size={12} />
                                                                        </button>
                                                                    </div>
                                                                </div>
                                                            ))}
                                                        </div>
                                                    )}
                                                </div>
                                            )}
                                        </div>
                                    ))
                                )}
                            </div>
                        )}
                    </div>
                ))}

                {cities.length === 0 && (
                    <div className="py-20 text-center glass-card border-dashed">
                        <p className="text-text-dim uppercase text-[10px] font-black tracking-widest mb-4">No Network Data Available</p>
                        <button onClick={() => openModal('city')} className="text-primary-gold font-black uppercase text-xs hover:underline">أضف أول مدينة الآن</button>
                    </div>
                )}
            </div>

            {/* Modal - Kept the same styled version from previous refinement */}
            {showModal && (
                <div className="fixed top-0 left-0 w-full h-screen z-[9999] flex items-start justify-center pt-32 p-6 bg-bg-black/60 backdrop-blur-sm animate-fade-in">
                    <div className="glass-card w-full max-w-lg p-12 space-y-10 animate-fade-up shadow-2xl border-white/10">
                        <div className="flex items-start justify-between">
                            <div>
                                <div className="flex items-center gap-2 mb-2">
                                    <div className="w-1.5 h-1.5 bg-primary-gold" />
                                    <span className="text-[10px] font-black uppercase tracking-[0.3em] text-primary-gold">
                                        {showModal === 'city' ? 'City Management' :
                                            showModal === 'pickup' ? 'Pickup Point Management' : 'Drop-off Point Management'}
                                    </span>
                                </div>
                                <h3 className="text-xl font-black italic uppercase leading-none">
                                    {showModal === 'city' ? 'إضافة مدينة جديدة' :
                                        showModal === 'pickup' ? 'إضافة نقطة ركوب' : 'إضافة نقطة وصول'}
                                </h3>
                            </div>
                            <button
                                onClick={() => setShowModal(null)}
                                className="w-10 h-10 flex items-center justify-center border border-white/5 hover:bg-white/5 text-text-dim hover:text-text-main transition-all"
                            >
                                <X size={20} />
                            </button>
                        </div>

                        <div className="space-y-8">
                            <div className="space-y-3">
                                <div className="flex justify-between items-center">
                                    <label className="text-[10px] font-black uppercase text-text-dim tracking-widest">الاسم بالعربي</label>
                                    <span className="text-[8px] font-bold text-primary-gold/50 uppercase tracking-widest">Arabic Name</span>
                                </div>
                                <input
                                    type="text"
                                    autoFocus
                                    value={modalData.nameAr}
                                    onChange={(e) => setModalData({ ...modalData, nameAr: e.target.value })}
                                    className="w-full h-16 bg-white/3 border border-white/5 px-6 text-sm font-bold placeholder:text-text-dim/20 outline-none focus:border-primary-gold focus:bg-white/5 transition-all text-right"
                                    placeholder="مثال: مدينة الشروق"
                                />
                            </div>
                            <div className="space-y-3">
                                <div className="flex justify-between items-center text-left">
                                    <span className="text-[8px] font-bold text-primary-gold/50 uppercase tracking-widest">English Name</span>
                                    <label className="text-[10px] font-black uppercase text-text-dim tracking-widest">الاسم بالإنجليزية</label>
                                </div>
                                <input
                                    type="text"
                                    value={modalData.nameEn}
                                    onChange={(e) => setModalData({ ...modalData, nameEn: e.target.value })}
                                    className="w-full h-16 bg-white/3 border border-white/5 px-6 text-sm font-bold placeholder:text-text-dim/20 outline-none focus:border-primary-gold focus:bg-white/5 transition-all text-left"
                                    placeholder="Example: El Shorouk City"
                                />
                            </div>
                        </div>

                        <div className="flex gap-4 pt-6">
                            <button
                                onClick={() => setShowModal(null)}
                                className="flex-1 h-14 text-[10px] font-black uppercase tracking-widest text-text-dim hover:text-text-main transition-all border border-white/5 hover:bg-white/5"
                            >
                                إلغاء
                            </button>
                            <button
                                onClick={handleAddEntity}
                                className="flex-1 h-14 bg-text-main text-bg-black font-display font-black text-xs uppercase tracking-widest transition-all hover:bg-primary-gold active:scale-95 px-6"
                            >
                                حفظ الكيان
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
}
