-- Supabase table schema for tide times data
CREATE TABLE IF NOT EXISTS tide_times (
    id SERIAL PRIMARY KEY,
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

-- Create an index on location and date for faster queries
CREATE INDEX IF NOT EXISTS idx_tide_times_location_date 
ON tide_times (country, city, post_code, date);

-- Create an index on date for range queries
CREATE INDEX IF NOT EXISTS idx_tide_times_date 
ON tide_times (date);