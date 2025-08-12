#!/usr/bin/env python3
"""
Irish Marine Data - Main Demo Application
Shows how to fetch and display real-time marine data from Irish waters.
"""

from marine_data import IrishMarineDataClient, save_to_csv, format_for_display, convert_timestamp
from datetime import datetime
import time
import os

def print_header():
    """Print a nice header for the application."""
    print("\n" + "="*60)
    print("🌊 IRISH MARINE DATA SYSTEM 🌊".center(60))
    print("Real-time data from buoys and tide gauges".center(60))
    print("="*60)

def print_section(title: str):
    """Print a section header."""
    print(f"\n{'─'*60}")
    print(f"  {title}")
    print(f"{'─'*60}")

def demo_single_buoy():
    """Demonstrate getting data from a single buoy."""
    print_section("📍 SINGLE BUOY DATA - M2 (West of Ireland)")
    
    client = IrishMarineDataClient()
    data = client.get_wave_buoy_data("M2", hours_back=6)
    
    print(format_for_display(data))
    
    # Show some historical data
    if 'historical' in data and len(data['historical']) > 0:
        print("\n📊 Recent Wave Heights (last 6 hours):")
        for reading in data['historical'][-6:]:
            time_str = convert_timestamp(reading['time'])
            wave_height = reading.get('wave_height', 0)
            print(f"  {time_str}: {wave_height:.1f}m")
    
    # Save to CSV
    if not os.path.exists('data'):
        os.makedirs('data')
    save_to_csv(data, 'data/m2_buoy_data.csv')
    
    return data

def demo_all_buoys():
    """Get current conditions from all M-series buoys."""
    print_section("🌊 ALL IRISH WEATHER BUOYS (M1-M6)")
    
    client = IrishMarineDataClient()
    all_buoys = client.get_all_buoy_data(hours_back=1)
    
    print("\n📊 Current Conditions Summary:")
    print(f"{'Buoy':<6} {'Location':<25} {'Waves':<8} {'Wind':<8} {'Sea Temp':<8}")
    print("─" * 65)
    
    for buoy in all_buoys:
        print(f"{buoy['buoy_id']:<6} {buoy['location']:<25} "
              f"{buoy['wave_height']:.1f}m     "
              f"{buoy['wind_speed']:.1f}kts   "
              f"{buoy['sea_temp']:.1f}°C")
    
    # Find the roughest seas
    if all_buoys:
        roughest = max(all_buoys, key=lambda x: x['wave_height'])
        print(f"\n⚠️  Highest waves: {roughest['buoy_id']} with {roughest['wave_height']:.1f}m")
        
        calmest = min(all_buoys, key=lambda x: x['wave_height'])
        print(f"✅ Calmest waters: {calmest['buoy_id']} with {calmest['wave_height']:.1f}m")
    
    return all_buoys

def demo_galway_tides():
    """Get tide data from Galway Harbor."""
    print_section("📈 GALWAY HARBOR TIDES")
    
    client = IrishMarineDataClient()
    tides = client.get_galway_tide_data(hours_back=24)
    
    print(format_for_display(tides))
    
    # Show tide trend
    if 'historical' in tides and len(tides['historical']) > 1:
        print("\n📊 Tide Levels (last 6 readings):")
        for reading in tides['historical'][-6:]:
            time_str = convert_timestamp(reading['time'])
            level = reading.get('level', 0)
            print(f"  {time_str}: {level:.2f}m")
        
        # Calculate high/low from last 24 hours
        levels = [r['level'] for r in tides['historical']]
        high_tide = max(levels)
        low_tide = min(levels)
        print(f"\n📈 24hr High: {high_tide:.2f}m")
        print(f"📉 24hr Low:  {low_tide:.2f}m")
        print(f"📊 Range:     {high_tide - low_tide:.2f}m")
    
    # Save tide data
    if not os.path.exists('data'):
        os.makedirs('data')
    save_to_csv(tides, 'data/galway_tides.csv')
    
    return tides

def demo_weather_monitoring():
    """Demonstrate weather monitoring from marine stations."""
    print_section("💨 WEATHER CONDITIONS")
    
    client = IrishMarineDataClient()
    
    # Get weather from multiple locations
    stations = ["M1", "M3", "M5"]
    
    print("\n📊 Current Weather Summary:")
    print(f"{'Station':<8} {'Wind':<12} {'Direction':<10} {'Temp':<8} {'Pressure':<10}")
    print("─" * 55)
    
    for station in stations:
        data = client.get_weather_data(station, hours_back=1)
        if 'latest' in data:
            latest = data['latest']
            print(f"{station:<8} "
                  f"{latest.get('wind_speed', 0):.1f} kts     "
                  f"{latest.get('wind_direction', 0):.0f}°       "
                  f"{latest.get('air_temperature', 0):.1f}°C    "
                  f"{latest.get('pressure', 0):.1f} mbar")
        time.sleep(0.5)  # Be nice to the server
    
    return True

def check_marine_safety():
    """Check if conditions are safe for marine activities."""
    print_section("🛡️ MARINE SAFETY CHECK")
    
    client = IrishMarineDataClient()
    
    # Define safety thresholds
    SAFE_WAVE_HEIGHT = 2.0  # meters
    SAFE_WIND_SPEED = 15.0  # knots
    
    print("\n🔍 Checking conditions for marine activities...")
    
    # Check a few key locations
    locations = ["M2", "M4", "M5"]
    safe_count = 0
    
    for buoy_id in locations:
        data = client.get_wave_buoy_data(buoy_id, hours_back=1)
        
        if 'latest' in data:
            latest = data['latest']
            wave_height = latest.get('wave_height', 0)
            wind_speed = latest.get('wind_speed', 0)
            
            is_safe = wave_height <= SAFE_WAVE_HEIGHT and wind_speed <= SAFE_WIND_SPEED
            
            status = "✅ SAFE" if is_safe else "⚠️  CAUTION"
            if is_safe:
                safe_count += 1
            
            print(f"\n{buoy_id} - {data.get('location', 'Unknown')}:")
            print(f"  Status: {status}")
            print(f"  Waves: {wave_height:.1f}m {'✅' if wave_height <= SAFE_WAVE_HEIGHT else '⚠️'}")
            print(f"  Wind: {wind_speed:.1f} kts {'✅' if wind_speed <= SAFE_WIND_SPEED else '⚠️'}")
        
        time.sleep(0.5)
    
    print(f"\n📊 Summary: {safe_count}/{len(locations)} locations have safe conditions")
    
    if safe_count == len(locations):
        print("✅ Overall: Good conditions for marine activities!")
    elif safe_count > 0:
        print("⚠️  Overall: Mixed conditions - check specific locations")
    else:
        print("🚫 Overall: Challenging conditions - exercise caution")

def main():
    """Run the complete marine data demonstration."""
    
    print_header()
    
    print("\n📡 Starting Irish Marine Data System...")
    print("This demo will fetch real-time data from:")
    print("  • Weather buoys (M1-M6)")
    print("  • Galway Harbor tide gauge")
    print("  • Marine weather stations")
    
    input("\nPress Enter to start fetching data...")
    
    try:
        # Run all demonstrations
        print("\n" + "="*60)
        print("STARTING DATA COLLECTION".center(60))
        print("="*60)
        
        # 1. Single buoy demo
        print("\n[1/5] Fetching single buoy data...")
        m2_data = demo_single_buoy()
        time.sleep(1)
        
        # 2. All buoys summary
        print("\n[2/5] Fetching all buoys...")
        all_buoys = demo_all_buoys()
        time.sleep(1)
        
        # 3. Tide data
        print("\n[3/5] Fetching tide data...")
        tide_data = demo_galway_tides()
        time.sleep(1)
        
        # 4. Weather monitoring
        print("\n[4/5] Fetching weather data...")
        demo_weather_monitoring()
        time.sleep(1)
        
        # 5. Safety check
        print("\n[5/5] Running safety analysis...")
        check_marine_safety()
        
        # Final summary
        print("\n" + "="*60)
        print("✅ DATA COLLECTION COMPLETE".center(60))
        print("="*60)
        
        print("\n📁 Data saved to:")
        print("  • data/m2_buoy_data.csv")
        print("  • data/galway_tides.csv")
        
        print("\n📊 Quick Stats:")
        if all_buoys:
            avg_wave = sum(b['wave_height'] for b in all_buoys) / len(all_buoys)
            avg_wind = sum(b['wind_speed'] for b in all_buoys) / len(all_buoys)
            avg_temp = sum(b['sea_temp'] for b in all_buoys) / len(all_buoys)
            
            print(f"  • Average wave height: {avg_wave:.1f}m")
            print(f"  • Average wind speed: {avg_wind:.1f} knots")
            print(f"  • Average sea temperature: {avg_temp:.1f}°C")
        
        print("\n🎉 Thank you for using Irish Marine Data System!")
        print("💡 Tip: You can import marine_data.py in your own projects!")
        
    except KeyboardInterrupt:
        print("\n\n⚠️ Demo interrupted by user")
    except Exception as e:
        print(f"\n\n❌ Error: {str(e)}")
        print("Please check your internet connection and try again.")

if __name__ == "__main__":
    main()