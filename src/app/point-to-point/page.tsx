"use client";

import { useState, useEffect } from "react";
import {
    Plus,
    MapPin,
    X,
    MapPinned,
    Building2,
    ChevronLeft,
    Clock,
    Banknote,
    Trash2,
    Loader2,
    Pencil
} from "lucide-react";
import { cn } from "@/lib/utils";
import { supabase } from "@/lib/supabase";

type Entity = {
    id: string;
    nameAr: string;
    nameEn: string;
};

type ArrivalStation = Entity & {
    price: number;
    schedules: string[];
};
type BoardingStation = Entity & { arrivalStations: ArrivalStation[] };
type City = Entity & { boardingStations: BoardingStation[] };

export default function PointToPointPage() {
    const [selectedCityId, setSelectedCityId] = useState<string | null>(null);
    const [selectedBoardingId, setSelectedBoardingId] = useState<string | null>(null);

    const [showModal, setShowModal] = useState<'city' | 'boarding' | 'arrival' | null>(null);
    const [editEntityId, setEditEntityId] = useState<string | null>(null);

    const [modalData, setModalData] = useState<{
        nameAr: string;
        nameEn: string;
        price: string;
        schedules: string[];
        newSchedule: string;
    }>({ nameAr: "", nameEn: "", price: "", schedules: [], newSchedule: "" });

    const [cities, setCities] = useState<City[]>([]);
    const [loading, setLoading] = useState(true);

    const fetchData = async () => {
        setLoading(true);
        try {
            const [citiesRes, boardingRes, arrivalRes] = await Promise.all([
                supabase.from('cities').select('*').order('created_at', { ascending: true }),
                supabase.from('boarding_stations').select('*').order('created_at', { ascending: true }),
                supabase.from('arrival_stations').select('*').order('created_at', { ascending: true })
            ]);

            if (citiesRes.data) {
                const mappedCities: City[] = citiesRes.data.map((c: any) => {
                    const cityBoardings = boardingRes.data?.filter((b: any) => b.city_id === c.id) || [];
                    return {
                        id: c.id,
                        nameAr: c.name_ar,
                        nameEn: c.name_en,
                        boardingStations: cityBoardings.map((b: any) => {
                            const bArrivals = arrivalRes.data?.filter((a: any) => a.boarding_station_id === b.id) || [];
                            return {
                                id: b.id,
                                nameAr: b.name_ar,
                                nameEn: b.name_en,
                                arrivalStations: bArrivals.map((a: any) => ({
                                    id: a.id,
                                    nameAr: a.name_ar,
                                    nameEn: a.name_en,
                                    price: Number(a.price),
                                    schedules: typeof a.schedules === 'string' ? JSON.parse(a.schedules) : a.schedules || []
                                }))
                            };
                        })
                    };
                });
                setCities(mappedCities);

                // Auto-select first item if nothing is selected
                if (mappedCities.length > 0 && !selectedCityId) {
                    setSelectedCityId(mappedCities[0].id);
                    if (mappedCities[0].boardingStations.length > 0) {
                        setSelectedBoardingId(mappedCities[0].boardingStations[0].id);
                    }
                }
            }
        } catch (error) {
            console.error("Error fetching data:", error);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchData();
    }, []);

    const selectedCity = cities.find(c => c.id === selectedCityId) || null;
    const selectedBoarding = selectedCity?.boardingStations.find(p => p.id === selectedBoardingId) || null;

    const handleCitySelect = (cityId: string) => {
        setSelectedCityId(cityId);
        setSelectedBoardingId(null);
    };

    const openModal = (type: 'city' | 'boarding' | 'arrival', editId: string | null = null, editData: any = null) => {
        setShowModal(type);
        setEditEntityId(editId);
        if (editData) {
            setModalData(editData);
        } else {
            setModalData({ nameAr: "", nameEn: "", price: "", schedules: [], newSchedule: "" });
        }
    };

    const handleAddSchedule = () => {
        if (modalData.newSchedule.trim()) {
            setModalData(prev => ({
                ...prev,
                schedules: [...prev.schedules, prev.newSchedule.trim()],
                newSchedule: ""
            }));
        }
    };

    const handleRemoveSchedule = (idxToRemove: number) => {
        setModalData(prev => ({
            ...prev,
            schedules: prev.schedules.filter((_, idx) => idx !== idxToRemove)
        }));
    };

    const handleDelete = async (type: 'city' | 'boarding' | 'arrival', id: string) => {
        if (!window.confirm("هل أنت متأكد من الحذف؟")) return;
        setLoading(true);
        let tableName = '';
        if (type === 'city') tableName = 'cities';
        else if (type === 'boarding') tableName = 'boarding_stations';
        else if (type === 'arrival') tableName = 'arrival_stations';

        const { error } = await supabase.from(tableName).delete().eq('id', id);

        if (!error) {
            fetchData();
            if (type === 'city' && selectedCityId === id) {
                setSelectedCityId(null);
                setSelectedBoardingId(null);
            } else if (type === 'boarding' && selectedBoardingId === id) {
                setSelectedBoardingId(null);
            }
        } else {
            console.error("Delete error:", error);
            alert("حدث خطأ أثناء الحذف");
        }
        setLoading(false);
    };

    const handleSaveEntity = async () => {
        setLoading(true);
        if (showModal === 'city') {
            if (editEntityId) {
                const { error } = await supabase.from('cities').update({ name_ar: modalData.nameAr, name_en: modalData.nameEn }).eq('id', editEntityId);
                if (!error) fetchData();
                else console.error("Error updating city:", error);
            } else {
                const { data, error } = await supabase.from('cities').insert([{ name_ar: modalData.nameAr, name_en: modalData.nameEn, is_active: true }]).select().single();
                if (!error && data) {
                    setSelectedCityId(data.id);
                    fetchData();
                } else console.error("Error creating city:", error);
            }
        }
        else if (showModal === 'boarding' && selectedCityId) {
            if (editEntityId) {
                const { error } = await supabase.from('boarding_stations').update({ name_ar: modalData.nameAr, name_en: modalData.nameEn }).eq('id', editEntityId);
                if (!error) fetchData();
                else console.error("Error updating boarding station:", error);
            } else {
                const { data, error } = await supabase.from('boarding_stations').insert([{ city_id: selectedCityId, name_ar: modalData.nameAr, name_en: modalData.nameEn }]).select().single();
                if (!error && data) {
                    setSelectedBoardingId(data.id);
                    fetchData();
                } else console.error("Error creating boarding station:", error, modalData);
            }
        }
        else if (showModal === 'arrival' && selectedCityId && selectedBoardingId) {
            if (editEntityId) {
                const { error } = await supabase.from('arrival_stations').update({
                    name_ar: modalData.nameAr,
                    name_en: modalData.nameEn,
                    price: Number(modalData.price) || 0,
                    schedules: modalData.schedules
                }).eq('id', editEntityId);
                if (!error) fetchData();
                else console.error("Error updating arrival station:", error);
            } else {
                const { error } = await supabase.from('arrival_stations').insert([{
                    boarding_station_id: selectedBoardingId,
                    name_ar: modalData.nameAr,
                    name_en: modalData.nameEn,
                    price: Number(modalData.price) || 0,
                    schedules: modalData.schedules
                }]);
                if (!error) fetchData();
                else console.error("Error creating arrival station:", error);
            }
        }
        setLoading(false);
        setShowModal(null);
        setEditEntityId(null);
    };

const isFormValid = () => {
    if (!modalData.nameAr || !modalData.nameEn) return false;
    if (showModal === 'arrival') {
        if (!modalData.price || modalData.schedules.length === 0) return false;
    }
    return true;
};

return (
    <>
        <div className="space-y-8 animate-fade-up h-[calc(100vh-8rem)] flex flex-col">
            {/* Header */}
            <div className="flex items-end justify-between shrink-0">
                <div>
                    <h2 className="text-3xl font-black italic mb-2">إدارة الخطوط والمحطات</h2>
                    <p className="text-[10px] text-text-dim uppercase tracking-widest">
                        Network Hubs & Routing Management
                    </p>
                </div>
                {loading && <Loader2 className="animate-spin text-primary-gold" size={24} />}
            </div>

            {/* 3-Column Layout */}
            <div className="flex-1 grid grid-cols-3 gap-6 min-h-0">

                {/* Column 1: Cities */}
                <div className="glass-card p-0 flex flex-col h-full overflow-hidden border-white/5 shadow-2xl">
                    <div className="p-5 border-b border-white/5 flex items-center justify-between bg-black/40 shrink-0">
                        <h3 className="font-black text-lg flex items-center gap-2">
                            <Building2 size={18} className="text-primary-gold" />
                            المدن الرئيسية
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
                                <div className="flex items-center gap-1 opacity-100 lg:opacity-0 lg:group-hover:opacity-100 transition-opacity">
                                    <button
                                        type="button"
                                        onClick={(e) => { e.preventDefault(); e.stopPropagation(); openModal('city', city.id, { nameAr: city.nameAr, nameEn: city.nameEn, price: "", schedules: [], newSchedule: "" }); }}
                                        className="p-1.5 hover:bg-white/10 text-text-dim hover:text-white transition-colors"
                                    >
                                        <Pencil size={14} />
                                    </button>
                                    <button
                                        type="button"
                                        onClick={(e) => { e.preventDefault(); e.stopPropagation(); handleDelete('city', city.id); }}
                                        className="p-1.5 hover:bg-state-error/20 text-text-dim hover:text-state-error transition-colors"
                                    >
                                        <Trash2 size={14} />
                                    </button>
                                    <ChevronLeft size={16} className={cn(
                                        "transition-all ml-1",
                                        selectedCityId === city.id ? "opacity-100" : "opacity-0 -translate-x-2 lg:group-hover:opacity-50 lg:group-hover:translate-x-0"
                                    )} />
                                </div>
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

                {/* Column 2: Boarding Stations */}
                <div className={cn(
                    "glass-card p-0 flex flex-col h-full overflow-hidden border-white/5 shadow-2xl transition-all duration-300",
                    !selectedCityId && "opacity-50 grayscale pointer-events-none"
                )}>
                    <div className="p-5 border-b border-white/5 flex items-center justify-between bg-black/40 shrink-0">
                        <h3 className="font-black text-lg flex items-center gap-2">
                            <MapPinned size={18} className="text-white" />
                            محطات الركوب
                        </h3>
                        <button
                            onClick={() => openModal('boarding')}
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
                        ) : selectedCity?.boardingStations.length === 0 ? (
                            <div className="h-full flex flex-col items-center justify-center text-center p-6 opacity-50">
                                <MapPinned size={32} className="mb-4 text-text-dim" />
                                <p className="text-xs font-black uppercase tracking-widest text-text-dim">لا توجد محطات ركوب</p>
                            </div>
                        ) : (
                            selectedCity?.boardingStations.map((boarding) => (
                                <div
                                    key={boarding.id}
                                    onClick={() => setSelectedBoardingId(boarding.id)}
                                    className={cn(
                                        "p-4 cursor-pointer transition-all border flex items-center justify-between group",
                                        selectedBoardingId === boarding.id
                                            ? "bg-white/10 border-white text-white"
                                            : "bg-surface-dark border-transparent hover:bg-white/5 text-text-main hover:border-white/10"
                                    )}
                                >
                                    <div>
                                        <h4 className="font-black text-base mb-1">{boarding.nameAr}</h4>
                                        <p className={cn(
                                            "text-[10px] uppercase font-bold tracking-widest",
                                            selectedBoardingId === boarding.id ? "text-white/70" : "text-text-dim"
                                        )}>{boarding.nameEn}</p>
                                    </div>
                                    <div className="flex items-center gap-1 opacity-100 lg:opacity-0 lg:group-hover:opacity-100 transition-opacity">
                                        <button
                                            type="button"
                                            onClick={(e) => { e.preventDefault(); e.stopPropagation(); openModal('boarding', boarding.id, { nameAr: boarding.nameAr, nameEn: boarding.nameEn, price: "", schedules: [], newSchedule: "" }); }}
                                            className="p-1.5 hover:bg-white/10 text-text-dim hover:text-white transition-colors"
                                        >
                                            <Pencil size={14} />
                                        </button>
                                        <button
                                            type="button"
                                            onClick={(e) => { e.preventDefault(); e.stopPropagation(); handleDelete('boarding', boarding.id); }}
                                            className="p-1.5 hover:bg-state-error/20 text-text-dim hover:text-state-error transition-colors"
                                        >
                                            <Trash2 size={14} />
                                        </button>
                                        <ChevronLeft size={16} className={cn(
                                            "transition-all ml-1",
                                            selectedBoardingId === boarding.id ? "opacity-100" : "opacity-0 -translate-x-2 lg:group-hover:opacity-50 lg:group-hover:translate-x-0"
                                        )} />
                                    </div>
                                </div>
                            ))
                        )}
                    </div>
                </div>

                {/* Column 3: Arrival Stations */}
                <div className={cn(
                    "glass-card p-0 flex flex-col h-full overflow-hidden border-white/5 shadow-2xl transition-all duration-300",
                    !selectedBoardingId && "opacity-50 grayscale pointer-events-none"
                )}>
                    <div className="p-5 border-b border-white/5 flex items-center justify-between bg-black/40 shrink-0">
                        <h3 className="font-black text-lg flex items-center gap-2">
                            <MapPin size={18} className="text-state-success" />
                            محطات الوصول
                        </h3>
                        <button
                            onClick={() => openModal('arrival')}
                            disabled={!selectedBoardingId}
                            className="w-8 h-8 flex items-center justify-center bg-state-success text-bg-black hover:bg-white disabled:opacity-50 transition-all font-black"
                        >
                            <Plus size={16} />
                        </button>
                    </div>
                    <div className="flex-1 overflow-y-auto p-3 space-y-2">
                        {!selectedBoardingId ? (
                            <div className="h-full flex flex-col items-center justify-center text-center p-6">
                                <p className="text-xs font-black uppercase tracking-widest text-text-dim">اختر محطة ركوب أولاً</p>
                            </div>
                        ) : selectedBoarding?.arrivalStations.length === 0 ? (
                            <div className="h-full flex flex-col items-center justify-center text-center p-6 opacity-50">
                                <MapPin size={32} className="mb-4 text-text-dim" />
                                <p className="text-xs font-black uppercase tracking-widest text-text-dim">لا توجد محطات وصول مضافة</p>
                            </div>
                        ) : (
                            selectedBoarding?.arrivalStations.map((arrival) => (
                                <div
                                    key={arrival.id}
                                    className="p-4 bg-surface-dark border border-white/5 flex flex-col hover:border-white/10 transition-all gap-3"
                                >
                                    <div className="flex items-center justify-between">
                                        <div className="text-left flex flex-col items-end gap-2">
                                            <p className="text-sm font-black text-state-success flex items-center gap-1 justify-end">
                                                {arrival.price} <span className="text-[10px] text-text-dim">EGP</span>
                                            </p>
                                            <div className="flex items-center gap-1 opacity-100 lg:opacity-0 lg:group-hover:opacity-100 transition-opacity">
                                                <button
                                                    type="button"
                                                    onClick={(e) => { e.preventDefault(); e.stopPropagation(); openModal('arrival', arrival.id, { nameAr: arrival.nameAr, nameEn: arrival.nameEn, price: arrival.price.toString(), schedules: arrival.schedules, newSchedule: "" }); }}
                                                    className="p-1.5 hover:bg-white/10 text-text-dim hover:text-white transition-colors bg-white/5 rounded"
                                                >
                                                    <Pencil size={12} />
                                                </button>
                                                <button
                                                    type="button"
                                                    onClick={(e) => { e.preventDefault(); e.stopPropagation(); handleDelete('arrival', arrival.id); }}
                                                    className="p-1.5 hover:bg-state-error/20 text-text-dim hover:text-state-error transition-colors bg-white/5 rounded"
                                                >
                                                    <Trash2 size={12} />
                                                </button>
                                            </div>
                                        </div>
                                    </div>

                                    <div className="flex flex-wrap gap-2 pt-2 border-t border-white/5">
                                        {arrival.schedules.map((time, idx) => (
                                            <span key={idx} className="bg-white/5 border border-white/10 px-2 py-1 text-[9px] font-bold text-text-main flex items-center gap-1">
                                                <Clock size={10} className="text-primary-gold" />
                                                {time}
                                            </span>
                                        ))}
                                    </div>
                                </div>
                            ))
                        )}
                    </div>
                </div>
            </div>
        </div>

        {/* Modal - Enhanced with Pricing and Scheduling */}
        {showModal && (
            <div className="fixed inset-0 z-100 flex items-center justify-center p-6 bg-bg-black/80 backdrop-blur-md animate-fade-in">
                <div className="glass-card w-full max-w-lg p-10 space-y-8 shadow-2xl border-white/10 animate-fade-up">
                    <div className="flex items-start justify-between">
                        <div>
                            <div className="flex items-center gap-2 mb-2">
                                <div className="w-1.5 h-1.5 bg-primary-gold" />
                                <span className="text-[10px] font-black uppercase tracking-[0.3em] text-primary-gold">
                                    {showModal === 'city' ? 'City' :
                                        showModal === 'boarding' ? 'Boarding Station' : 'Arrival Config'}
                                </span>
                            </div>
                            <h3 className="text-xl font-black italic uppercase leading-none">
                                {editEntityId ?
                                    (showModal === 'city' ? 'تعديل مدينة' :
                                        showModal === 'boarding' ? `تعديل محطة ركوب في ${selectedCity?.nameAr}` :
                                            `تعديل محطة وصول وإعداد رحلة`)
                                    :
                                    (showModal === 'city' ? 'إضافة مدينة' :
                                        showModal === 'boarding' ? `محطة ركوب في ${selectedCity?.nameAr}` :
                                            `محطة وصول وإعداد رحلة`)
                                }
                            </h3>
                        </div>
                        <button
                            onClick={() => setShowModal(null)}
                            className="w-10 h-10 shrink-0 flex items-center justify-center border border-white/5 hover:bg-white/5 text-text-dim hover:text-text-main transition-all"
                        >
                            <X size={20} />
                        </button>
                    </div>

                    <div className="space-y-6">
                        {/* Name Fields */}
                        <div className="grid grid-cols-2 gap-4">
                            <div className="space-y-2 col-span-2">
                                <div className="flex justify-between items-center">
                                    <label className="text-[10px] font-black uppercase text-text-dim tracking-widest">الاسم بالعربي</label>
                                </div>
                                <input
                                    type="text"
                                    autoFocus
                                    value={modalData.nameAr}
                                    onChange={(e) => setModalData({ ...modalData, nameAr: e.target.value })}
                                    className="w-full h-14 bg-white/5 border border-white/10 px-4 text-sm font-bold placeholder:text-text-dim/20 outline-none focus:border-primary-gold transition-all text-right"
                                    placeholder="مثال: محطة التجمع"
                                />
                            </div>
                            <div className="space-y-2 col-span-2">
                                <div className="flex justify-between items-center text-left">
                                    <label className="text-[10px] font-black uppercase text-text-dim tracking-widest">English Name</label>
                                </div>
                                <input
                                    type="text"
                                    value={modalData.nameEn}
                                    onChange={(e) => setModalData({ ...modalData, nameEn: e.target.value })}
                                    className="w-full h-14 bg-white/5 border border-white/10 px-4 text-sm font-bold placeholder:text-text-dim/20 outline-none focus:border-primary-gold transition-all text-left"
                                    placeholder="Example: Tagamoa Station"
                                />
                            </div>
                        </div>

                        {/* Arrival Specific Fields (Pricing & Schedules) */}
                        {showModal === 'arrival' && (
                            <div className="p-5 bg-black/40 border border-white/5 space-y-6 mt-6">
                                {/* Price */}
                                <div className="space-y-2">
                                    <label className="text-[10px] font-black uppercase text-text-main tracking-widest flex items-center gap-2">
                                        <Banknote size={14} className="text-state-success" />
                                        سعر التذكرة (EGP)
                                    </label>
                                    <input
                                        type="number"
                                        value={modalData.price}
                                        onChange={(e) => setModalData({ ...modalData, price: e.target.value })}
                                        className="w-full h-14 bg-white/5 border border-white/10 px-4 text-sm font-bold placeholder:text-text-dim/20 outline-none focus:border-state-success transition-all text-left dir-ltr"
                                        placeholder="0.00"
                                    />
                                </div>

                                {/* Schedules */}
                                <div className="space-y-3">
                                    <label className="text-[10px] font-black uppercase text-text-main tracking-widest flex items-center gap-2">
                                        <Clock size={14} className="text-primary-gold" />
                                        مواعيد الرحلات
                                    </label>
                                    <div className="flex gap-2">
                                        <button
                                            onClick={handleAddSchedule}
                                            disabled={!modalData.newSchedule}
                                            className="h-14 px-8 bg-[#1A1A1A] hover:bg-white/5 text-text-main font-black text-[10px] uppercase tracking-widest disabled:opacity-50 transition-all border border-white/10"
                                        >
                                            إضافة
                                        </button>
                                        <input
                                            type="time"
                                            value={modalData.newSchedule}
                                            onChange={(e) => setModalData({ ...modalData, newSchedule: e.target.value })}
                                            className="flex-1 h-14 bg-[#1A1A1A] border border-white/10 px-6 text-sm font-bold font-display outline-none focus:border-primary-gold transition-all text-center dir-ltr text-white"
                                            style={{ colorScheme: 'dark' }}
                                        />
                                    </div>

                                    {/* Schedule Chips */}
                                    {modalData.schedules.length > 0 && (
                                        <div className="flex flex-wrap gap-3 pt-3">
                                            {modalData.schedules.map((time, idx) => (
                                                <div key={idx} className="bg-[#1A1A1A] border border-white/10 px-5 py-2.5 flex items-center gap-4 hover:border-white/20 transition-all group cursor-default" dir="ltr">
                                                    <button
                                                        onClick={() => handleRemoveSchedule(idx)}
                                                        className="text-text-dim group-hover:text-state-error transition-colors focus:outline-none flex items-center justify-center shrink-0"
                                                    >
                                                        <X size={15} />
                                                    </button>
                                                    <span className="text-sm font-bold font-display tracking-widest text-[#E0E0E0] group-hover:text-white transition-colors">{time}</span>
                                                </div>
                                            ))}
                                        </div>
                                    )}
                                </div>
                            </div>
                        )}

                        <div className="flex gap-4 pt-4 border-t border-white/5 mt-8">
                            <button
                                onClick={() => setShowModal(null)}
                                className="flex-1 h-14 text-[10px] font-black uppercase tracking-widest text-text-dim hover:text-text-main transition-all border border-white/5 hover:bg-white/5"
                            >
                                إلغاء
                            </button>
                            <button
                                onClick={handleSaveEntity}
                                disabled={!isFormValid() || loading}
                                className="flex-1 h-14 bg-text-main text-bg-black font-display font-black text-xs uppercase tracking-widest transition-all hover:bg-primary-gold disabled:opacity-50 disabled:hover:bg-text-main active:scale-95 px-6"
                            >
                                {loading ? <Loader2 className="animate-spin mx-auto" size={16} /> : 'حفظ'}
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        )}
    </>
);
}
