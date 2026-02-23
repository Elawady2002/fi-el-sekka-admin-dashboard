-- 1. Create Boarding Stations Table
CREATE TABLE IF NOT EXISTS public.boarding_stations (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  city_id uuid REFERENCES public.cities(id) ON DELETE CASCADE,
  name_ar text NOT NULL,
  name_en text NOT NULL,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. Create Arrival Stations Table
CREATE TABLE IF NOT EXISTS public.arrival_stations (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  boarding_station_id uuid REFERENCES public.boarding_stations(id) ON DELETE CASCADE,
  name_ar text NOT NULL,
  name_en text NOT NULL,
  price numeric(10,2) NOT NULL DEFAULT 0,
  schedules jsonb NOT NULL DEFAULT '[]'::jsonb,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. Temporarily Disable RLS or Allow All (for Development)
ALTER TABLE public.cities DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.boarding_stations DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.arrival_stations DISABLE ROW LEVEL SECURITY;
