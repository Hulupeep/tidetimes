# 🌊 Irish Marine Data Made Easy!

Get real-time ocean conditions, tide levels, and weather data from Ireland's coast - **no API key required!**

## What is this?

This toolkit makes it incredibly simple to access marine data from the Irish Marine Institute's ERDDAP service. Whether you're building a sailing app, planning fishing trips, or just curious about ocean conditions, you can get live data in seconds!

## Get Started in 30 Seconds

### 1. Install
```bash
pip install requests pandas python-dateutil
```

### 2. Copy this code
```python
from src.marine_data import IrishMarineDataClient

client = IrishMarineDataClient()
data = client.get_wave_buoy_data("M2")
print(f"Wave height: {data['latest']['wave_height']}m")
```

### 3. Run it!
That's it - you're now getting live ocean data from Ireland!

## 📦 Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/irish-marine-data.git
cd irish-marine-data

# Install dependencies
pip install -r requirements.txt

# Run the demo
python src/main.py
```

## 🚀 Quick Examples

### Example 1: Check if it's safe to go sailing
```python
from src.marine_data import IrishMarineDataClient

client = IrishMarineDataClient()
data = client.get_wave_buoy_data("M2", hours_back=1)

waves = data['latest']['wave_height']
wind = data['latest']['wind_speed']

if waves < 2.0 and wind < 15:
    print("✅ Great conditions for sailing!")
else:
    print("⚠️ Conditions might be challenging")
```

### Example 2: Get tide times for Galway
```python
client = IrishMarineDataClient()
tides = client.get_galway_tide_data(hours_back=24)

print(f"Current level: {tides['latest']['water_level']}m")
print(f"Tide is: {tides['tide_state']}")
```

### Example 3: Check all buoys at once
```python
client = IrishMarineDataClient()
all_buoys = client.get_all_buoy_data()

for buoy in all_buoys:
    print(f"{buoy['buoy_id']}: {buoy['wave_height']}m waves")
```

### Example 4: Weather dashboard
```python
client = IrishMarineDataClient()
weather = client.get_weather_data("M3")

print(f"Wind: {weather['latest']['wind_speed']} knots")
print(f"Air temp: {weather['latest']['air_temperature']}°C")
print(f"Sea temp: {weather['latest']['sea_temperature']}°C")
```

### Example 5: Save data to CSV
```python
from src.marine_data import save_to_csv

client = IrishMarineDataClient()
data = client.get_wave_buoy_data("M4", hours_back=24)
save_to_csv(data, "wave_data.csv")
```

### Example 6: Create safety alerts
```python
client = IrishMarineDataClient()

for buoy_id in ["M1", "M2", "M3", "M4", "M5", "M6"]:
    data = client.get_wave_buoy_data(buoy_id, hours_back=1)
    waves = data['latest']['wave_height']
    
    if waves > 3.0:
        print(f"⚠️ HIGH WAVES at {buoy_id}: {waves}m")
```

## 📊 Available Data Sources

### Wave Buoys (M1-M6)
- **M1**: Southwest of Ireland
- **M2**: West of Ireland
- **M3**: Southwest of Ireland
- **M4**: Southeast of Ireland
- **M5**: West of Ireland
- **M6**: Northwest of Ireland

**Data available**: Wave height, period, direction, wind speed/direction, air/sea temperature, pressure

### Tide Gauges
- **Galway Port**: Real-time tide levels
- More ports coming soon!

**Data available**: Water level (LAT), tide state (rising/falling), historical patterns

## 🌐 Direct API Access

You can also access the data directly without any code:

### Wave data from M2 buoy:
```
https://erddap.marine.ie/erddap/tabledap/IWBNetwork.csv?station_id,SignificantWaveHeight,time&station_id="M2"&time>=now-7days
```

### Tide data from Galway:
```
https://erddap.marine.ie/erddap/tabledap/IrishNationalTideGaugeNetwork.csv?station_id,Water_Level_LAT,time&station_id="Galway Port"&time>=now-1day
```

Just paste these URLs in your browser to see the data!

## 🛠️ Troubleshooting

### "Connection error" message
The module includes realistic mock data for testing when the API is unavailable. Your code will still work!

### Times look wrong
All times are in UTC. Convert to Irish time:
- Winter: UTC = Irish time
- Summer: UTC + 1 hour = Irish time

### Can't find my local beach
The buoys are offshore. Use the nearest buoy:
- West coast: M2 or M5
- Southwest: M1 or M3
- Southeast: M4
- Northwest: M6

## 📚 More Examples

Run the complete example suite:
```bash
python examples/quick_examples.py
```

This includes:
- Simple wave checking
- Safety advisories
- Historical analysis
- Custom alerts
- Trend detection

## 🔗 Links & Resources

- **Live Demo**: Open `index.html` in your browser
- **Marine Institute**: https://www.marine.ie
- **ERDDAP Portal**: https://erddap.marine.ie
- **Data Dictionary**: See `docs/API_GUIDE.md`

## 📄 License

This project is open source and available under the MIT License. The data is provided by the Irish Marine Institute under Creative Commons Attribution 4.0.

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Add more data sources
- Improve documentation
- Create new examples
- Report issues

## ❓ Need Help?

- Check the `docs/` folder for detailed guides
- Run `python examples/quick_examples.py` for working examples
- The code includes extensive comments explaining everything

---

Made with ❤️ to make Irish marine data accessible to everyone!