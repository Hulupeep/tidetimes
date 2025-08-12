#!/usr/bin/env node
/**
 * Simple Database Viewer - Shows what's in your Supabase database
 * Run with: node examples/view-database.js
 */

const { createClient } = require('@supabase/supabase-js');

// Local Supabase connection (no auth needed for local)
const supabaseUrl = 'http://localhost:54321';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';

const supabase = createClient(supabaseUrl, supabaseKey);

async function viewDatabase() {
    console.log('🔍 Checking your Supabase database...\n');
    
    try {
        // Get today's tide data
        const today = new Date().toISOString().split('T')[0];
        const { data: todayTide, error: todayError } = await supabase
            .from('tide_times')
            .select('*')
            .eq('date', today)
            .single();
            
        if (todayTide) {
            console.log("📅 Today's Tide Times for Galway:");
            console.log('─'.repeat(50));
            console.log(`Date: ${todayTide.date}`);
            console.log(`Morning High: ${todayTide.morning_high_time} (${todayTide.morning_high_height}m)`);
            console.log(`Morning Low: ${todayTide.morning_low_time} (${todayTide.morning_low_height}m)`);
            console.log(`Afternoon High: ${todayTide.afternoon_high_time} (${todayTide.afternoon_high_height}m)`);
            console.log(`Afternoon Low: ${todayTide.afternoon_low_time} (${todayTide.afternoon_low_height}m)`);
            console.log();
        }
        
        // Get next 7 days high tides
        const { data: weekTides, error: weekError } = await supabase
            .from('tide_times')
            .select('date, morning_high_time, morning_high_height, afternoon_high_time, afternoon_high_height')
            .gte('date', today)
            .lte('date', new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString().split('T')[0])
            .order('date');
            
        if (weekTides && weekTides.length > 0) {
            console.log('🌊 Next 7 Days High Tides:');
            console.log('─'.repeat(50));
            weekTides.forEach(tide => {
                console.log(`${tide.date}: ${tide.morning_high_time} (${tide.morning_high_height}m) | ${tide.afternoon_high_time} (${tide.afternoon_high_height}m)`);
            });
            console.log();
        }
        
        // Get statistics
        const { data: stats, error: statsError } = await supabase
            .from('tide_times')
            .select('morning_high_height, afternoon_high_height');
            
        if (stats && stats.length > 0) {
            const allHeights = [];
            stats.forEach(s => {
                if (s.morning_high_height) allHeights.push(parseFloat(s.morning_high_height));
                if (s.afternoon_high_height) allHeights.push(parseFloat(s.afternoon_high_height));
            });
            
            const avgHeight = (allHeights.reduce((a, b) => a + b, 0) / allHeights.length).toFixed(2);
            const maxHeight = Math.max(...allHeights).toFixed(2);
            const minHeight = Math.min(...allHeights).toFixed(2);
            
            console.log('📊 Database Statistics:');
            console.log('─'.repeat(50));
            console.log(`Total records: ${stats.length} days`);
            console.log(`Average high tide: ${avgHeight}m`);
            console.log(`Highest tide: ${maxHeight}m`);
            console.log(`Lowest high tide: ${minHeight}m`);
            console.log();
        }
        
        // Swimming recommendation
        const currentHour = new Date().getHours();
        if (todayTide) {
            const morningHighHour = parseInt(todayTide.morning_high_time.split(':')[0]);
            const afternoonHighHour = parseInt(todayTide.afternoon_high_time.split(':')[0]);
            
            let recommendation = '';
            if (Math.abs(currentHour - morningHighHour) <= 2 || Math.abs(currentHour - afternoonHighHour) <= 2) {
                recommendation = '🏊 Good time for swimming! (within 2 hours of high tide)';
            } else {
                const nextHigh = currentHour < afternoonHighHour ? 
                    `${todayTide.afternoon_high_time}` : 
                    'tomorrow morning';
                recommendation = `⏰ Next good swimming time: around ${nextHigh}`;
            }
            
            console.log('💡 Swimming Recommendation:');
            console.log('─'.repeat(50));
            console.log(recommendation);
            console.log();
        }
        
        console.log('✅ Database connection successful!');
        console.log('\n🎯 Try these queries in Supabase Studio:');
        console.log('   SELECT * FROM tide_times WHERE morning_high_height > 4.5;');
        console.log('   SELECT date, morning_high_time FROM tide_times ORDER BY morning_high_height DESC LIMIT 10;');
        
    } catch (error) {
        console.error('❌ Error connecting to database:', error.message);
        console.log('\n💡 Make sure Supabase is running:');
        console.log('   npx supabase status');
        console.log('   npx supabase start');
    }
}

// Run the viewer
viewDatabase();