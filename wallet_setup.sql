CREATE TABLE IF NOT EXISTS public.users (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    full_name text,
    phone text UNIQUE,
    email text,
    role text DEFAULT 'user' CHECK (role IN ('user', 'driver', 'office', 'supervisor')),
    wallet_balance numeric DEFAULT 0,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Ensure existing users have a role if they don't
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='role') THEN
        ALTER TABLE public.users ADD COLUMN role text DEFAULT 'user' CHECK (role IN ('user', 'driver', 'office', 'supervisor'));
    END IF;
END $$;

-- Create wallet_transactions table
CREATE TABLE IF NOT EXISTS public.wallet_transactions (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid REFERENCES public.users(id) ON DELETE CASCADE,
    amount numeric NOT NULL,
    type text CHECK (type IN ('debit', 'credit')) NOT NULL,
    reason text,
    balance_after numeric NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Create recharge_requests table (final synchronized structure)
CREATE TABLE IF NOT EXISTS public.recharge_requests (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid REFERENCES public.users(id) ON DELETE CASCADE,
    amount numeric NOT NULL,
    phone_number text,
    proof_image_url text,
    method text, -- (Vodafone Cash, InstaPay)
    type text DEFAULT 'topup' CHECK (type IN ('topup', 'withdraw')),
    status text DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Update wallet_transactions for pending states
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='wallet_transactions' AND column_name='status') THEN
        ALTER TABLE public.wallet_transactions ADD COLUMN status text DEFAULT 'success' CHECK (status IN ('pending', 'success', 'rejected'));
    END IF;
    
    ALTER TABLE public.wallet_transactions ALTER COLUMN balance_after DROP NOT NULL;
END $$;

-- Disable RLS for development
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.recharge_requests DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallet_transactions DISABLE ROW LEVEL SECURITY;

-- Atomic function to approve recharge/withdraw requests with Smart Recovery
CREATE OR REPLACE FUNCTION approve_recharge_request(req_id uuid)
RETURNS void AS $$
DECLARE
    req_amount numeric;
    req_user_id uuid;
    req_phone text;
    req_type text;
    found_user_id uuid;
    current_bal numeric;
    new_bal numeric;
BEGIN
    -- 1. Get request details
    SELECT amount, user_id, phone_number, type INTO req_amount, req_user_id, req_phone, req_type
    FROM recharge_requests 
    WHERE id = req_id AND status = 'pending'
    FOR UPDATE;

    IF req_amount IS NULL THEN
        RAISE EXCEPTION 'الطلب غير موجود أو تمت معالجته بالفعل';
    END IF;

    -- 2. SMART RECOVERY: Try to find user by ID first, then by Phone
    SELECT id INTO found_user_id FROM users WHERE id = req_user_id;
    
    IF found_user_id IS NULL THEN
        -- Try finding by phone if ID failed
        SELECT id INTO found_user_id FROM users WHERE phone = req_phone OR phone = ('0' || req_phone) LIMIT 1;
    END IF;

    IF found_user_id IS NULL THEN
        RAISE EXCEPTION 'فشل العثور على المستخدم (الـ ID والرقم غير مسجلين في جدول users)';
    END IF;

    -- 3. Get current balance
    SELECT wallet_balance INTO current_bal FROM users WHERE id = found_user_id FOR UPDATE;

    -- 4. Calculate new balance
    IF req_type = 'topup' THEN
        new_bal := COALESCE(current_bal, 0) + req_amount;
    ELSE
        IF COALESCE(current_bal, 0) < req_amount THEN
            RAISE EXCEPTION 'رصيد المستخدم غير كافٍ لسحب هذا المبلغ';
        END IF;
        new_bal := COALESCE(current_bal, 0) - req_amount;
    END IF;

    -- 5. PERFORM UPDATES
    UPDATE users SET wallet_balance = new_bal WHERE id = found_user_id;
    UPDATE recharge_requests SET status = 'approved', user_id = found_user_id WHERE id = req_id;

    -- 6. Log transaction
    INSERT INTO wallet_transactions (user_id, amount, type, reason, balance_after, status)
    VALUES (
        found_user_id, 
        req_amount, 
        CASE WHEN req_type = 'topup' THEN 'credit' ELSE 'debit' END,
        'موافقة ذكية - طلب رقم ' || left(req_id::text, 5),
        new_bal,
        'success'
    );
END;
$$ LANGUAGE plpgsql;

