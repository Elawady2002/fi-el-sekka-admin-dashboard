-- Disable Row Level Security (RLS) for bookings-related tables to allow the dashboard to fetch data.
-- Run this in your Supabase SQL Editor if data is not appearing in the dashboard.

ALTER TABLE IF EXISTS public.bookings DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.subscriptions DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.routes DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.universities DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.schedules DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.arrival_stations DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.boarding_stations DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.cities DISABLE ROW LEVEL SECURITY;

-- If you prefer keeping RLS enabled, you can instead add policies to allow service-role or anon-key access:
-- Example (Uncomment to use instead of disabling RLS):
-- CREATE POLICY "Allow public select" ON public.bookings FOR SELECT USING (true);
