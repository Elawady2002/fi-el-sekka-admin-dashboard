-- Create users table if not exists (or update it)
CREATE TABLE IF NOT EXISTS public.users (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    full_name text,
    phone text UNIQUE,
    balance numeric DEFAULT 0,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Create wallet_recharge_requests table
CREATE TABLE IF NOT EXISTS public.wallet_recharge_requests (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid REFERENCES public.users(id) ON DELETE CASCADE,
    amount numeric NOT NULL,
    screenshot_url text,
    status text DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Disable RLS for development
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallet_recharge_requests DISABLE ROW LEVEL SECURITY;
