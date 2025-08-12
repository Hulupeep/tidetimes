# 🚀 Quick Start Guide: Get Current Wave Height at M2 Buoy

This step-by-step tutorial will get you from zero to getting real Irish marine data in just a few minutes!

## Step 1: Install Python

Make sure you have Python 3.7 or newer installed on your computer.

**Check your Python version:**
```bash
python --version
```

If you need to install Python, visit: https://python.org/downloads/

## Step 2: Install the Irish Marine Data Toolkit

Open your terminal or command prompt and run:

```bash
pip install irish-marine-data
```

You should see output like this:
```
Collecting irish-marine-data
  Downloading irish-marine-data-1.0.0.tar.gz (15 kB)
Installing collected packages: irish-marine-data
Successfully installed irish-marine-data-1.0.0
```

## Step 3: Create Your First Script

Create a new file called `my_first_marine_data.py` and paste this code:

```python
from irish_marine_data import MarineData

# Create a connection to the Irish marine data
client = MarineData()

print("🌊 Getting current wave conditions at M2 buoy...")

# Get the latest wave data from the M2 buoy (last 1 hour)
wave_data = client.get_wave_data('M2', hours=1)

# Show the results
if wave_data.has_data():
    latest = wave_data.latest
    print(f"📊 Current wave height: {latest.wave_height}m")
    print(f"📊 Wave period: {latest.wave_period}s")  
    print(f"📊 Wave direction: {latest.wave_direction}°")
    print(f"📊 Recorded at: {latest.timestamp}")
else:
    print("❌ No recent data available")

print("\n✅ Done! You just got real Irish marine data!")
```

## Step 4: Run Your Script

In your terminal, navigate to where you saved the file and run:

```bash
python my_first_marine_data.py
```

**Expected Output:**
```
🌊 Getting current wave conditions at M2 buoy...
📊 Current wave height: 1.8m
📊 Wave period: 6.2s
📊 Wave direction: 245°
📊 Recorded at: 2024-08-12 14:30:00
✅ Done! You just got real Irish marine data!
```

## Step 5: Try More Locations

Let's expand your script to check multiple locations. Replace your code with:

```python
from irish_marine_data import MarineData

client = MarineData()

# List of Irish marine buoys to check
buoys = ['M2', 'M3', 'M4', 'M5']

print("🌊 IRISH WAVE CONDITIONS REPORT")
print("=" * 40)

for buoy in buoys:
    print(f"\n📍 Checking buoy {buoy}...")
    
    try:
        wave_data = client.get_wave_data(buoy, hours=1)
        
        if wave_data.has_data():
            latest = wave_data.latest
            height = latest.wave_height
            
            # Add some interpretation
            if height < 1.0:
                condition = "🌊 Calm seas"
            elif height < 2.0:
                condition = "🌊 Moderate waves"
            elif height < 3.0:
                condition = "⚠️ Rough seas"
            else:
                condition = "🚨 Very rough seas"
            
            print(f"   Wave Height: {height}m - {condition}")
            print(f"   Last Updated: {latest.timestamp.strftime('%H:%M')}")
        else:
            print("   ❌ No data available")
            
    except Exception as e:
        print(f"   ❌ Error: {str(e)}")

print("\n" + "=" * 40)
print("✅ Report complete!")
```

**Expected Output:**
```
🌊 IRISH WAVE CONDITIONS REPORT
========================================

📍 Checking buoy M2...
   Wave Height: 1.8m - 🌊 Moderate waves
   Last Updated: 14:30

📍 Checking buoy M3...
   Wave Height: 0.7m - 🌊 Calm seas
   Last Updated: 14:25

📍 Checking buoy M4...
   Wave Height: 2.3m - ⚠️ Rough seas
   Last Updated: 14:35

📍 Checking buoy M5...
   ❌ No data available

========================================
✅ Report complete!
```

## Step 6: Add Weather Information

Let's make it even more useful by adding weather data:

```python
from irish_marine_data import MarineData
from datetime import datetime

client = MarineData()

location = 'dublin_bay'  # You can also try 'galway_bay', 'cork_harbour'

print(f"🌊 COMPLETE MARINE CONDITIONS FOR {location.upper()}")
print("=" * 50)

# Get different types of data
try:
    # Wave conditions
    waves = client.get_wave_data(location, hours=1)
    if waves.has_data():
        w = waves.latest
        print(f"🌊 Wave Height: {w.wave_height}m")
        print(f"🌊 Wave Period: {w.wave_period}s")
    
    # Weather conditions  
    weather = client.get_weather_data(location, hours=1)
    if weather.has_data():
        wt = weather.latest
        print(f"💨 Wind Speed: {wt.wind_speed} knots")
        print(f"💨 Wind Direction: {wt.wind_direction}°")
        print(f"🌡️ Air Temperature: {wt.air_temp}°C")
    
    # Water temperature
    temp = client.get_temperature_data(location, hours=1)  
    if temp.has_data():
        t = temp.latest
        print(f"🌊 Water Temperature: {t.temperature}°C")
    
    # Today's tide times
    tides = client.get_tide_times(location, days=1)
    if tides.has_data():
        today_tides = tides.today
        print(f"🌊 High Tide: {today_tides.high_tide_time}")
        print(f"🌊 Low Tide: {today_tides.low_tide_time}")

except Exception as e:
    print(f"❌ Error getting data: {str(e)}")

print("\n" + "=" * 50)
print("✅ Marine conditions report complete!")
print("📱 Save this script and run it anytime for updates!")
```

## Step 7: What's Next?

Now that you've got the basics working, here are some ideas for what to do next:

### 🎯 For Beginners:
- Modify the locations to check areas near you
- Change the time periods (try `days=7` instead of `hours=1`)
- Add your own condition interpretations (good for fishing, sailing, etc.)

### 🚀 For Advanced Users:
- Set up automated reports that email you daily conditions
- Create graphs of historical data trends
- Build a web dashboard with real-time updates
- Set up SMS alerts for dangerous conditions

### 📚 Learn More:
- Check out [EXAMPLES.md](EXAMPLES.md) for 10+ real-world use cases
- Read [API_GUIDE.md](API_GUIDE.md) for all available data and parameters
- See the main [README.md](../README.md) for more advanced examples

## 🔧 Troubleshooting Your First Script

### "ModuleNotFoundError: No module named 'irish_marine_data'"
**Solution:** Make sure you installed the package:
```bash
pip install irish-marine-data
```

### "No data available" or "Connection timeout"
**Possible causes:**
- The buoy might be temporarily offline
- Network connection issues
- Try a different location code

**Try this debug version:**
```python
from irish_marine_data import MarineData

client = MarineData(debug=True)  # Enable debug mode
wave_data = client.get_wave_data('M2', hours=1)
```

### "AttributeError" or similar errors
**Solution:** Make sure you're using the latest version:
```bash
pip install --upgrade irish-marine-data
```

### Still having issues?
- Check that Python 3.7+ is installed: `python --version`
- Try running the script from a different directory
- Make sure your internet connection is working
- Check the GitHub issues page for known problems

## 🎉 Success!

Congratulations! You now know how to:
- ✅ Install the Irish Marine Data toolkit
- ✅ Get real-time wave data from Irish buoys
- ✅ Check multiple locations at once
- ✅ Combine different types of marine data
- ✅ Handle errors gracefully

You're ready to start building your own marine data applications!

---

**What to do now:**
1. Experiment with different locations and time periods
2. Check out the [EXAMPLES.md](EXAMPLES.md) file for more inspiration  
3. Join our community discussions on GitHub
4. Share your creations with the #IrishMarineData hashtag!

*Happy coding and safe sailing! 🌊*