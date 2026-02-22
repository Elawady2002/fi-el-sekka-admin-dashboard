"use client";

import { useEffect, useState } from "react";
import { Plus, MapPin, Search, Edit2, Trash2, ChevronDown, ChevronUp, Loader2, X } from "lucide-react";
import { cn } from "@/lib/utils";
import { db } from "@/lib/database";
import { City, Station, StationType } from "@/types/database";

export default function CitiesPage() {
    const [cities, setCities] = useState<City[]>([]);
    const [stations, setStations] = useState<Station[]>([]);
    const [loading, setLoading] = useState(true);
    const [expandedCity, setExpandedCity] = useState<string | null>(null);
    const [searchQuery, setSearchQuery] = useState("");

    // Modal States
    const [cityModal, setCityModal] = useState<{ open: boolean; city?: City }>({ open: false });
    const [stationModal, setStationModal] = useState<{ open: boolean; cityId?: string; station?: Station }>({ open: false });

    async function fetchData() {
        try {
            const [citiesData, stationsData] = await Promise.all([
                db.getCities(),
                db.getStations()
            ]);
            setCities(citiesData);
            setStations(stationsData);
        } catch (error) {
            console.error("Error fetching data:", error);
        } finally {
            setLoading(false);
        }
    }

    useEffect(() => {
        fetchData();
    }, []);

    const toggleCity = (id: string | null) => {
        setExpandedCity(expandedCity === id ? null : id);
    };

    const filteredCities = cities.filter(city =>
        city.name_ar.includes(searchQuery) ||
        city.name_en.toLowerCase().includes(searchQuery.toLowerCase())
    );

    const getCityStations = (cityId: string) => {
        return stations.filter(s => s.city_id === cityId);
    };

    const handleDeleteCity = async (id: string) => {
        if (!confirm("هل أنت متأكد من حذف هذه المدينة؟ سيتم حذف جميع المحطات التابعة لها أيضاً.")) return;
        try {
            await db.deleteCity(id);
            setCities(prev => prev.filter(c => c.id !== id));
        } catch (error) {
            alert("حدث خطأ أثناء الحذف");
        }
    };

    const handleDeleteStation = async (id: string) => {
        if (!confirm("هل أنت متأكد من حذف هذه المحطة؟")) return;
        try {
            await db.deleteStation(id);
            setStations(prev => prev.filter(s => s.id !== id));
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
        <div className="p-6 space-y-6">
            {/* Header */}
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 text-right">
                <div>
                    <h1 className="text-2xl font-bold text-text-primary">من موقف لموقف</h1>
                    <p className="text-sm text-text-secondary">إدارة نقاط التوقف وشبكة النقل من قاعدة البيانات</p>
                </div>
                <button
                    onClick={() => setCityModal({ open: true })}
                    className="btn-primary"
                >
                    <Plus size={18} />
                    <span>إضافة منطقة جديدة</span>
                </button>
            </div>

            {/* Search */}
            <div className="relative">
                <Search className="absolute right-3 top-1/2 -translate-y-1/2 text-text-muted" size={18} />
                <input
                    type="text"
                    placeholder="بحث عن منطقة أو نقطة..."
                    className="w-full bg-surface-dark border border-border-dark rounded-xl py-2.5 pr-10 pl-4 text-right text-sm focus:border-primary-green transition-colors outline-none"
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                />
            </div>

            {/* Cities List */}
            <div className="grid gap-4">
                {filteredCities.map((city) => (
                    <div key={city.id} className="card overflow-hidden text-right border-border-dark">
                        <div
                            className={cn(
                                "flex items-center justify-between p-4 cursor-pointer transition-colors",
                                expandedCity === city.id ? "bg-primary-green/5" : "hover:bg-white/2"
                            )}
                            onClick={() => toggleCity(city.id)}
                        >
                            <div className="flex items-center gap-3">
                                <div className="w-10 h-10 rounded-lg bg-primary-green/10 flex items-center justify-center text-primary-green">
                                    <MapPin size={20} />
                                </div>
                                <div className="text-right">
                                    <h3 className="font-bold text-text-primary">{city.name_ar}</h3>
                                    <p className="text-xs text-text-secondary">{getCityStations(city.id).length} نقطة توقف</p>
                                </div>
                            </div>

                            <div className="flex items-center gap-4">
                                <div className="flex items-center gap-2">
                                    <button
                                        onClick={(e) => { e.stopPropagation(); setCityModal({ open: true, city }); }}
                                        className="p-2 hover:bg-white/5 rounded-lg text-text-secondary hover:text-primary-green transition-colors"
                                    >
                                        <Edit2 size={16} />
                                    </button>
                                    <button
                                        onClick={(e) => { e.stopPropagation(); handleDeleteCity(city.id); }}
                                        className="p-2 hover:bg-white/5 rounded-lg text-text-secondary hover:text-accent-red transition-colors"
                                    >
                                        <Trash2 size={16} />
                                    </button>
                                </div>
                                {expandedCity === city.id ? <ChevronUp size={20} /> : <ChevronDown size={20} />}
                            </div>
                        </div>

                        {expandedCity === city.id && (
                            <div className="border-t border-border-dark bg-[#1a1a1a]/50">
                                <div className="p-4 flex items-center justify-between border-b border-border-dark">
                                    <h4 className="text-sm font-bold text-text-primary">قائمة النقاط</h4>
                                    <button
                                        onClick={() => setStationModal({ open: true, cityId: city.id })}
                                        className="text-xs text-primary-green hover:underline flex items-center gap-1 font-bold"
                                    >
                                        <Plus size={14} />
                                        <span>إضافة نقطة</span>
                                    </button>
                                </div>
                                <div className="divide-y divide-border-dark">
                                    {getCityStations(city.id).map((station) => (
                                        <div key={station.id} className="flex items-center justify-between p-4 hover:bg-white/5 transition-colors">
                                            <div className="flex items-center gap-3">
                                                <div className={cn(
                                                    "w-2 h-2 rounded-full",
                                                    station.station_type === "pickup" ? "bg-primary-green" :
                                                        station.station_type === "dropoff" ? "bg-accent-blue" : "bg-accent-purple"
                                                )} />
                                                <div className="text-right">
                                                    <p className="text-sm font-medium text-text-primary">{station.name_ar}</p>
                                                    <p className="text-[10px] text-text-secondary">
                                                        {station.station_type === 'pickup' ? 'صعود' :
                                                            station.station_type === 'dropoff' ? 'نزول' : 'صعود ونزول'}
                                                    </p>
                                                    {station.destination_ids && station.destination_ids.length > 0 && (
                                                        <div className="flex flex-wrap gap-1 mt-1">
                                                            {station.destination_ids.map(id => {
                                                                const dest = stations.find(s => s.id === id);
                                                                return dest ? (
                                                                    <span key={id} className="text-[9px] bg-white/5 text-text-muted px-1.5 py-0.5 rounded border border-border-dark">
                                                                        إلى: {dest.name_ar}
                                                                    </span>
                                                                ) : null;
                                                            })}
                                                        </div>
                                                    )}
                                                </div>
                                            </div>
                                            <div className="flex items-center gap-2">
                                                <button
                                                    onClick={() => setStationModal({ open: true, cityId: city.id, station })}
                                                    className="p-2 hover:bg-white/5 rounded-lg text-text-muted hover:text-primary-green"
                                                >
                                                    <Edit2 size={14} />
                                                </button>
                                                <button
                                                    onClick={() => handleDeleteStation(station.id)}
                                                    className="p-2 hover:bg-white/5 rounded-lg text-text-muted hover:text-accent-red"
                                                >
                                                    <Trash2 size={14} />
                                                </button>
                                            </div>
                                        </div>
                                    ))}
                                    {getCityStations(city.id).length === 0 && (
                                        <p className="p-4 text-xs text-text-muted text-center italic">لا توجد نقاط مضافة لهذه المنطقة بعد.</p>
                                    )}
                                </div>
                            </div>
                        )}
                    </div>
                ))}
            </div>

            {/* City Modal */}
            {cityModal.open && (
                <div className="fixed inset-0 z-100 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm">
                    <div className="bg-surface-dark border border-border-dark rounded-2xl w-full max-w-md p-6 space-y-6 shadow-2xl text-right">
                        <div className="flex items-center justify-between">
                            <button onClick={() => setCityModal({ open: false })} className="text-text-muted hover:text-white">
                                <X size={20} />
                            </button>
                            <h2 className="text-xl font-bold text-white">{cityModal.city ? 'تعديل منطقة' : 'إضافة منطقة جديدة'}</h2>
                        </div>

                        <form className="space-y-4" onSubmit={async (e) => {
                            e.preventDefault();
                            const formData = new FormData(e.currentTarget);
                            const name_ar = formData.get('name_ar') as string;
                            const name_en = formData.get('name_en') as string;
                            try {
                                if (cityModal.city) {
                                    await db.updateCity(cityModal.city.id, { name_ar, name_en });
                                } else {
                                    const newCity = await db.addCity({ name_ar, name_en, is_active: true });
                                    setExpandedCity(newCity.id);
                                }
                                setCityModal({ open: false });
                                await fetchData();
                            } catch (err) { alert("حدث خطأ"); }
                        }}>
                            <div className="space-y-1.5">
                                <label className="text-xs text-text-secondary">الاسم بالعربية</label>
                                <input name="name_ar" required defaultValue={cityModal.city?.name_ar} className="w-full bg-white/5 border border-border-dark rounded-xl py-2 px-4 text-right outline-none focus:border-primary-green" placeholder="مثال: الشروق" />
                            </div>
                            <div className="space-y-1.5">
                                <label className="text-xs text-text-secondary italic">Name (English)</label>
                                <input name="name_en" required defaultValue={cityModal.city?.name_en} className="w-full bg-white/5 border border-border-dark rounded-xl py-2 px-4 text-left outline-none focus:border-primary-green font-mono" placeholder="Ex: Al-Shorouk" />
                            </div>
                            <button className="btn-primary w-full py-3 mt-4">حفظ البيانات</button>
                        </form>
                    </div>
                </div>
            )}

            {/* Station Modal */}
            {stationModal.open && (
                <div className="fixed inset-0 z-100 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm">
                    <div className="card-no-hover w-full max-w-md p-6 space-y-6 shadow-2xl text-right animate-in fade-in zoom-in duration-200">
                        <div className="flex items-center justify-between">
                            <button onClick={() => setStationModal({ open: false })} className="text-text-muted hover:text-white">
                                <X size={20} />
                            </button>
                            <h2 className="text-xl font-bold text-white">{stationModal.station ? 'تعديل نقطة' : 'إضافة نقطة جديدة'}</h2>
                        </div>

                        <form className="space-y-4" onSubmit={async (e) => {
                            e.preventDefault();
                            const formData = new FormData(e.currentTarget);
                            const name_ar = formData.get('name_ar') as string;
                            const name_en = formData.get('name_en') as string;
                            const station_type = formData.get('station_type') as StationType;
                            const destination_ids = formData.getAll('destination_ids') as string[];

                            try {
                                if (stationModal.station) {
                                    await db.updateStation(stationModal.station.id, {
                                        name_ar,
                                        name_en,
                                        station_type,
                                        destination_ids
                                    });
                                } else {
                                    await db.addStation({
                                        name_ar,
                                        name_en,
                                        station_type,
                                        city_id: stationModal.cityId,
                                        is_active: true,
                                        destination_ids
                                    });
                                }
                                setStationModal({ open: false });
                                await fetchData();
                            } catch (err) { alert("حدث خطأ"); }
                        }}>
                            <div className="space-y-1.5">
                                <label className="text-xs text-text-secondary">اسم النقطة بالعربية</label>
                                <input name="name_ar" required defaultValue={stationModal.station?.name_ar} className="w-full bg-white/5 border border-border-dark rounded-xl py-2 px-4 text-right outline-none focus:border-primary-green" placeholder="مثال: بوابه 1" />
                            </div>
                            <div className="space-y-1.5">
                                <label className="text-xs text-text-secondary italic">Point Name (English)</label>
                                <input name="name_en" required defaultValue={stationModal.station?.name_en} className="w-full bg-white/5 border border-border-dark rounded-xl py-2 px-4 text-left outline-none focus:border-primary-green font-mono" placeholder="Ex: Gate 1" />
                            </div>

                            <div className="space-y-2">
                                <label className="text-xs text-text-secondary">نوع النقطة (صعود/نزول)</label>
                                <div className="grid grid-cols-3 gap-2">
                                    {['pickup', 'dropoff', 'both'].map((type) => (
                                        <label key={type} className={cn(
                                            "flex flex-col items-center gap-2 p-3 rounded-xl border cursor-pointer transition-all",
                                            (stationModal.station?.station_type === type || (!stationModal.station && type === 'pickup')) ? "border-primary-green bg-primary-green/10" : "border-border-dark hover:bg-white/5"
                                        )}>
                                            <input type="radio" name="station_type" value={type} defaultChecked={stationModal.station?.station_type === type || (type === 'pickup' && !stationModal.station)} className="hidden" />
                                            <div className={cn(
                                                "w-3 h-3 rounded-full",
                                                type === 'pickup' ? "bg-primary-green" : type === 'dropoff' ? "bg-accent-blue" : "bg-accent-purple"
                                            )} />
                                            <span className="text-[10px] font-bold">
                                                {type === 'pickup' ? 'صعود' : type === 'dropoff' ? 'نزول' : 'الكل'}
                                            </span>
                                        </label>
                                    ))}
                                </div>
                            </div>

                            <div className="space-y-3">
                                <label className="text-xs font-bold text-text-secondary pr-1 border-r-2 border-primary-green">نقاط الوصول (المواقف المستهدفة)</label>
                                <div className="max-h-60 overflow-y-auto border border-border-dark rounded-2xl bg-black/20 p-3 space-y-4 scrollbar-thin">
                                    {cities.map(c => {
                                        const cityStations = stations.filter(s => s.city_id === c.id && s.id !== stationModal.station?.id);
                                        if (cityStations.length === 0) return null;
                                        return (
                                            <div key={c.id} className="space-y-2">
                                                <div className="flex items-center gap-2 px-1">
                                                    <div className="w-1.5 h-1.5 rounded-full bg-primary-green" />
                                                    <p className="text-[11px] font-bold text-primary-green">{c.name_ar}</p>
                                                </div>
                                                <div className="grid grid-cols-2 gap-2">
                                                    {cityStations.map(s => (
                                                        <label key={s.id} className="flex items-center gap-3 p-2.5 bg-white/5 hover:bg-primary-green/10 rounded-xl cursor-pointer transition-all border border-border-dark/50 hover:border-primary-green/30 group">
                                                            <div className="relative flex items-center justify-center">
                                                                <input
                                                                    type="checkbox"
                                                                    name="destination_ids"
                                                                    value={s.id}
                                                                    defaultChecked={stationModal.station?.destination_ids?.includes(s.id)}
                                                                    className="w-4 h-4 accent-primary-green rounded cursor-pointer"
                                                                />
                                                            </div>
                                                            <span className="text-[11px] text-text-primary truncate font-medium group-hover:text-primary-green transition-colors">{s.name_ar}</span>
                                                        </label>
                                                    ))}
                                                </div>
                                            </div>
                                        );
                                    })}
                                </div>
                                <p className="text-[10px] text-text-muted italic px-1">الرجاء تحديد المواقف التي يمكن التحرك إليها من هذه النقطة.</p>
                            </div>

                            <button className="btn-primary w-full py-3 mt-4">حفظ البيانات</button>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}
