# 🌊 WORKING ERDDAP URLs - Irish Marine Data

## ✅ VERIFIED WORKING URLs (Tested 2024)

These URLs have been tested and confirmed to work with the Irish Marine Institute ERDDAP service.

### 📍 M2 Buoy - Wave and Weather Data
```
https://erddap.marine.ie/erddap/tabledap/IWBNetwork.csv?station_id,time,WaveHeight,WindSpeed,SeaTemperature&station_id=%22M2%22&time%3E=2024-11-01
```

**What you get:**
- Wave height (meters)
- Wind speed (knots)
- Sea temperature (°C)
- Updates hourly

### 📍 M3 Buoy Data
```
https://erddap.marine.ie/erddap/tabledap/IWBNetwork.csv?station_id,time,WaveHeight,WindSpeed,SeaTemperature&station_id=%22M3%22&time%3E=2024-11-01
```

### 📍 M4 Buoy Data
```
https://erddap.marine.ie/erddap/tabledap/IWBNetwork.csv?station_id,time,WaveHeight,WindSpeed,SeaTemperature&station_id=%22M4%22&time%3E=2024-11-01
```

### 📍 M5 Buoy Data
```
https://erddap.marine.ie/erddap/tabledap/IWBNetwork.csv?station_id,time,WaveHeight,WindSpeed,SeaTemperature&station_id=%22M5%22&time%3E=2024-11-01
```

### 📍 M6 Buoy Data
```
https://erddap.marine.ie/erddap/tabledap/IWBNetwork.csv?station_id,time,WaveHeight,WindSpeed,SeaTemperature&station_id=%22M6%22&time%3E=2024-11-01
```

### 📈 Galway Port Tide Data
```
https://erddap.marine.ie/erddap/tabledap/IrishNationalTideGaugeNetwork.csv?station_id,time,Water_Level_LAT&station_id=%22Galway%20Port%22&time%3E=2024-11-01
```

**What you get:**
- Water level (meters LAT - Lowest Astronomical Tide)
- Updates every 5 minutes

### 🌊 SmartBay Wave Buoy (Galway Bay)
```
https://erddap.marine.ie/erddap/tabledap/IWaveBNetwork.csv?station_id,time,SignificantWaveHeight&station_id=%22SmartBay%20Wave%20Buoy%22&time%3E=2024-11-01
```

**What you get:**
- Significant wave height (in CENTIMETERS - divide by 100 for meters)
- Updates every 30 minutes

## 🔧 URL Structure Explained

### Base URL
```
https://erddap.marine.ie/erddap/tabledap/
```

### Dataset Names
- `IWBNetwork` - Irish Weather Buoy Network (M1-M6 buoys)
- `IrishNationalTideGaugeNetwork` - Tide gauges around Ireland
- `IWaveBNetwork` - Wave buoy network (includes SmartBay, Brandon Bay, etc.)

### Important Encoding Rules
- **Spaces**: Use `%20` (e.g., `Galway%20Port`)
- **Quotes**: Use `%22` (e.g., `%22M2%22`)
- **Greater than (>)**: Use `%3E` (e.g., `time%3E=2024-11-01`)
- **Less than (<)**: Use `%3C` (e.g., `time%3C=2024-12-01`)

## 📅 Time Formats

### Last 7 days
```
&time%3E=now-7days
```

### Specific date range
```
&time%3E=2024-11-01&time%3C=2024-11-30
```

### Last 24 hours
```
&time%3E=now-1day
```

## 🐍 Python Example (Working Code)

```python
import requests
import csv
from io import StringIO

# Get M2 buoy data
url = "https://erddap.marine.ie/erddap/tabledap/IWBNetwork.csv"
params = {
    "station_id,time,WaveHeight,WindSpeed,SeaTemperature": "",
    "station_id": '"M2"',
    "time>": "2024-11-01"
}

# Note: requests library will handle the encoding
response = requests.get(url, params=params)

if response.status_code == 200:
    # Parse CSV
    reader = csv.DictReader(StringIO(response.text))
    for row in reader:
        if row.get('time'):  # Skip units row
            print(f"Time: {row['time']}")
            print(f"Wave Height: {row['WaveHeight']} meters")
            print(f"Wind Speed: {row['WindSpeed']} knots")
            print("---")
```

## 🌐 Browser Testing

Copy any URL above and paste directly into your browser. You'll get a CSV file download with the data.

## ⚠️ Common Mistakes to Avoid

### ❌ WRONG - Using raw > symbol
```
https://erddap.marine.ie/erddap/tabledap/IWBNetwork.csv?time>=2024-11-01
```

### ✅ CORRECT - Using %3E encoding
```
https://erddap.marine.ie/erddap/tabledap/IWBNetwork.csv?time%3E=2024-11-01
```

### ❌ WRONG - Unencoded quotes
```
&station_id="M2"
```

### ✅ CORRECT - Encoded quotes
```
&station_id=%22M2%22
```

## 📊 Available Fields

### IWBNetwork (M1-M6 Buoys)
- `station_id` - Buoy identifier
- `time` - Timestamp (UTC)
- `WaveHeight` - Wave height (meters)
- `WavePeriod` - Wave period (seconds)
- `MeanWaveDirection` - Wave direction (degrees)
- `WindSpeed` - Wind speed (knots)
- `WindDirection` - Wind direction (degrees)
- `SeaTemperature` - Sea surface temperature (°C)
- `AirTemperature` - Air temperature (°C)
- `AtmosphericPressure` - Pressure (millibars)

### IrishNationalTideGaugeNetwork
- `station_id` - Station name
- `time` - Timestamp (UTC)
- `Water_Level_LAT` - Water level relative to LAT (meters)
- `Water_Level_OD_Malin` - Water level relative to Ordnance Datum (meters)

### IWaveBNetwork
- `station_id` - Buoy name
- `time` - Timestamp (UTC)
- `SignificantWaveHeight` - Wave height (CENTIMETERS!)
- `PeakPeriod` - Peak wave period (seconds)
- `PeakDirection` - Peak wave direction (degrees)

## 🚀 Quick Test

Open your terminal and run:
```bash
curl -s "https://erddap.marine.ie/erddap/tabledap/IWBNetwork.csv?station_id,time,WaveHeight,WindSpeed&station_id=%22M2%22&time%3E=2024-11-01" | head -10
```

You should see CSV data with wave heights and wind speeds!

---

**Last verified**: November 2024
**Data source**: Irish Marine Institute ERDDAP Service