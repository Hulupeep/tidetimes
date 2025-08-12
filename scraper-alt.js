const axios = require('axios');
const cheerio = require('cheerio');
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

class AlternativeTideScraper {
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

    async fetchTideData() {
        try {
            console.log('Fetching tide data from Galway port website...');
            
            const response = await axios.get('https://theportofgalway.ie/galway-tide-times/', {
                headers: {
                    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
                    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
                    'Accept-Language': 'en-US,en;q=0.5',
                    'Accept-Encoding': 'gzip, deflate, br',
                    'Connection': 'keep-alive',
                    'Upgrade-Insecure-Requests': '1'
                }
            });

            const $ = cheerio.load(response.data);
            
            // Look for the tide table
            const tideData = [];
            
            // Try to find rows with tide data
            $('tr[class*="row-"]').each((index, element) => {
                const row = $(element);
                const dateCell = row.find('td[data-th="Date"], .column-1').text().trim();
                
                if (dateCell) {
                    const morningHighText = row.find('td[data-th="Morning high water"], .column-2').text();
                    const afternoonHighText = row.find('td[data-th="Afternoon high water"], .column-3').text();
                    const morningLowText = row.find('td[data-th="Morning low water"], .column-4').text();
                    const afternoonLowText = row.find('td[data-th="Afternoon low water"], .column-5').text();
                    
                    const extractTimeAndHeight = (text) => {
                        const timeMatch = text.match(/(\d{2}:\d{2})/);
                        const heightMatch = text.match(/([\d.]+)m/);
                        
                        return {
                            time: timeMatch ? timeMatch[1] : null,
                            height: heightMatch ? parseFloat(heightMatch[1]) : null
                        };
                    };
                    
                    tideData.push({
                        date: dateCell.replace(/\s+/g, ' '),
                        morningHigh: extractTimeAndHeight(morningHighText),
                        afternoonHigh: extractTimeAndHeight(afternoonHighText),
                        morningLow: extractTimeAndHeight(morningLowText),
                        afternoonLow: extractTimeAndHeight(afternoonLowText)
                    });
                }
            });

            // If no data found, let's see what's in the page
            if (tideData.length === 0) {
                console.log('No tide data found in standard format. Checking page content...');
                
                // Look for any table
                const tables = $('table');
                console.log(`Found ${tables.length} tables on the page`);
                
                // Check for any rows
                const allRows = $('tr');
                console.log(`Found ${allRows.length} total rows`);
                
                // Sample some content
                console.log('\nFirst few rows:');
                allRows.slice(0, 5).each((i, el) => {
                    console.log(`Row ${i}: ${$(el).text().substring(0, 100)}...`);
                });
            }

            return tideData;

        } catch (error) {
            console.error('Error fetching tide data:', error.message);
            throw error;
        }
    }

    parseDate(dateString) {
        const cleanDate = dateString.replace(/&nbsp;/g, ' ').trim();
        const date = new Date(cleanDate);
        
        if (isNaN(date.getTime())) {
            console.warn(`Could not parse date: ${dateString}`);
            return null;
        }
        
        return date.toISOString().split('T')[0];
    }

    async storeTideData(tideData) {
        console.log('Storing tide data to Supabase...');
        
        const records = tideData
            .map(record => {
                const parsedDate = this.parseDate(record.date);
                if (!parsedDate) return null;

                return {
                    country: this.locationData.country,
                    city: this.locationData.city,
                    post_code: this.locationData.postCode,
                    date: parsedDate,
                    morning_high_time: record.morningHigh.time,
                    morning_high_height: record.morningHigh.height,
                    afternoon_high_time: record.afternoonHigh.time,
                    afternoon_high_height: record.afternoonHigh.height,
                    morning_low_time: record.morningLow.time,
                    morning_low_height: record.morningLow.height,
                    afternoon_low_time: record.afternoonLow.time,
                    afternoon_low_height: record.afternoonLow.height
                };
            })
            .filter(record => record !== null);

        const batchSize = 100;
        let insertedCount = 0;
        let errorCount = 0;

        for (let i = 0; i < records.length; i += batchSize) {
            const batch = records.slice(i, i + batchSize);
            
            try {
                const { data, error } = await this.supabase
                    .from('tide_times')
                    .upsert(batch, { 
                        onConflict: 'country,city,post_code,date',
                        ignoreDuplicates: false 
                    });

                if (error) {
                    console.error(`Batch error:`, error);
                    errorCount += batch.length;
                } else {
                    insertedCount += batch.length;
                }
            } catch (error) {
                console.error(`Batch exception:`, error);
                errorCount += batch.length;
            }
        }

        return { insertedCount, errorCount };
    }

    async run() {
        try {
            console.log('=== Alternative Tide Scraper Starting ===');
            
            const tideData = await this.fetchTideData();
            
            console.log(`Found ${tideData.length} tide records`);
            
            if (tideData.length > 0) {
                console.log('\nSample data:');
                console.log(JSON.stringify(tideData[0], null, 2));
                
                const result = await this.storeTideData(tideData);
                console.log(`\nStored: ${result.insertedCount} records`);
                console.log(`Errors: ${result.errorCount}`);
            }
            
        } catch (error) {
            console.error('Scraper failed:', error);
            process.exit(1);
        }
    }
}

if (require.main === module) {
    const scraper = new AlternativeTideScraper();
    scraper.run();
}

module.exports = AlternativeTideScraper;