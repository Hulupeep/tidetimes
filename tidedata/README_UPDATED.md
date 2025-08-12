# 🌊 Irish Marine Data Made Easy! - WORKING VERSION

Get real-time ocean conditions, tide levels, and weather data from Ireland's coast - **no API key required!**

## ✅ TESTED & VERIFIED WORKING (2024)

This toolkit makes it incredibly simple to access marine data from the Irish Marine Institute's ERDDAP service. All URLs and code examples have been tested and confirmed working.

## Get Started in 30 Seconds

### 1. Install
```bash
pip install requests pandas python-dateutil
```

### 2. Copy this WORKING code
```python
from src.marine_data_v2 import IrishMarineDataClient  # Use V2 for working version!

client = IrishMarineDataClient()
data = client.get_wave_buoy_data("M2")
print(f"Wave height: {data['latest']['wave_height']}m")
print(f"Wind speed: {data['latest']['wind_speed']} knots")
print(f"Sea temp: {data['latest']['sea_temperature']}°C")
```

### 3. Run it!
That's it - you're now getting REAL live ocean data from Ireland!

## 📦 Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/irish-marine-data.git
cd irish-marine-data

# Install dependencies
pip install -r requirements.txt

# Run the WORKING demo
python src/marine_data_v2.py
```

## 🌐 WORKING Direct API URLs (Copy & Paste into Browser!)

These URLs are tested and confirmed working. Just paste them into your browser:

### M2 Buoy - West of Ireland
```
https://erddap.marine.ie/erddap/tabledap/IWBNetwork.csv?station_id,time,WaveHeight,WindSpeed,SeaTemperature&station_id=%22M2%22&time%3E=2024-11-01
```

### Galway Harbor Tides
```
https://erddap.marine.ie/erddap/tabledap/IrishNationalTideGaugeNetwork.csv?station_id,time,Water_Level_LAT&station_id=%22Galway%20Port%22&time%3E=2024-11-01
```

### All Weather Buoys (M1-M6)
- **M1**: `https://erddap.marine.ie/erddap/tabledap/IWBNetwork.csv?station_id,time,WaveHeight&station_id=%22M1%22&time%3E=2024-11-01`
- **M2**: `https://erddap.marine.ie/erddap/tabledap/IWBNetwork.csv?station_id,time,WaveHeight&station_id=%22M2%22&time%3E=2024-11-01`
- **M3**: `https://erddap.marine.ie/erddap/tabledap/IWBNetwork.csv?station_id,time,WaveHeight&station_id=%22M3%22&time%3E=2024-11-01`
- **M4**: `https://erddap.marine.ie/erddap/tabledap/IWBNetwork.csv?station_id,time,WaveHeight&station_id=%22M4%22&time%3E=2024-11-01`
- **M5**: `https://erddap.marine.ie/erddap/tabledap/IWBNetwork.csv?station_id,time,WaveHeight&station_id=%22M5%22&time%3E=2024-11-01`
- **M6**: `https://erddap.marine.ie/erddap/tabledap/IWBNetwork.csv?station_id,time,WaveHeight&station_id=%22M6%22&time%3E=2024-11-01`

## 🚀 Working Examples (All Tested!)

### Example 1: Check if it's safe to go sailing
```python
from src.marine_data_v2 import IrishMarineDataClient

client = IrishMarineDataClient()
data = client.get_wave_buoy_data("M2", hours_back=1)

waves = data['latest']['wave_height']
wind = data['latest']['wind_speed']

print(f"🌊 Waves: {waves}m")
print(f"💨 Wind: {wind} knots")

if waves < 2.0 and wind < 15:
    print("✅ Great conditions for sailing!")
else:
    print("⚠️ Conditions might be challenging")
```

### Example 2: Get current tide in Galway
```python
client = IrishMarineDataClient()
tides = client.get_galway_tide_data(hours_back=24)

print(f"Current level: {tides['latest']['water_level']:.2f}m")
print(f"Tide is: {tides['tide_state']}")

# Output:
# Current level: 3.44m
# Tide is: Falling 📉
```

### Example 3: Check all buoys at once
```python
client = IrishMarineDataClient()
all_buoys = client.get_all_buoy_data()

for buoy in all_buoys:
    print(f"{buoy['buoy_id']}: {buoy['wave_height']}m waves, {buoy['wind_speed']} kts wind")
```

### Example 4: Direct URL Access (No Code!)
```python
import requests

# This URL actually works - try it!
url = "https://erddap.marine.ie/erddap/tabledap/IWBNetwork.csv?station_id,time,WaveHeight&station_id=%22M2%22&time%3E=2024-11-01"
response = requests.get(url)
print(response.text[:200])  # Shows real CSV data!
```

## 📊 What Data You Get

### Wave Buoys (M1-M6)
- **Wave Height**: In meters (real ocean wave height)
- **Wind Speed**: In knots
- **Wind Direction**: In degrees (0-360)
- **Sea Temperature**: In Celsius
- **Air Temperature**: In Celsius
- **Atmospheric Pressure**: In millibars
- **Updates**: Every hour

### Tide Gauges (Galway Port)
- **Water Level LAT**: Meters above Lowest Astronomical Tide
- **Water Level Malin**: Meters above Ordnance Datum
- **Updates**: Every 5 minutes
- **Tide State**: Rising 📈 or Falling 📉

## 🔧 Important URL Encoding Rules

The ERDDAP server requires specific encoding:
- **Quotes**: Use `%22` instead of `"`
- **Greater than (>)**: Use `%3E` instead of `>`
- **Spaces**: Use `%20` instead of spaces
- **Example**: `station_id=%22M2%22` not `station_id="M2"`

## 🛠️ Troubleshooting

### Getting 400 Bad Request errors?
You're probably not encoding the URL correctly. Use the exact URLs provided above.

### Want data from last week?
Change the date in the URL from `time%3E=2024-11-01` to your desired date.

### Times look wrong?
All times are in UTC. Ireland is UTC+0 in winter, UTC+1 in summer.

## 📚 Files in This Package

- `src/marine_data_v2.py` - **WORKING** Python client with correct URLs
- `src/marine_data.py` - Original version (has URL encoding issues)
- `docs/WORKING_URLS.md` - Complete list of tested, working URLs
- `examples/quick_examples.py` - 7 ready-to-run examples
- `index.html` - Interactive web interface
- `tests/test_marine_data.py` - Test suite

## 🎯 Quick Test - Verify It Works

Run this in your terminal RIGHT NOW to see it work:
```bash
curl -s "https://erddap.marine.ie/erddap/tabledap/IWBNetwork.csv?station_id,time,WaveHeight&station_id=%22M2%22&time%3E=2024-11-01" | head -5
```

You should see:
```
station_id,time,WaveHeight
,UTC,meters
M2,2024-11-01T00:00:00Z,0.586
M2,2024-11-01T01:00:00Z,0.586
M2,2024-11-01T02:00:00Z,0.703
```

## 🔗 Links & Resources

- **Live Demo**: Open `index.html` in your browser
- **Marine Institute**: https://www.marine.ie
- **ERDDAP Portal**: https://erddap.marine.ie
- **Working URLs**: See `docs/WORKING_URLS.md`

## 📄 License

Open source under MIT License. Data provided by Irish Marine Institute under Creative Commons Attribution 4.0.

## ⭐ Key Differences from Original

1. **URLs Actually Work**: All URLs use proper encoding (%22, %3E, %20)
2. **Real Data**: Successfully fetches actual data from ERDDAP
3. **CSV Parsing**: Correctly parses CSV responses (not JSON)
4. **Field Names**: Uses correct field names (WaveHeight not SignificantWaveHeight)
5. **Fallback**: Still includes mock data when API is down

---

**Last tested and verified**: November 2024
**Status**: ✅ FULLY WORKING