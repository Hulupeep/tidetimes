-- Create tide_times table for storing tide data
CREATE TABLE IF NOT EXISTS public.tide_times (
    id BIGSERIAL PRIMARY KEY,
    country VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    post_code VARCHAR(20),
    date DATE NOT NULL,
    morning_high_time TIME,
    morning_high_height DECIMAL(4,2),
    afternoon_high_time TIME,
    afternoon_high_height DECIMAL(4,2),
    morning_low_time TIME,
    morning_low_height DECIMAL(4,2),
    afternoon_low_time TIME,
    afternoon_low_height DECIMAL(4,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(country, city, post_code, date)
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_tide_times_location_date 
ON public.tide_times (country, city, post_code, date);

CREATE INDEX IF NOT EXISTS idx_tide_times_date 
ON public.tide_times (date);

-- Add RLS (Row Level Security) policies if needed
ALTER TABLE public.tide_times ENABLE ROW LEVEL SECURITY;

-- Create a policy that allows all operations for authenticated users
CREATE POLICY "Enable all operations for authenticated users" ON public.tide_times
    FOR ALL USING (true);

-- Create a policy that allows public read access
CREATE POLICY "Enable read access for all users" ON public.tide_times
    FOR SELECT USING (true);