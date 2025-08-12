const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

class TideDataImporter {
    constructor() {
        const supabaseUrl = process.env.SUPABASE_URL || 'http://127.0.0.1:54421';
        const supabaseKey = process.env.SUPABASE_SERVICE_KEY || process.env.SUPABASE_ANON_KEY;
        
        if (!supabaseKey) {
            throw new Error('Please set SUPABASE_SERVICE_KEY or SUPABASE_ANON_KEY in your .env file');
        }
        
        this.supabase = createClient(supabaseUrl, supabaseKey);
        
        this.locationData = {
            country: process.env.LOCATION_COUNTRY || 'Ireland',
            city: process.env.LOCATION_CITY || 'Galway',
            postCode: process.env.LOCATION_POST_CODE || 'H91'
        };
    }

    parseDate(dateString) {
        // Handle format like "29 December 2025"
        const cleanDate = dateString.replace(/&nbsp;/g, ' ').trim();
        const date = new Date(cleanDate);
        
        if (isNaN(date.getTime())) {
            console.warn(`Could not parse date: ${dateString}`);
            return null;
        }
        
        return date.toISOString().split('T')[0];
    }

    parseTimeAndHeight(text) {
        if (!text || text.trim() === '') {
            return { time: null, height: null };
        }
        
        // Extract time (format: 🕐11:54)
        const timeMatch = text.match(/🕐(\d{2}:\d{2})/);
        // Extract height (format: 4.23m)
        const heightMatch = text.match(/([\d.]+)m/);
        
        return {
            time: timeMatch ? timeMatch[1] : null,
            height: heightMatch ? parseFloat(heightMatch[1]) : null
        };
    }

    parseTideRow(htmlString) {
        // Parse a single row of tide data
        // Example: <tr class="row-364" style="display: none;"><td class="column-1" data-th="Date">29&nbsp;December&nbsp;2025</td><td class="column-2" data-th="Morning high water">🕐11:54<br> 4.23m</td><td class="column-3" data-th="Afternoon high water"></td><td class="column-4" data-th="Morning low water">🕐05:39<br> 1.84m</td><td class="column-5" data-th="Afternoon low water">🕐18:06<br> 1.54m</td></tr>
        
        const cheerio = require('cheerio');
        const $ = cheerio.load(htmlString);
        
        const date = $('td.column-1').text();
        console.log('Raw date text:', date);
        const morningHighText = $('td.column-2').html() || '';
        const afternoonHighText = $('td.column-3').html() || '';
        const morningLowText = $('td.column-4').html() || '';
        const afternoonLowText = $('td.column-5').html() || '';
        
        return {
            date: this.parseDate(date),
            morningHigh: this.parseTimeAndHeight(morningHighText),
            afternoonHigh: this.parseTimeAndHeight(afternoonHighText),
            morningLow: this.parseTimeAndHeight(morningLowText),
            afternoonLow: this.parseTimeAndHeight(afternoonLowText)
        };
    }

    async importSingleRow(htmlRow) {
        const tideData = this.parseTideRow(htmlRow);
        
        console.log('Parsed tide data:', JSON.stringify(tideData, null, 2));
        
        if (!tideData.date) {
            console.error('Could not parse date from row');
            return false;
        }

        const record = {
            country: this.locationData.country,
            city: this.locationData.city,
            post_code: this.locationData.postCode,
            date: tideData.date,
            morning_high_time: tideData.morningHigh.time,
            morning_high_height: tideData.morningHigh.height,
            afternoon_high_time: tideData.afternoonHigh.time,
            afternoon_high_height: tideData.afternoonHigh.height,
            morning_low_time: tideData.morningLow.time,
            morning_low_height: tideData.morningLow.height,
            afternoon_low_time: tideData.afternoonLow.time,
            afternoon_low_height: tideData.afternoonLow.height
        };

        const { data, error } = await this.supabase
            .from('tide_times')
            .upsert(record, { 
                onConflict: 'country,city,post_code,date',
                ignoreDuplicates: false 
            });

        if (error) {
            console.error('Error inserting record:', error);
            return false;
        }

        console.log(`✅ Imported tide data for ${tideData.date}`);
        return true;
    }

    async importFromFile(filename) {
        const fs = require('fs');
        
        try {
            const content = fs.readFileSync(filename, 'utf8');
            
            // Split by lines and find all <tr> elements
            const rows = content.match(/<tr[^>]*>.*?<\/tr>/gs) || [];
            
            console.log(`Found ${rows.length} rows to import`);
            
            let successCount = 0;
            let errorCount = 0;
            
            for (const row of rows) {
                if (row.includes('data-th="Date"') || row.includes('class="column-1"')) {
                    const success = await this.importSingleRow(row);
                    if (success) {
                        successCount++;
                    } else {
                        errorCount++;
                    }
                }
            }
            
            console.log(`\n=== Import Complete ===`);
            console.log(`✅ Successfully imported: ${successCount} records`);
            console.log(`❌ Errors: ${errorCount}`);
            
        } catch (error) {
            console.error('Error reading file:', error);
        }
    }

    async testImport() {
        // Test with the sample row provided
        const sampleRow = '<tr class="row-364" style="display: none;"><td class="column-1" data-th="Date">29&nbsp;December&nbsp;2025</td><td class="column-2" data-th="Morning high water">🕐11:54<br> 4.23m</td><td class="column-3" data-th="Afternoon high water"></td><td class="column-4" data-th="Morning low water">🕐05:39<br> 1.84m</td><td class="column-5" data-th="Afternoon low water">🕐18:06<br> 1.54m</td></tr>';
        
        console.log('Testing with sample row...');
        const result = await this.importSingleRow(sampleRow);
        console.log('Test result:', result ? '✅ Success' : '❌ Failed');
    }
}

// Command line usage
if (require.main === module) {
    const importer = new TideDataImporter();
    
    const args = process.argv.slice(2);
    
    if (args[0] === 'test') {
        importer.testImport();
    } else if (args[0] === 'file' && args[1]) {
        importer.importFromFile(args[1]);
    } else if (args[0] === 'row' && args[1]) {
        importer.importSingleRow(args[1]);
    } else {
        console.log('Usage:');
        console.log('  node import-tide-data.js test              - Test with sample data');
        console.log('  node import-tide-data.js file <filename>   - Import from HTML file');
        console.log('  node import-tide-data.js row "<html row>"  - Import single row');
    }
}

module.exports = TideDataImporter;