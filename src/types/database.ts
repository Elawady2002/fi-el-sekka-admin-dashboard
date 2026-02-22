export type UserType = 'student' | 'driver' | 'admin';
export type TripStatus = 'scheduled' | 'in_progress' | 'completed' | 'cancelled';
export type SubscriptionStatus = 'active' | 'expired' | 'pending';
export type BookingStatus = 'pending' | 'confirmed' | 'cancelled' | 'completed';
export type PaymentStatus = 'unpaid' | 'paid' | 'refunded';
export type StationType = 'pickup' | 'dropoff' | 'both';

export interface City {
    id: string;
    name_ar: string;
    name_en: string;
    is_active: boolean;
}

export interface Station {
    id: string;
    city_id: string;
    name_ar: string;
    name_en: string;
    location: any;
    station_type: StationType;
    is_active: boolean;
    destination_ids?: string[]; // Array of reachable station IDs
    cities?: City; // For joins
}

export interface University {
    id: string;
    name_ar: string;
    name_en: string;
    is_active: boolean;
}

export interface Route {
    id: string;
    university_id: string;
    route_name_ar: string;
    route_name_en: string;
    route_code: string;
    stations_order: string[];
    is_active: boolean;
    universities?: University; // For joins
}

export interface Trip {
    id: string;
    route_id: string | null;
    driver_id: string | null;
    trip_date: string;
    departure_time: string | null;
    return_time: string | null;
    available_seats: number;
    seat_price: number;
    minibus_price: number;
    car_type: string | null;
    is_women_only: boolean;
    trip_direction: string | null;
    trip_type: 'city_to_city' | 'university';
    status: TripStatus;
    created_at: string;
    routes?: Route; // For joins
    stops_data?: Array<{
        station_id: string;
        arrival_time: string | null;
        seat_price: number;
        minibus_price: number;
    }>;
}

export interface User {
    id: string;
    email: string;
    phone: string;
    full_name: string;
    student_id: string | null;
    university_id: string | null;
    user_type: UserType;
    is_verified: boolean;
    created_at: string;
    wallet_balance: number;
    avatar_url: string | null;
}

export interface Subscription {
    id: string;
    user_id: string;
    plan_type: string;
    status: SubscriptionStatus;
    total_price: number;
    payment_proof_url: string | null;
    transfer_number: string | null;
    start_date: string;
    end_date: string;
    trip_type: string;
    is_installment: boolean;
    created_at: string;
    users?: User; // For joins
}

export interface Booking {
    id: string;
    user_id: string;
    schedule_id: string | null;
    subscription_id: string | null;
    booking_date: string;
    trip_type: string;
    pickup_station_id: string | null;
    dropoff_station_id: string | null;
    status: BookingStatus;
    payment_status: PaymentStatus;
    total_price: number;
    created_at: string;
    users?: User; // For joins
    pickup_station?: Station;
    dropoff_station?: Station;
}

export interface FAQ {
    id: number;
    question: string;
    answer: string;
    category: string;
}
