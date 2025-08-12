const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');
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

function parseDate(dateString) {
    // Handle format like "29&nbsp;December&nbsp;2025"
    const cleanDate = dateString.replace(/&nbsp;/g, ' ').trim();
    const date = new Date(cleanDate);
    
    if (isNaN(date.getTime())) {
        console.warn(`Could not parse date: ${dateString}`);
        return null;
    }
    
    return date.toISOString().split('T')[0];
}

function parseTimeAndHeight(htmlContent) {
    if (!htmlContent || htmlContent.trim() === '') {
        return { time: null, height: null };
    }
    
    // Extract time (format: 🕐11:54)
    const timeMatch = htmlContent.match(/🕐(\d{2}:\d{2})/);
    // Extract height (format: 4.23m)
    const heightMatch = htmlContent.match(/([\d.]+)m/);
    
    return {
        time: timeMatch ? timeMatch[1] : null,
        height: heightMatch ? parseFloat(heightMatch[1]) : null
    };
}

async function importTideData() {
    try {
        console.log('Reading tide data from tide.txt...');
        const content = fs.readFileSync('/home/xanacan/Dropbox/code/tidetimes/tide.txt', 'utf8');
        
        // Use regex to extract all table rows
        const rowRegex = /<tr class="row-\d+"[^>]*>(.*?)<\/tr>/gs;
        const rows = [...content.matchAll(rowRegex)];
        
        console.log(`Found ${rows.length} tide data rows`);
        
        const records = [];
        
        for (const match of rows) {
            const rowContent = match[1];
            
            // Extract data from each cell
            const dateMatch = rowContent.match(/<td[^>]*data-th="Date"[^>]*>(.*?)<\/td>/);
            const morningHighMatch = rowContent.match(/<td[^>]*data-th="Morning high water"[^>]*>(.*?)<\/td>/);
            const afternoonHighMatch = rowContent.match(/<td[^>]*data-th="Afternoon high water"[^>]*>(.*?)<\/td>/);
            const morningLowMatch = rowContent.match(/<td[^>]*data-th="Morning low water"[^>]*>(.*?)<\/td>/);
            const afternoonLowMatch = rowContent.match(/<td[^>]*data-th="Afternoon low water"[^>]*>(.*?)<\/td>/);
            
            if (dateMatch) {
                const date = parseDate(dateMatch[1]);
                if (date) {
                    const morningHigh = parseTimeAndHeight(morningHighMatch ? morningHighMatch[1] : '');
                    const afternoonHigh = parseTimeAndHeight(afternoonHighMatch ? afternoonHighMatch[1] : '');
                    const morningLow = parseTimeAndHeight(morningLowMatch ? morningLowMatch[1] : '');
                    const afternoonLow = parseTimeAndHeight(afternoonLowMatch ? afternoonLowMatch[1] : '');
                    
                    records.push({
                        country: LOCATION.country,
                        city: LOCATION.city,
                        post_code: LOCATION.post_code,
                        date: date,
                        morning_high_time: morningHigh.time,
                        morning_high_height: morningHigh.height,
                        afternoon_high_time: afternoonHigh.time,
                        afternoon_high_height: afternoonHigh.height,
                        morning_low_time: morningLow.time,
                        morning_low_height: morningLow.height,
                        afternoon_low_time: afternoonLow.time,
                        afternoon_low_height: afternoonLow.height
                    });
                }
            }
        }
        
        console.log(`Parsed ${records.length} valid records`);
        
        // Show sample data
        if (records.length > 0) {
            console.log('\nSample record:');
            console.log(JSON.stringify(records[0], null, 2));
        }
        
        // Insert in batches
        const batchSize = 50;
        let successCount = 0;
        let errorCount = 0;
        
        for (let i = 0; i < records.length; i += batchSize) {
            const batch = records.slice(i, i + batchSize);
            
            const { data, error } = await supabase
                .from('tide_times')
                .upsert(batch, { 
                    onConflict: 'country,city,post_code,date',
                    ignoreDuplicates: false 
                });
            
            if (error) {
                console.error(`Batch ${Math.floor(i / batchSize) + 1} error:`, error.message);
                errorCount += batch.length;
            } else {
                successCount += batch.length;
                console.log(`✅ Batch ${Math.floor(i / batchSize) + 1}: Imported ${batch.length} records`);
            }
        }
        
        console.log('\n=== Import Complete ===');
        console.log(`✅ Successfully imported: ${successCount} records`);
        console.log(`❌ Errors: ${errorCount}`);
        
    } catch (error) {
        console.error('Import failed:', error);
    }
}

// Run the import
importTideData();