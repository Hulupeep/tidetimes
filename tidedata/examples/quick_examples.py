#!/usr/bin/env python3
"""
Quick Examples for Irish Marine Data
Copy and paste these examples to get started quickly!
"""

import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

from marine_data import IrishMarineDataClient
from datetime import datetime

def example_1_simple_wave_check():
    """Example 1: Check current wave height at a buoy."""
    print("\n" + "="*50)
    print("Example 1: Simple Wave Height Check")
    print("="*50)
    
    # Create client
    client = IrishMarineDataClient()
    
    # Get data from M2 buoy
    data = client.get_wave_buoy_data("M2", hours_back=1)
    
    # Display the result
    if 'latest' in data:
        wave_height = data['latest']['wave_height']
        location = data['location']
        print(f"\n📍 Location: {location}")
        print(f"🌊 Current wave height: {wave_height:.1f} meters")
        
        # Simple interpretation
        if wave_height < 1.5:
            print("✅ Calm conditions - great for small boats!")
        elif wave_height < 3.0:
            print("⚠️ Moderate waves - okay for experienced sailors")
        else:
            print("🚫 Rough seas - stay in port!")

def example_2_check_all_locations():
    """Example 2: Get conditions from all buoys."""
    print("\n" + "="*50)
    print("Example 2: Check All Buoy Locations")
    print("="*50)
    
    client = IrishMarineDataClient()
    
    # Get latest from all buoys
    all_buoys = client.get_all_buoy_data(hours_back=1)
    
    print("\n🌊 Current conditions around Ireland:")
    print("-" * 40)
    
    for buoy in all_buoys:
        status = "🟢" if buoy['wave_height'] < 2.0 else "🟡" if buoy['wave_height'] < 3.0 else "🔴"
        print(f"{status} {buoy['buoy_id']}: {buoy['wave_height']:.1f}m waves, "
              f"{buoy['wind_speed']:.0f}kts wind")

def example_3_tide_tracker():
    """Example 3: Check tide levels in Galway."""
    print("\n" + "="*50)
    print("Example 3: Galway Harbor Tide Tracker")
    print("="*50)
    
    client = IrishMarineDataClient()
    
    # Get tide data
    tides = client.get_galway_tide_data(hours_back=6)
    
    if 'latest' in tides:
        current_level = tides['latest']['water_level']
        tide_state = tides.get('tide_state', 'Unknown')
        
        print(f"\n📍 Galway Harbor")
        print(f"🌊 Current water level: {current_level:.2f}m")
        print(f"📈 Tide is: {tide_state}")
        
        # Find high and low from historical data
        if 'historical' in tides:
            levels = [h['level'] for h in tides['historical']]
            print(f"📊 6-hour range: {min(levels):.2f}m to {max(levels):.2f}m")

def example_4_weather_dashboard():
    """Example 4: Create a simple weather dashboard."""
    print("\n" + "="*50)
    print("Example 4: Marine Weather Dashboard")
    print("="*50)
    
    client = IrishMarineDataClient()
    
    # Check weather at M3 (Southwest)
    weather = client.get_weather_data("M3", hours_back=1)
    
    if 'latest' in weather:
        latest = weather['latest']
        
        print(f"\n🌤️ MARINE WEATHER REPORT - {datetime.now().strftime('%Y-%m-%d %H:%M')}")
        print("-" * 40)
        print(f"📍 Location: {weather.get('location', 'M3 Buoy')}")
        print(f"💨 Wind: {latest['wind_speed']:.1f} knots from {latest['wind_direction']:.0f}°")
        print(f"🌡️ Air temp: {latest['air_temperature']:.1f}°C")
        print(f"🌊 Sea temp: {latest['sea_temperature']:.1f}°C")
        print(f"📊 Pressure: {latest['pressure']:.1f} mbar")
        print(f"🌊 Waves: {latest['wave_height']:.1f}m")

def example_5_safety_advisor():
    """Example 5: Check if it's safe for water activities."""
    print("\n" + "="*50)
    print("Example 5: Marine Safety Advisor")
    print("="*50)
    
    client = IrishMarineDataClient()
    
    # Define what activity you want to do
    activity = "kayaking"  # Change this to sailing, fishing, swimming, etc.
    
    # Check conditions at nearest buoy (M2 for west coast)
    data = client.get_wave_buoy_data("M2", hours_back=1)
    
    if 'latest' in data:
        waves = data['latest']['wave_height']
        wind = data['latest']['wind_speed']
        temp = data['latest']['sea_temperature']
        
        print(f"\n🏄 Activity: {activity.upper()}")
        print(f"📍 Checking conditions at {data['location']}...")
        print("-" * 40)
        
        # Safety scores
        wave_safe = waves < 1.5
        wind_safe = wind < 15
        temp_safe = temp > 10
        
        print(f"🌊 Waves: {waves:.1f}m {'✅' if wave_safe else '⚠️'}")
        print(f"💨 Wind: {wind:.1f}kts {'✅' if wind_safe else '⚠️'}")
        print(f"🌡️ Water: {temp:.1f}°C {'✅' if temp_safe else '⚠️'}")
        
        # Overall recommendation
        if wave_safe and wind_safe:
            print(f"\n✅ Conditions look good for {activity}!")
        elif wave_safe or wind_safe:
            print(f"\n⚠️ Mixed conditions - be careful if {activity}")
        else:
            print(f"\n🚫 Not recommended for {activity} today")

def example_6_historical_analysis():
    """Example 6: Analyze trends over time."""
    print("\n" + "="*50)
    print("Example 6: Historical Trend Analysis")
    print("="*50)
    
    client = IrishMarineDataClient()
    
    # Get 24 hours of data
    data = client.get_wave_buoy_data("M4", hours_back=24)
    
    if 'historical' in data and len(data['historical']) > 0:
        print(f"\n📍 24-hour analysis for {data['location']}")
        print("-" * 40)
        
        # Calculate statistics
        wave_heights = [h['wave_height'] for h in data['historical']]
        wind_speeds = [h['wind_speed'] for h in data['historical']]
        
        print(f"🌊 Wave heights:")
        print(f"   Min: {min(wave_heights):.1f}m")
        print(f"   Max: {max(wave_heights):.1f}m")
        print(f"   Avg: {sum(wave_heights)/len(wave_heights):.1f}m")
        
        print(f"\n💨 Wind speeds:")
        print(f"   Min: {min(wind_speeds):.1f} kts")
        print(f"   Max: {max(wind_speeds):.1f} kts")
        print(f"   Avg: {sum(wind_speeds)/len(wind_speeds):.1f} kts")
        
        # Trend detection
        recent_avg = sum(wave_heights[-6:]) / 6  # Last 6 hours
        earlier_avg = sum(wave_heights[:6]) / 6  # First 6 hours
        
        if recent_avg > earlier_avg * 1.2:
            print("\n📈 Conditions are getting rougher")
        elif recent_avg < earlier_avg * 0.8:
            print("\n📉 Conditions are improving")
        else:
            print("\n➡️ Conditions are stable")

def example_7_custom_alert():
    """Example 7: Create custom alerts for specific conditions."""
    print("\n" + "="*50)
    print("Example 7: Custom Marine Alerts")
    print("="*50)
    
    client = IrishMarineDataClient()
    
    # Define alert thresholds
    WAVE_ALERT = 3.0  # meters
    WIND_ALERT = 25   # knots
    
    print(f"\n🚨 Checking for alerts (waves >{WAVE_ALERT}m, wind >{WIND_ALERT}kts)...")
    print("-" * 40)
    
    alerts_found = False
    
    # Check all buoys
    for buoy_id in ["M1", "M2", "M3", "M4", "M5", "M6"]:
        data = client.get_wave_buoy_data(buoy_id, hours_back=1)
        
        if 'latest' in data:
            waves = data['latest']['wave_height']
            wind = data['latest']['wind_speed']
            
            if waves > WAVE_ALERT or wind > WIND_ALERT:
                alerts_found = True
                print(f"\n⚠️ ALERT at {buoy_id} ({data['location']}):")
                
                if waves > WAVE_ALERT:
                    print(f"   🌊 High waves: {waves:.1f}m")
                if wind > WIND_ALERT:
                    print(f"   💨 Strong wind: {wind:.1f} kts")
    
    if not alerts_found:
        print("\n✅ No alerts - all locations within safe limits")

def main():
    """Run all examples."""
    print("\n" + "="*60)
    print("🌊 IRISH MARINE DATA - QUICK EXAMPLES 🌊".center(60))
    print("="*60)
    
    examples = [
        example_1_simple_wave_check,
        example_2_check_all_locations,
        example_3_tide_tracker,
        example_4_weather_dashboard,
        example_5_safety_advisor,
        example_6_historical_analysis,
        example_7_custom_alert
    ]
    
    for i, example in enumerate(examples, 1):
        try:
            example()
            if i < len(examples):
                input(f"\nPress Enter to continue to Example {i+1}...")
        except Exception as e:
            print(f"\n❌ Example {i} error: {str(e)}")
            print("(This might be due to network issues or API limits)")
    
    print("\n" + "="*60)
    print("✅ ALL EXAMPLES COMPLETE!".center(60))
    print("="*60)
    print("\n💡 Copy any example function to your own code to get started!")
    print("📚 See the documentation for more details.")

if __name__ == "__main__":
    main()