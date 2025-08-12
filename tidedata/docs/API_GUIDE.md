# 📖 Irish Marine Data API Guide

Complete reference for all available datasets, parameters, and usage patterns.

## 🌊 Available Datasets

### Marine Institute Ireland Buoys
Real-time data from weather buoys around Irish waters.

| Buoy ID | Location | Available Data | Status |
|---------|----------|----------------|--------|
| `M2` | Halfway Rock (53.47°N, 5.42°W) | Waves, Weather, Temperature | Active |
| `M3` | Blackwater Bank (51.69°N, 6.76°W) | Waves, Weather, Temperature | Active |
| `M4` | Ronans Well (53.07°N, 11.20°W) | Waves, Weather, Temperature | Active |
| `M5` | Little Sole Bank (49.22°N, 9.93°W) | Waves, Weather, Temperature | Active |
| `M6` | Donegal Bay (54.50°N, 8.90°W) | Waves, Weather, Temperature | Active |

### Coastal Weather Stations
Land-based weather monitoring stations along the Irish coast.

| Station ID | Location | Available Data | Status |
|------------|----------|----------------|--------|
| `dublin_bay` | Dublin Bay Area | Weather, Temperature, Tides | Active |
| `galway_bay` | Galway Bay Area | Weather, Temperature, Tides | Active |
| `cork_harbour` | Cork Harbour Area | Weather, Temperature, Tides | Active |
| `donegal_bay` | Donegal Bay Area | Weather, Temperature, Tides | Active |
| `sligo_bay` | Sligo Bay Area | Weather, Temperature | Active |
| `waterford_harbour` | Waterford Harbour | Weather, Temperature, Tides | Active |

### Tide Gauge Network
Real-time tide measurements from the Irish National Tide Gauge Network.

| Gauge ID | Location | Data Type | Update Frequency |
|----------|----------|-----------|------------------|
| `dublin_port` | Dublin Port | Tide levels, predictions | 6 minutes |
| `dun_laoghaire` | Dún Laoghaire | Tide levels, predictions | 6 minutes |
| `howth` | Howth | Tide levels | 6 minutes |
| `arklow` | Arklow | Tide levels | 6 minutes |
| `rosslare` | Rosslare | Tide levels, predictions | 6 minutes |
| `waterford` | Waterford | Tide levels | 6 minutes |
| `cork` | Cork | Tide levels, predictions | 6 minutes |
| `castletownbere` | Castletownbere | Tide levels | 6 minutes |
| `galway` | Galway | Tide levels, predictions | 6 minutes |

## 🔗 URL Structure Explanation

The toolkit builds ERDDAP URLs following this pattern:

```
https://[server]/erddap/tabledap/[dataset].csv?[parameters]&time>=[start]&time<=[end]
```

### Base Servers:
- **Marine Institute**: `https://erddap.marine.ie`
- **Met Éireann**: `https://erddap.met.ie` 
- **Copernicus**: `https://nrt.cmems-du.eu/motu-web/Motu`

### Example URL:
```
https://erddap.marine.ie/erddap/tabledap/IWaveBNetwork.csv?
time,latitude,longitude,sea_surface_wave_significant_height
&time>=2024-08-12T00:00:00Z
&time<=2024-08-12T23:59:59Z
&station="M2"
```

## 🎯 Common Query Patterns

### 1. Latest Data (Last Reading)
```python
# Get the most recent wave data
waves = client.get_wave_data('M2', hours=1)
latest = waves.latest
```

### 2. Time Range Queries
```python
# Last 24 hours
data = client.get_wave_data('M2', hours=24)

# Last 7 days  
data = client.get_wave_data('M2', days=7)

# Specific date range
from datetime import datetime
start = datetime(2024, 8, 1)
end = datetime(2024, 8, 7) 
data = client.get_historical_data('M2', 'wave_height', start, end)
```

### 3. Multiple Parameters
```python
# Get several measurements at once
data = client.get_comprehensive_data('M2', hours=6, include=[
    'wave_height',
    'wave_period', 
    'wind_speed',
    'air_temperature'
])
```

### 4. Batch Downloads
```python
# Download large datasets efficiently
data = client.batch_download(
    location='M2',
    parameters=['wave_height', 'wind_speed'],
    start_date=datetime(2024, 1, 1),
    end_date=datetime(2024, 8, 1),
    chunk_size='7D'  # Download in 7-day chunks
)
```

## 📅 Time Formatting Guide

### Input Formats Accepted:
```python
# Hours/days (most common)
hours=24, days=7, weeks=2

# Python datetime objects
from datetime import datetime
start_date = datetime(2024, 8, 12, 14, 30, 0)

# ISO 8601 strings
start_date = "2024-08-12T14:30:00Z"
start_date = "2024-08-12 14:30:00"

# Relative strings
start_date = "yesterday"
start_date = "last_week" 
start_date = "last_month"
```

### Time Zones:
- All times are in **UTC** by default
- Use `timezone='local'` for Irish local time
- Use `timezone='Europe/Dublin'` for explicit Irish time

```python
# Get data in Irish local time
waves = client.get_wave_data('M2', hours=24, timezone='local')
```

## 📊 Response Format Examples

### Wave Data Response
```python
wave_data = client.get_wave_data('M2', hours=6)

# Access individual readings
for reading in wave_data.data:
    print(f"Time: {reading.timestamp}")
    print(f"Wave Height: {reading.wave_height}m")
    print(f"Wave Period: {reading.wave_period}s") 
    print(f"Wave Direction: {reading.wave_direction}°")
    print(f"Peak Period: {reading.peak_period}s")

# Quick access to latest
latest = wave_data.latest
print(f"Current waves: {latest.wave_height}m")

# Statistical summaries
print(f"Average wave height: {wave_data.average.wave_height}m")
print(f"Maximum wave height: {wave_data.maximum.wave_height}m")
print(f"Minimum wave height: {wave_data.minimum.wave_height}m")
```

### Weather Data Response
```python
weather = client.get_weather_data('dublin_bay', hours=12)

for reading in weather.data:
    print(f"Wind Speed: {reading.wind_speed} knots")
    print(f"Wind Direction: {reading.wind_direction}°")
    print(f"Wind Gusts: {reading.wind_gusts} knots")
    print(f"Air Temperature: {reading.air_temp}°C")
    print(f"Air Pressure: {reading.pressure} hPa")
    print(f"Humidity: {reading.humidity}%")
    print(f"Visibility: {reading.visibility} meters")
```

### Temperature Data Response  
```python
temp = client.get_temperature_data('M2', days=1)

for reading in temp.data:
    print(f"Sea Temperature: {reading.temperature}°C")
    print(f"Air Temperature: {reading.air_temperature}°C")

# Daily averages
daily_avg = temp.daily_averages
for day in daily_avg:
    print(f"{day.date}: {day.avg_temp}°C")
```

### Tide Data Response
```python  
tides = client.get_tide_times('dublin_port', days=3)

# Today's tides
today = tides.today
print(f"High tide: {today.high_tide_time} ({today.high_tide_height}m)")
print(f"Low tide: {today.low_tide_time} ({today.low_tide_height}m)")

# Next few days
for day in tides.forecast:
    print(f"{day.date}:")
    print(f"  High: {day.high_tide_time} ({day.high_tide_height}m)")
    print(f"  Low: {day.low_tide_time} ({day.low_tide_height}m)")

# Current tide level
current = tides.current_level
print(f"Current tide level: {current.height}m ({current.status})")
```

## 🛠️ Advanced Parameters

### Data Quality Filtering
```python
# Only return high-quality data
data = client.get_wave_data('M2', hours=24, quality_flags=['good', 'acceptable'])

# Include quality metadata
data = client.get_wave_data('M2', hours=24, include_quality=True)
for reading in data.data:
    print(f"Wave: {reading.wave_height}m (Quality: {reading.quality_flag})")
```

### Aggregation Options
```python
# Get hourly averages instead of raw data
data = client.get_wave_data('M2', days=7, aggregate='hourly')

# Daily maximums
data = client.get_wave_data('M2', days=30, aggregate='daily', function='max')

# Custom aggregation periods
data = client.get_wave_data('M2', days=14, aggregate='6H')  # 6-hour periods
```

### Output Formats
```python
# Default: Python objects
data = client.get_wave_data('M2', hours=24)

# Pandas DataFrame
df = client.get_wave_data('M2', hours=24, format='dataframe')

# Raw CSV data
csv = client.get_wave_data('M2', hours=24, format='csv')

# JSON format
json_data = client.get_wave_data('M2', hours=24, format='json')
```

### Spatial Filtering
```python
# Get data within a geographic box
data = client.get_regional_data(
    north=54.0, south=51.0,
    east=-5.0, west=-10.0,
    hours=6
)

# Find nearest station to coordinates
nearest = client.find_nearest_station(
    latitude=53.3498, longitude=-6.2603,  # Dublin coordinates
    data_type='wave'
)
```

## 🚨 Error Handling

### Common Error Responses

#### No Data Available
```python
try:
    data = client.get_wave_data('M2', hours=1)
    if not data.has_data():
        print("No recent data available")
except NoDataError as e:
    print(f"No data: {str(e)}")
```

#### Invalid Location
```python
try:
    data = client.get_wave_data('INVALID', hours=1)
except InvalidLocationError as e:
    print(f"Location not found: {str(e)}")
    # Get list of valid locations
    valid_locations = client.list_locations()
    print(f"Valid options: {valid_locations}")
```

#### Rate Limiting
```python
from time import sleep

try:
    data = client.get_wave_data('M2', days=30)
except RateLimitError as e:
    print(f"Rate limited: {str(e)}")
    print(f"Retry after: {e.retry_after} seconds")
    sleep(e.retry_after)
    data = client.get_wave_data('M2', days=30)  # Retry
```

#### Server Errors
```python
try:
    data = client.get_wave_data('M2', hours=1)
except ServerError as e:
    print(f"Server error: {str(e)}")
    print("Trying alternative data source...")
    data = client.get_wave_data('M3', hours=1)  # Try different buoy
```

## 🎛️ Configuration Options

### Client Configuration
```python
from irish_marine_data import MarineData

# Default configuration
client = MarineData()

# Custom configuration  
client = MarineData(
    timeout=30,           # Request timeout in seconds
    retries=3,           # Number of retry attempts
    cache_ttl=300,       # Cache time-to-live in seconds
    user_agent='MyApp/1.0',  # Custom user agent
    debug=True           # Enable debug logging
)

# Use specific ERDDAP servers
client = MarineData(
    servers=[
        'https://erddap.marine.ie',
        'https://erddap.met.ie'
    ]
)
```

### Global Settings
```python
import irish_marine_data

# Set global defaults
irish_marine_data.config.set_defaults(
    timezone='Europe/Dublin',
    quality_flags=['good', 'acceptable'],
    cache_enabled=True,
    request_timeout=30
)
```

## 📋 Complete Method Reference

### Core Data Methods
```python
# Wave data
get_wave_data(location, hours=None, days=None, start_date=None, end_date=None)

# Weather data  
get_weather_data(location, hours=None, days=None, start_date=None, end_date=None)

# Temperature data
get_temperature_data(location, hours=None, days=None, start_date=None, end_date=None)

# Tide information
get_tide_times(location, days=7)
get_tide_levels(location, hours=None, days=None)

# Historical data
get_historical_data(location, parameter, start_date, end_date)

# Comprehensive data (multiple parameters)
get_comprehensive_data(location, hours=None, days=None, include=[])
```

### Utility Methods
```python
# Location information
list_locations(data_type=None)
get_location_info(location)
find_nearest_station(latitude, longitude, data_type=None)

# Data availability
check_data_availability(location, data_type, date_range)
get_data_coverage(location, start_date, end_date)

# Quality control
validate_data(data, strict=False)
get_quality_summary(data)

# Export/import
export_data(data, filename, format='csv')
import_data(filename, format='csv')
```

## 🔍 Data Quality Information

### Quality Flags
| Flag | Meaning | Include in Analysis? |
|------|---------|---------------------|
| `good` | High quality, passed all tests | ✅ Yes |
| `acceptable` | Minor issues, generally usable | ✅ Usually |
| `questionable` | Significant issues, use with caution | ⚠️ Maybe |
| `bad` | Failed quality tests | ❌ No |
| `missing` | No data available | ❌ No |

### Typical Data Ranges
| Parameter | Typical Range | Units | Accuracy |
|-----------|---------------|-------|----------|
| Wave Height | 0.2 - 8.0 | meters | ±0.1m |
| Wave Period | 3 - 20 | seconds | ±0.2s |
| Wind Speed | 0 - 50+ | knots | ±2 knots |
| Sea Temperature | 4 - 20 | °C | ±0.2°C |
| Air Temperature | -5 - 35 | °C | ±0.5°C |
| Air Pressure | 950 - 1050 | hPa | ±1 hPa |

---

*This API guide covers all current functionality. Check back regularly for updates as new data sources and features are added!*