const puppeteer = require('puppeteer');
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

class TideTimesScraper {
    constructor() {
        // Use local Supabase instance or remote
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

    async scrapeGalwayTideTimes() {
        let browser;
        try {
            console.log('Starting Galway tide times scraper...');
            
            browser = await puppeteer.launch({
                headless: 'new',
                args: [
                    '--no-sandbox',
                    '--disable-setuid-sandbox',
                    '--disable-http2',
                    '--disable-blink-features=AutomationControlled',
                    '--disable-web-security',
                    '--disable-features=IsolateOrigins,site-per-process'
                ]
            });
            
            const page = await browser.newPage();
            await page.setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36');
            
            console.log('Navigating to Galway tide times page...');
            
            // Try multiple navigation strategies
            try {
                await page.goto('https://theportofgalway.ie/galway-tide-times/', {
                    waitUntil: 'domcontentloaded',
                    timeout: 60000
                });
            } catch (navError) {
                console.log('First navigation attempt failed, trying alternative approach...');
                await page.goto('https://theportofgalway.ie/galway-tide-times/', {
                    waitUntil: 'load',
                    timeout: 60000
                });
            }

            // Wait for the table to load and make hidden rows visible
            console.log('Waiting for tide data to load...');
            await page.waitForTimeout(3000);

            // Show all hidden rows by removing display:none styling
            await page.evaluate(() => {
                const hiddenRows = document.querySelectorAll('tr[style*="display: none"]');
                hiddenRows.forEach(row => {
                    row.style.display = '';
                });
            });

            // Extract tide data from all rows
            const tideData = await page.evaluate(() => {
                const rows = document.querySelectorAll('tr[class*="row-"]');
                const data = [];

                rows.forEach(row => {
                    const dateCell = row.querySelector('.column-1, td[data-th="Date"]');
                    const morningHighCell = row.querySelector('.column-2, td[data-th="Morning high water"]');
                    const afternoonHighCell = row.querySelector('.column-3, td[data-th="Afternoon high water"]');
                    const morningLowCell = row.querySelector('.column-4, td[data-th="Morning low water"]');
                    const afternoonLowCell = row.querySelector('.column-5, td[data-th="Afternoon low water"]');

                    if (dateCell && dateCell.textContent.trim()) {
                        const dateText = dateCell.textContent.replace(/&nbsp;/g, ' ').trim();
                        
                        const extractTimeAndHeight = (cellContent) => {
                            if (!cellContent) return { time: null, height: null };
                            
                            const timeMatch = cellContent.match(/🕐(\d{2}:\d{2})/);
                            const heightMatch = cellContent.match(/([\d.]+)m/);
                            
                            return {
                                time: timeMatch ? timeMatch[1] : null,
                                height: heightMatch ? parseFloat(heightMatch[1]) : null
                            };
                        };

                        const morningHigh = extractTimeAndHeight(morningHighCell?.innerHTML || '');
                        const afternoonHigh = extractTimeAndHeight(afternoonHighCell?.innerHTML || '');
                        const morningLow = extractTimeAndHeight(morningLowCell?.innerHTML || '');
                        const afternoonLow = extractTimeAndHeight(afternoonLowCell?.innerHTML || '');

                        data.push({
                            date: dateText,
                            morningHigh,
                            afternoonHigh,
                            morningLow,
                            afternoonLow
                        });
                    }
                });

                return data;
            });

            console.log(`Extracted ${tideData.length} tide records`);
            return tideData;

        } catch (error) {
            console.error('Error scraping tide data:', error);
            throw error;
        } finally {
            if (browser) {
                await browser.close();
            }
        }
    }

    parseDate(dateString) {
        // Handle various date formats like "29 December 2025" or "29&nbsp;December&nbsp;2025"
        const cleanDate = dateString.replace(/&nbsp;/g, ' ').trim();
        const date = new Date(cleanDate);
        
        if (isNaN(date.getTime())) {
            console.warn(`Could not parse date: ${dateString}`);
            return null;
        }
        
        return date.toISOString().split('T')[0]; // Return YYYY-MM-DD format
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

        console.log(`Preparing to insert ${records.length} valid records`);

        // Insert records in batches to avoid hitting limits
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
                    console.error(`Batch ${Math.floor(i / batchSize) + 1} error:`, error);
                    errorCount += batch.length;
                } else {
                    insertedCount += batch.length;
                    console.log(`Batch ${Math.floor(i / batchSize) + 1} completed: ${batch.length} records`);
                }
            } catch (error) {
                console.error(`Batch ${Math.floor(i / batchSize) + 1} exception:`, error);
                errorCount += batch.length;
            }
        }

        console.log(`Storage complete: ${insertedCount} inserted, ${errorCount} errors`);
        return { insertedCount, errorCount };
    }

    async run() {
        try {
            console.log('=== Tide Times Scraper Starting ===');
            
            const tideData = await this.scrapeGalwayTideTimes();
            
            if (tideData.length === 0) {
                console.log('No tide data found');
                return;
            }

            const result = await this.storeTideData(tideData);
            
            console.log('=== Scraping Complete ===');
            console.log(`Total records processed: ${tideData.length}`);
            console.log(`Successfully stored: ${result.insertedCount}`);
            console.log(`Errors: ${result.errorCount}`);
            
        } catch (error) {
            console.error('Scraper failed:', error);
            process.exit(1);
        }
    }
}

// Run the scraper if this file is executed directly
if (require.main === module) {
    const scraper = new TideTimesScraper();
    scraper.run();
}

module.exports = TideTimesScraper;