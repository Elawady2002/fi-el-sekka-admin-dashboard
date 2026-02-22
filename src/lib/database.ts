import { supabase } from './supabase';
import {
    City, Station, Route, Trip, User, Subscription, Booking, FAQ
} from '../types/database';

export const db = {
    // Cities & Stations
    async getCities() {
        const { data, error } = await supabase.from('cities').select('*').order('name_ar');
        if (error) throw error;
        return data as City[];
    },

    async getStations() {
        const { data, error } = await supabase.from('stations').select('*, cities(*)').order('name_ar');
        if (error) {
            console.error("getStations error:", error);
            throw error;
        }
        return data as Station[];
    },

    async addCity(city: Partial<City>) {
        const { data, error } = await supabase.from('cities').insert([city]).select();
        if (error) throw error;
        return data[0] as City;
    },

    async updateCity(id: string, city: Partial<City>) {
        const { data, error } = await supabase.from('cities').update(city).eq('id', id).select();
        if (error) throw error;
        return data[0] as City;
    },

    async deleteCity(id: string) {
        const { error } = await supabase.from('cities').delete().eq('id', id);
        if (error) throw error;
    },

    async addStation(station: Partial<Station>) {
        const { data, error } = await supabase.from('stations').insert([station]).select();
        if (error) throw error;
        return data[0] as Station;
    },

    async updateStation(id: string, station: Partial<Station>) {
        const { data, error } = await supabase.from('stations').update(station).eq('id', id).select();
        if (error) throw error;
        return data[0] as Station;
    },

    async deleteStation(id: string) {
        const { error } = await supabase.from('stations').delete().eq('id', id);
        if (error) throw error;
    },

    // Routes & Universities
    async getRoutes() {
        const { data, error } = await supabase.from('routes').select('*, universities(*)').order('route_name_ar');
        if (error) {
            console.error("getRoutes error:", error);
            throw error;
        }
        return data as Route[];
    },

    async addRoute(route: Partial<Route>) {
        const { data, error } = await supabase.from('routes').insert([route]).select();
        if (error) throw error;
        return data[0] as Route;
    },

    async updateRoute(id: string, route: Partial<Route>) {
        const { data, error } = await supabase.from('routes').update(route).eq('id', id).select();
        if (error) throw error;
        return data[0] as Route;
    },

    async deleteRoute(id: string) {
        const { error } = await supabase.from('routes').delete().eq('id', id);
        if (error) throw error;
    },

    async getUniversities() {
        const { data, error } = await supabase.from('universities').select('*').order('name_ar');
        if (error) throw error;
        return data as any[];
    },

    // Subscriptions
    async getPendingSubscriptions() {
        const { data, error } = await supabase
            .from('subscriptions')
            .select('*, users(*)')
            .eq('status', 'pending')
            .order('created_at', { ascending: false });
        if (error) throw error;
        return data as Subscription[];
    },

    async updateSubscriptionStatus(id: string, status: string) {
        const { data, error } = await supabase
            .from('subscriptions')
            .update({ status })
            .eq('id', id);
        if (error) throw error;
        return data;
    },

    // Users & Wallet
    async getUsers() {
        try {
            const { data, error } = await supabase.from('users').select('*').order('full_name');
            if (error) throw error;
            return data as User[];
        } catch (error) {
            console.error("Error in getUsers:", error);
            return [];
        }
    },

    async updateWalletBalance(userId: string, newBalance: number) {
        const { data, error } = await supabase
            .from('users')
            .update({ wallet_balance: newBalance })
            .eq('id', userId);
        if (error) throw error;
        return data;
    },

    // Bookings
    async getBookings() {
        const { data, error } = await supabase
            .from('bookings')
            .select('*, users(*), pickup_station:stations!pickup_station_id(*), dropoff_station:stations!dropoff_station_id(*)')
            .order('created_at', { ascending: false });
        if (error) throw error;
        return data as Booking[];
    },

    // Trips (Schedules)
    async getTrips() {
        const { data, error } = await supabase
            .from('schedules')
            .select('*, routes(*, universities(*))')
            .order('trip_date', { ascending: false });
        if (error) {
            console.error("getTrips error:", error);
            throw error;
        }
        return data as Trip[];
    },

    async addTrip(trip: Partial<Trip>) {
        const { data, error } = await supabase.from('schedules').insert([trip]).select();
        if (error) throw error;
        return data[0] as Trip;
    },

    async updateTrip(id: string, trip: Partial<Trip>) {
        const { data, error } = await supabase.from('schedules').update(trip).eq('id', id).select();
        if (error) throw error;
        return data[0] as Trip;
    },

    async deleteTrip(id: string) {
        const { error } = await supabase.from('schedules').delete().eq('id', id);
        if (error) throw error;
    },

    // CMS
    async getFAQs() {
        try {
            // Mapping to possible FAQ table names
            const { data, error } = await supabase.from('help_center_faqs').select('*').order('id');
            if (error) {
                // Try fallback table name if first one fails
                const { data: fallbackData, error: fallbackError } = await supabase.from('cms_faqs').select('*').order('id');
                if (fallbackError) return [];
                return fallbackData as FAQ[];
            }
            return data as FAQ[];
        } catch (error) {
            return [];
        }
    }
};
