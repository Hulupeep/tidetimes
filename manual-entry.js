const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

// Initialize Supabase client
const supabaseUrl = process.env.SUPABASE_URL || 'http://127.0.0.1:54421';
const supabaseKey = process.env.SUPABASE_SERVICE_KEY || process.env.SUPABASE_ANON_KEY;

if (!supabaseKey) {
    throw new Error('Please set SUPABASE_SERVICE_KEY or SUPABASE_ANON_KEY in your .env file');
}

const supabase = createClient(supabaseUrl, supabaseKey);

// Location data
const LOCATION = {
    country: process.env.LOCATION_COUNTRY || 'Ireland',
    city: process.env.LOCATION_CITY || 'Galway',
    post_code: process.env.LOCATION_POST_CODE || 'H91'
};

async function addTideEntry(dateStr, morningHigh, afternoonHigh, morningLow, afternoonLow) {
    // Parse date
    const date = new Date(dateStr);
    const formattedDate = date.toISOString().split('T')[0];
    
    const record = {
        country: LOCATION.country,
        city: LOCATION.city,
        post_code: LOCATION.post_code,
        date: formattedDate,
        morning_high_time: morningHigh.time || null,
        morning_high_height: morningHigh.height || null,
        afternoon_high_time: afternoonHigh.time || null,
        afternoon_high_height: afternoonHigh.height || null,
        morning_low_time: morningLow.time || null,
        morning_low_height: morningLow.height || null,
        afternoon_low_time: afternoonLow.time || null,
        afternoon_low_height: afternoonLow.height || null
    };
    
    const { data, error } = await supabase
        .from('tide_times')
        .upsert(record, { 
            onConflict: 'country,city,post_code,date',
            ignoreDuplicates: false 
        });
    
    if (error) {
        console.error(`❌ Error for ${dateStr}:`, error.message);
        return false;
    }
    
    console.log(`✅ Added tide data for ${dateStr}`);
    return true;
}

// Example usage based on your data format:
// Date format: "29 December 2025"
// Time format: "11:54"
// Height format: 4.23 (in meters)

async function main() {
    console.log('=== Manual Tide Data Entry ===');
    console.log(`Location: ${LOCATION.city}, ${LOCATION.country} (${LOCATION.post_code})`);
    console.log('');
    
    // Example entry based on your sample:
    await addTideEntry(
        '29 December 2025',
        { time: '11:54', height: 4.23 },  // Morning high
        { time: null, height: null },      // Afternoon high (empty in sample)
        { time: '05:39', height: 1.84 },  // Morning low
        { time: '18:06', height: 1.54 }   // Afternoon low
    );
    
    // Add more entries here as needed
    // You can copy the HTML from the website and manually extract the data
    
    // Example of multiple entries:
    const entries = [
        {
            date: '30 December 2025',
            morningHigh: { time: '12:30', height: 4.15 },
            afternoonHigh: { time: null, height: null },
            morningLow: { time: '06:15', height: 1.90 },
            afternoonLow: { time: '18:45', height: 1.60 }
        },
        // Add more entries...
    ];
    
    for (const entry of entries) {
        await addTideEntry(
            entry.date,
            entry.morningHigh,
            entry.afternoonHigh,
            entry.morningLow,
            entry.afternoonLow
        );
    }
    
    console.log('\n=== Entry Complete ===');
}

// Instructions for use:
console.log(`
To use this script:
1. Copy the tide data from the website
2. Format it as JavaScript objects in the 'entries' array
3. Run: node manual-entry.js

Data format:
{
    date: 'DD Month YYYY',
    morningHigh: { time: 'HH:MM', height: X.XX },
    afternoonHigh: { time: 'HH:MM', height: X.XX },
    morningLow: { time: 'HH:MM', height: X.XX },
    afternoonLow: { time: 'HH:MM', height: X.XX }
}

Use null for empty values.
`);

if (require.main === module) {
    main().catch(console.error);
}