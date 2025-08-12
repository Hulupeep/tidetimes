const TideTimesScraper = require('./scraper');

async function testScraper() {
    console.log('=== Testing Tide Times Scraper ===');
    
    const scraper = new TideTimesScraper();
    
    try {
        // Test scraping (without storing to database)
        console.log('Testing tide data extraction...');
        
        const tideData = await scraper.scrapeGalwayTideTimes();
        
        console.log(`\nScraping Results:`);
        console.log(`- Total records found: ${tideData.length}`);
        
        if (tideData.length > 0) {
            console.log(`\nSample record:`);
            console.log(JSON.stringify(tideData[0], null, 2));
            
            console.log(`\nFirst 5 dates found:`);
            tideData.slice(0, 5).forEach((record, index) => {
                console.log(`${index + 1}. ${record.date}`);
            });
        }
        
        console.log('\n=== Test Complete ===');
        
    } catch (error) {
        console.error('Test failed:', error);
        process.exit(1);
    }
}

if (require.main === module) {
    testScraper();
}