"use client";

import { useState } from "react";
import {
    Plus,
    MapPin,
    X,
    MapPinned,
    Building2,
    ChevronLeft
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
    const [selectedCityId, setSelectedCityId] = useState<string | null>("1");
    const [selectedPickupId, setSelectedPickupId] = useState<string | null>("p1");

    const [showModal, setShowModal] = useState<'city' | 'pickup' | 'dropoff' | null>(null);
    const [modalData, setModalData] = useState({ nameAr: "", nameEn: "" });

    // Clean, generic mock data for Point to Point
    const [cities, setCities] = useState<City[]>([
        {
            id: "1", nameAr: "مدينة الرياض", nameEn: "Riyadh City",
            pickupPoints: [
                {
                    id: "p1", nameAr: "المحطة الرئيسية", nameEn: "Main Station",
                    dropOffPoints: [
                        { id: "d1", nameAr: "نقطة توقف أ", nameEn: "Stop Point A" },
                        { id: "d2", nameAr: "نقطة توقف ب", nameEn: "Stop Point B" }
                    ]
                },
                {
                    id: "p2", nameAr: "محطة الشمال", nameEn: "North Station",
                    dropOffPoints: [
                        { id: "d3", nameAr: "بوابة المعارض", nameEn: "Expo Gate" }
                    ]
                }
            ]
        },
        {
            id: "2", nameAr: "مدينة جدة", nameEn: "Jeddah City",
            pickupPoints: [
                {
                    id: "p3", nameAr: "محطة المطار", nameEn: "Airport Station",
                    dropOffPoints: []
                }
            ]
        },
    ]);

    const selectedCity = cities.find(c => c.id === selectedCityId) || null;
    const selectedPickup = selectedCity?.pickupPoints.find(p => p.id === selectedPickupId) || null;

    const handleCitySelect = (cityId: string) => {
        setSelectedCityId(cityId);
        // Reset child selection when parent changes
        setSelectedPickupId(null);
    };

    const openModal = (type: 'city' | 'pickup' | 'dropoff') => {
        setShowModal(type);
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
            setSelectedCityId(newCity.id);
            setSelectedPickupId(null);
        }
        else if (showModal === 'pickup' && selectedCityId) {
            const newPickup: PickupPoint = {
                id: Math.random().toString(),
                nameAr: modalData.nameAr,
                nameEn: modalData.nameEn,
                dropOffPoints: []
            };
            setCities(cities.map(c =>
                c.id === selectedCityId
                    ? { ...c, pickupPoints: [...c.pickupPoints, newPickup] }
                    : c
            ));
            setSelectedPickupId(newPickup.id);
        }
        else if (showModal === 'dropoff' && selectedCityId && selectedPickupId) {
            const newDropoff: DropOffPoint = {
                id: Math.random().toString(),
                nameAr: modalData.nameAr,
                nameEn: modalData.nameEn
            };
            setCities(cities.map(c => {
                if (c.id === selectedCityId) {
                    return {
                        ...c,
                        pickupPoints: c.pickupPoints.map(p =>
                            p.id === selectedPickupId
                                ? { ...p, dropOffPoints: [...p.dropOffPoints, newDropoff] }
                                : p
                        )
                    };
                }
                return c;
            }));
        }
        setShowModal(null);
    };

    return (
        <div className="space-y-8 animate-fade-up h-[calc(100vh-8rem)] flex flex-col">
            {/* Header */}
            <div className="flex items-end justify-between shrink-0">
                <div>
                    <h2 className="text-3xl font-black italic mb-2">إدارة الخطوط والمحطات</h2>
                    <p className="text-[10px] text-text-dim uppercase tracking-widest">
                        Point to Point - Master/Detail View
                    </p>
                </div>
            </div>

            {/* 3-Column Layout */}
            <div className="flex-1 grid grid-cols-3 gap-6 min-h-0">

                {/* Column 1: Cities */}
                <div className="glass-card p-0 flex flex-col h-full overflow-hidden border-white/5 shadow-2xl">
                    <div className="p-5 border-b border-white/5 flex items-center justify-between bg-black/40 shrink-0">
                        <h3 className="font-black text-lg flex items-center gap-2">
                            <Building2 size={18} className="text-primary-gold" />
                            المدن
                        </h3>
                        <button
                            onClick={() => openModal('city')}
                            className="w-8 h-8 flex items-center justify-center bg-primary-gold text-bg-black hover:bg-white transition-all shadow-[0_0_15px_rgba(212,175,55,0.3)]"
                        >
                            <Plus size={16} />
                        </button>
                    </div>
                    <div className="flex-1 overflow-y-auto p-3 space-y-2">
                        {cities.map((city) => (
                            <div
                                key={city.id}
                                onClick={() => handleCitySelect(city.id)}
                                className={cn(
                                    "p-4 cursor-pointer transition-all border flex items-center justify-between group",
                                    selectedCityId === city.id
                                        ? "bg-primary-gold/10 border-primary-gold text-primary-gold"
                                        : "bg-surface-dark border-transparent hover:bg-white/5 text-text-main hover:border-white/10"
                                )}
                            >
                                <div>
                                    <h4 className="font-black text-base mb-1">{city.nameAr}</h4>
                                    <p className={cn(
                                        "text-[10px] uppercase font-bold tracking-widest",
                                        selectedCityId === city.id ? "text-primary-gold/70" : "text-text-dim"
                                    )}>{city.nameEn}</p>
                                </div>
                                <ChevronLeft size={16} className={cn(
                                    "transition-all",
                                    selectedCityId === city.id ? "opacity-100" : "opacity-0 -translate-x-2 group-hover:opacity-50 group-hover:translate-x-0"
                                )} />
                            </div>
                        ))}
                        {cities.length === 0 && (
                            <div className="h-full flex flex-col items-center justify-center text-center p-6 opacity-50">
                                <Building2 size={32} className="mb-4 text-text-dim" />
                                <p className="text-xs font-black uppercase tracking-widest text-text-dim">لا توجد مدن مضافة</p>
                            </div>
                        )}
                    </div>
                </div>

                {/* Column 2: Pickups */}
                <div className={cn(
                    "glass-card p-0 flex flex-col h-full overflow-hidden border-white/5 shadow-2xl transition-all duration-300",
                    !selectedCityId && "opacity-50 grayscale pointer-events-none"
                )}>
                    <div className="p-5 border-b border-white/5 flex items-center justify-between bg-black/40 shrink-0">
                        <h3 className="font-black text-lg flex items-center gap-2">
                            <MapPinned size={18} className="text-white" />
                            نقاط الركوب
                        </h3>
                        <button
                            onClick={() => openModal('pickup')}
                            disabled={!selectedCityId}
                            className="w-8 h-8 flex items-center justify-center bg-white text-bg-black hover:bg-primary-gold disabled:opacity-50 transition-all"
                        >
                            <Plus size={16} />
                        </button>
                    </div>
                    <div className="flex-1 overflow-y-auto p-3 space-y-2">
                        {!selectedCityId ? (
                            <div className="h-full flex flex-col items-center justify-center text-center p-6">
                                <p className="text-xs font-black uppercase tracking-widest text-text-dim">اختر مدينة أولاً</p>
                            </div>
                        ) : selectedCity?.pickupPoints.length === 0 ? (
                            <div className="h-full flex flex-col items-center justify-center text-center p-6 opacity-50">
                                <MapPinned size={32} className="mb-4 text-text-dim" />
                                <p className="text-xs font-black uppercase tracking-widest text-text-dim">لا توجد نقاط ركوب</p>
                            </div>
                        ) : (
                            selectedCity?.pickupPoints.map((pickup) => (
                                <div
                                    key={pickup.id}
                                    onClick={() => setSelectedPickupId(pickup.id)}
                                    className={cn(
                                        "p-4 cursor-pointer transition-all border flex items-center justify-between group",
                                        selectedPickupId === pickup.id
                                            ? "bg-white/10 border-white text-white"
                                            : "bg-surface-dark border-transparent hover:bg-white/5 text-text-main hover:border-white/10"
                                    )}
                                >
                                    <div>
                                        <h4 className="font-black text-base mb-1">{pickup.nameAr}</h4>
                                        <p className={cn(
                                            "text-[10px] uppercase font-bold tracking-widest",
                                            selectedPickupId === pickup.id ? "text-white/70" : "text-text-dim"
                                        )}>{pickup.nameEn}</p>
                                    </div>
                                    <ChevronLeft size={16} className={cn(
                                        "transition-all",
                                        selectedPickupId === pickup.id ? "opacity-100" : "opacity-0 -translate-x-2 group-hover:opacity-50 group-hover:translate-x-0"
                                    )} />
                                </div>
                            ))
                        )}
                    </div>
                </div>

                {/* Column 3: Drop-offs */}
                <div className={cn(
                    "glass-card p-0 flex flex-col h-full overflow-hidden border-white/5 shadow-2xl transition-all duration-300",
                    !selectedPickupId && "opacity-50 grayscale pointer-events-none"
                )}>
                    <div className="p-5 border-b border-white/5 flex items-center justify-between bg-black/40 shrink-0">
                        <h3 className="font-black text-lg flex items-center gap-2">
                            <MapPin size={18} className="text-state-success" />
                            نقاط الوصول
                        </h3>
                        <button
                            onClick={() => openModal('dropoff')}
                            disabled={!selectedPickupId}
                            className="w-8 h-8 flex items-center justify-center bg-state-success text-bg-black hover:bg-white disabled:opacity-50 transition-all font-black"
                        >
                            <Plus size={16} />
                        </button>
                    </div>
                    <div className="flex-1 overflow-y-auto p-3 space-y-2">
                        {!selectedPickupId ? (
                            <div className="h-full flex flex-col items-center justify-center text-center p-6">
                                <p className="text-xs font-black uppercase tracking-widest text-text-dim">اختر نقطة ركوب أولاً</p>
                            </div>
                        ) : selectedPickup?.dropOffPoints.length === 0 ? (
                            <div className="h-full flex flex-col items-center justify-center text-center p-6 opacity-50">
                                <MapPin size={32} className="mb-4 text-text-dim" />
                                <p className="text-xs font-black uppercase tracking-widest text-text-dim">لا توجد نقاط وصول</p>
                            </div>
                        ) : (
                            selectedPickup?.dropOffPoints.map((dropoff) => (
                                <div
                                    key={dropoff.id}
                                    className="p-4 bg-surface-dark border border-white/5 flex items-center justify-between hover:border-white/10 transition-all"
                                >
                                    <div>
                                        <h4 className="font-black text-base">{dropoff.nameAr}</h4>
                                        <p className="text-[10px] uppercase font-bold tracking-widest text-text-dim">{dropoff.nameEn}</p>
                                    </div>
                                </div>
                            ))
                        )}
                    </div>
                </div>

            </div>

            {/* Modal - Same Premium UI */}
            {showModal && (
                <div className="fixed top-0 left-0 w-full h-screen z-9999 flex items-start justify-center pt-32 p-6 bg-bg-black/60 backdrop-blur-sm animate-fade-in">
                    <div className="glass-card w-full max-w-lg p-12 space-y-10 animate-fade-up shadow-2xl border-white/10">
                        <div className="flex items-start justify-between">
                            <div>
                                <div className="flex items-center gap-2 mb-2">
                                    <div className="w-1.5 h-1.5 bg-primary-gold" />
                                    <span className="text-[10px] font-black uppercase tracking-[0.3em] text-primary-gold">
                                        {showModal === 'city' ? 'City' :
                                            showModal === 'pickup' ? 'Pickup Point' : 'Drop-off Point'}
                                    </span>
                                </div>
                                <h3 className="text-xl font-black italic uppercase leading-none">
                                    {showModal === 'city' ? 'إضافة مدينة' :
                                        showModal === 'pickup' ? `محطة ركوب في ${selectedCity?.nameAr}` :
                                            `نقطة وصول لـ ${selectedPickup?.nameAr}`}
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
                                    className="w-full h-16 bg-white/5 border border-white/10 px-6 text-sm font-bold placeholder:text-text-dim/20 outline-none focus:border-primary-gold focus:bg-white/10 transition-all text-right"
                                    placeholder={
                                        showModal === 'city' ? 'مثال: الرياض' :
                                            showModal === 'pickup' ? 'مثال: محطة الشمال' : 'مثال: التوقف الأول'
                                    }
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
                                    className="w-full h-16 bg-white/5 border border-white/10 px-6 text-sm font-bold placeholder:text-text-dim/20 outline-none focus:border-primary-gold focus:bg-white/10 transition-all text-left"
                                    placeholder={
                                        showModal === 'city' ? 'Example: Riyadh' :
                                            showModal === 'pickup' ? 'Example: North Station' : 'Example: First Stop'
                                    }
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
                                disabled={!modalData.nameAr || !modalData.nameEn}
                                className="flex-1 h-14 bg-text-main text-bg-black font-display font-black text-xs uppercase tracking-widest transition-all hover:bg-primary-gold disabled:opacity-50 disabled:hover:bg-text-main active:scale-95 px-6"
                            >
                                حفظ
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
}
