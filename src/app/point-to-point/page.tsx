"use client";

import { useState } from "react";
import {
    Plus,
    Search,
    MapPin,
    ArrowLeft,
    ChevronLeft,
    X,
    Edit2,
    Trash2,
    Globe,
    MapPinned,
    MoreVertical
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
    const [view, setView] = useState<'cities' | 'pickups' | 'dropoffs'>('cities');
    const [selectedCity, setSelectedCity] = useState<City | null>(null);
    const [selectedPickup, setSelectedPickup] = useState<PickupPoint | null>(null);

    const [showModal, setShowModal] = useState<'city' | 'pickup' | 'dropoff' | null>(null);
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
                }
            ]
        },
        { id: "2", nameAr: "القاهرة الجديدة", nameEn: "New Cairo", pickupPoints: [] },
    ]);

    const handleBack = () => {
        if (view === 'dropoffs') {
            setView('pickups');
            setSelectedPickup(null);
        } else if (view === 'pickups') {
            setView('cities');
            setSelectedCity(null);
        }
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
        } else if (showModal === 'pickup' && selectedCity) {
            const newPickup: PickupPoint = {
                id: Math.random().toString(),
                nameAr: modalData.nameAr,
                nameEn: modalData.nameEn,
                dropOffPoints: []
            };
            const updatedCities = cities.map(c =>
                c.id === selectedCity.id
                    ? { ...c, pickupPoints: [...c.pickupPoints, newPickup] }
                    : c
            );
            setCities(updatedCities);
            setSelectedCity({ ...selectedCity, pickupPoints: [...selectedCity.pickupPoints, newPickup] });
        } else if (showModal === 'dropoff' && selectedCity && selectedPickup) {
            const newDropoff: DropOffPoint = {
                id: Math.random().toString(),
                nameAr: modalData.nameAr,
                nameEn: modalData.nameEn
            };
            const updatedCities = cities.map(c => {
                if (c.id === selectedCity.id) {
                    return {
                        ...c,
                        pickupPoints: c.pickupPoints.map(p =>
                            p.id === selectedPickup.id
                                ? { ...p, dropOffPoints: [...p.dropOffPoints, newDropoff] }
                                : p
                        )
                    };
                }
                return c;
            });
            setCities(updatedCities);
            setSelectedPickup({ ...selectedPickup, dropOffPoints: [...selectedPickup.dropOffPoints, newDropoff] });
        }
        setShowModal(null);
        setModalData({ nameAr: "", nameEn: "" });
    };

    return (
        <div className="space-y-10 animate-fade-up">
            {/* Header */}
            <div className="flex items-end justify-between">
                <div>
                    <div className="flex items-center gap-4 mb-2">
                        {view !== 'cities' && (
                            <button
                                onClick={handleBack}
                                className="w-10 h-10 glass-card flex items-center justify-center hover:bg-primary-gold hover:text-bg-black transition-all"
                            >
                                <ArrowLeft size={18} />
                            </button>
                        )}
                        <h2 className="text-3xl font-black italic">
                            {view === 'cities' ? 'المدن والمناطق' :
                                view === 'pickups' ? `نقاط الركوب - ${selectedCity?.nameAr}` :
                                    `نقاط الوصول - ${selectedPickup?.nameAr}`}
                        </h2>
                    </div>
                    <p className="text-[10px] text-text-dim uppercase tracking-widest">
                        {view === 'cities' ? 'Network Hubs & Regions' :
                            view === 'pickups' ? `pickup stations in ${selectedCity?.nameEn}` :
                                `available drop-offs from ${selectedPickup?.nameEn}`}
                    </p>
                </div>
                <button
                    onClick={() => setShowModal(view === 'cities' ? 'city' : view === 'pickups' ? 'pickup' : 'dropoff')}
                    className="btn-swiss flex items-center gap-2"
                >
                    <Plus size={16} />
                    {view === 'cities' ? 'إضافة مدينة' : view === 'pickups' ? 'إضافة نقطة ركوب' : 'إضافة نقطة وصول'}
                </button>
            </div>

            {/* Breadcrumbs */}
            {view !== 'cities' && (
                <div className="flex items-center gap-2 text-[10px] font-black uppercase tracking-tighter text-text-dim">
                    <span className="hover:text-primary-gold cursor-pointer" onClick={() => { setView('cities'); setSelectedCity(null); setSelectedPickup(null); }}>CITIES</span>
                    <ChevronLeft size={10} />
                    <span className={cn(view === 'pickups' ? "text-primary-gold" : "hover:text-primary-gold cursor-pointer")} onClick={() => { if (view === 'dropoffs') { setView('pickups'); setSelectedPickup(null); } }}>{selectedCity?.nameEn}</span>
                    {selectedPickup && (
                        <>
                            <ChevronLeft size={10} />
                            <span className="text-primary-gold">{selectedPickup?.nameEn}</span>
                        </>
                    )}
                </div>
            )}

            {/* Grid Content */}
            <div className="grid grid-cols-2 gap-4">
                {view === 'cities' && cities.map((city) => (
                    <div key={city.id} className="glass-card p-0 overflow-hidden flex flex-col group active:scale-[0.98] cursor-pointer" onClick={() => { setSelectedCity(city); setView('pickups'); }}>
                        <div className="p-8 flex items-center justify-between">
                            <div className="flex items-center gap-6">
                                <div className="w-16 h-16 bg-white/5 flex items-center justify-center font-black text-xl border border-white/5 group-hover:border-primary-gold transition-all italic">
                                    {city.nameAr[0]}
                                </div>
                                <div>
                                    <h3 className="text-xl font-black mb-1">{city.nameAr}</h3>
                                    <p className="text-[10px] text-text-dim uppercase font-bold tracking-widest">{city.nameEn}</p>
                                    <div className="flex items-center gap-4 mt-2">
                                        <span className="flex items-center gap-1.5 text-[8px] font-black uppercase text-text-dim">
                                            <MapPin size={10} className="text-primary-gold" /> {city.pickupPoints.length} محطات ركوب
                                        </span>
                                    </div>
                                </div>
                            </div>
                            <ChevronLeft size={20} className="text-text-dim group-hover:text-primary-gold transition-colors" />
                        </div>
                    </div>
                ))}

                {view === 'pickups' && selectedCity?.pickupPoints.map((pickup) => (
                    <div key={pickup.id} className="glass-card p-0 overflow-hidden flex flex-col group active:scale-[0.98] cursor-pointer" onClick={() => { setSelectedPickup(pickup); setView('dropoffs'); }}>
                        <div className="p-8 flex items-center justify-between">
                            <div className="flex items-center gap-6">
                                <div className="w-16 h-16 bg-primary-gold-dim flex items-center justify-center font-black text-xl border border-primary-gold/10 group-hover:border-primary-gold transition-all">
                                    <MapPinned size={24} className="text-primary-gold" />
                                </div>
                                <div>
                                    <h3 className="text-xl font-black mb-1">{pickup.nameAr}</h3>
                                    <p className="text-[10px] text-text-dim uppercase font-bold tracking-widest">{pickup.nameEn}</p>
                                    <div className="flex items-center gap-4 mt-2">
                                        <span className="flex items-center gap-1.5 text-[8px] font-black uppercase text-text-dim">
                                            <Globe size={10} className="text-primary-gold" /> {pickup.dropOffPoints.length} نقاط وصول متاحة
                                        </span>
                                    </div>
                                </div>
                            </div>
                            <ChevronLeft size={20} className="text-text-dim group-hover:text-primary-gold transition-colors" />
                        </div>
                    </div>
                ))}

                {view === 'dropoffs' && selectedPickup?.dropOffPoints.map((dropoff) => (
                    <div key={dropoff.id} className="glass-card p-8 flex items-center justify-between group">
                        <div className="flex items-center gap-6">
                            <div className="w-12 h-12 bg-white/5 flex items-center justify-center font-black text-sm border border-white/5">
                                <MapPin size={18} className="text-state-success" />
                            </div>
                            <div>
                                <h3 className="text-lg font-black mb-0.5">{dropoff.nameAr}</h3>
                                <p className="text-[9px] text-text-dim uppercase font-bold tracking-widest">{dropoff.nameEn}</p>
                            </div>
                        </div>
                        <div className="flex gap-2">
                            <button className="w-10 h-10 flex items-center justify-center hover:bg-white/5 border border-transparent hover:border-white/5 text-text-dim hover:text-text-main transition-all">
                                <Edit2 size={16} />
                            </button>
                            <button className="w-10 h-10 flex items-center justify-center hover:bg-state-error/10 border border-transparent hover:border-state-error/20 text-text-dim hover:text-state-error transition-all">
                                <Trash2 size={16} />
                            </button>
                        </div>
                    </div>
                ))}
            </div>

            {cities.length === 0 && view === 'cities' && (
                <div className="py-20 text-center glass-card border-dashed">
                    <p className="text-text-dim uppercase text-[10px] font-black tracking-widest mb-4">No Network Data Available</p>
                    <button onClick={() => setShowModal('city')} className="text-primary-gold font-black uppercase text-xs hover:underline">أضف أول مدينة الآن</button>
                </div>
            )}

            {/* Modal */}
            {showModal && (
                <div className="fixed inset-0 z-[100] flex items-center justify-center p-6 bg-bg-black/90 backdrop-blur-md animate-fade-in">
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
                                <h3 className="text-2xl font-black italic uppercase leading-none">
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
                                    className="w-full h-16 bg-white/[0.03] border border-white/5 px-6 text-sm font-bold placeholder:text-text-dim/20 outline-none focus:border-primary-gold focus:bg-white/[0.05] transition-all text-right"
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
                                    className="w-full h-16 bg-white/[0.03] border border-white/5 px-6 text-sm font-bold placeholder:text-text-dim/20 outline-none focus:border-primary-gold focus:bg-white/[0.05] transition-all text-left"
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
