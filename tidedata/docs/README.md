# Irish Marine Institute ERDDAP Data Access

A Python module for accessing real-time marine and weather data from the Irish Marine Institute's ERDDAP server.

## Features

- 🌊 **Wave Data**: Access data from all Irish wave buoys (M1-M6)
- 🌤️ **Weather Data**: Get wind, temperature, and pressure readings
- 🌊 **Tidal Data**: Monitor water levels at Galway Harbor
- 💾 **Data Export**: Save data to CSV files for analysis
- 🔄 **Error Handling**: Graceful fallback to mock data when API unavailable
- 📊 **Data Analysis**: Built-in formatting and statistical functions

## Quick Start

1. **Install Dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

2. **Run Main Application**:
   ```bash
   python src/main.py
   ```

3. **Try Examples**:
   ```bash
   python examples/quick_examples.py
   ```

## Data Sources

### Wave Buoys (M1-M6)
- **M1, M2, M3, M4, M5, M6**: Irish wave monitoring network
- **Parameters**: Wave height (VHM0), wave period (VTPK), wave direction (VMDR)
- **Location**: Atlantic waters around Ireland

### Weather Stations
- **Galway**: Local weather conditions
- **Dublin Airport**: Reference weather data
- **Parameters**: Wind speed/direction, air temperature, atmospheric pressure, sea temperature

### Tide Gauges
- **Galway Harbor**: Tidal water level measurements
- **Parameters**: Water level, tide state analysis

## Usage Examples

### Basic Usage
```python
from src.marine_data import IrishMarineDataClient

# Create client
client = IrishMarineDataClient()

# Get wave data
wave_data = client.get_wave_buoy_data('M1', hours_back=6)
print(f"Current wave height: {wave_data['latest']['VHM0']} meters")

# Get weather data
weather = client.get_weather_data('galway', hours_back=12)
print(f"Wind speed: {weather['latest']['WindSpeed']} m/s")

# Get tidal data
tides = client.get_galway_tide_data(hours_back=24)
print(f"Water level: {tides['latest']['Water_Level']} meters")
```

### Save Data to CSV
```python
# Fetch and save data
wave_data = client.get_wave_buoy_data('M2', 24)
client.save_to_csv(wave_data, 'wave_data_m2.csv')
```

### Get All Buoys
```python
# Get data from all wave buoys
all_buoys = client.get_all_buoy_data(6)
for buoy_id, data in all_buoys['buoys'].items():
    if 'latest' in data and data['latest']:
        print(f"{buoy_id}: {data['latest']['VHM0']}m")
```

## File Structure

```
├── src/
│   ├── marine_data.py    # Main module
│   └── main.py           # Complete demo application
├── examples/
│   ├── quick_examples.py # Simple usage examples
│   └── README.md         # Examples documentation
├── tests/
│   └── test_marine_data.py # Unit tests
├── docs/                 # Output directory for CSV files
├── requirements.txt      # Python dependencies
└── README.md            # This file
```

## API Reference

### IrishMarineDataClient

Main class for accessing marine data.

#### Methods

- **`get_wave_buoy_data(buoy_id, hours_back=24)`**
  - Get wave data from specific buoy (M1-M6)
  - Returns: Dictionary with latest readings and historical data

- **`get_weather_data(location, hours_back=24)`**
  - Get weather data from station ('galway' or 'dublin_airport')
  - Returns: Dictionary with wind, temperature, pressure data

- **`get_galway_tide_data(hours_back=24)`**
  - Get tidal data from Galway Harbor
  - Returns: Dictionary with water level measurements

- **`get_all_buoy_data(hours_back=6)`**
  - Get data from all wave buoys
  - Returns: Dictionary with data from all buoys

- **`save_to_csv(data, filename)`**
  - Save data to CSV file in docs/ directory
  - Returns: Boolean indicating success

- **`format_for_display(data)`**
  - Format data for console output
  - Returns: Formatted string

### Utility Functions

- **`convert_timestamp(timestamp_str)`**: Convert timestamp to readable format
- **`print_summary_table(all_data)`**: Print formatted summary of all data

## Error Handling

The module includes robust error handling:

- **Network Issues**: Falls back to mock data for demonstration
- **Invalid Parameters**: Raises ValueError with helpful messages
- **API Changes**: Graceful degradation with informative error messages
- **Data Parsing**: Safe handling of malformed responses

## Testing

Run the test suite:
```bash
python tests/test_marine_data.py
```

Tests include:
- Unit tests for all major functions
- Mock data generation testing
- Integration testing
- Error handling validation

## Data Format

All functions return dictionaries with consistent structure:

```python
{
    'data_points': 24,           # Number of data points
    'time_range': {              # Time range queried
        'start': '2025-01-14T00:00:00',
        'end': '2025-01-14T24:00:00'
    },
    'latest': {                  # Most recent reading
        'time': '2025-01-14T12:00:00Z',
        'VHM0': 2.5,            # Wave height (m)
        'VTPK': 8.2,            # Wave period (s)
        # ... other parameters
    },
    'all_data': [...]           # All historical data points
}
```

## Requirements

- Python 3.6+
- requests >= 2.25.0
- pandas >= 1.3.0
- python-dateutil >= 2.8.0

## Troubleshooting

### Common Issues

1. **Network Connectivity**:
   - Check internet connection
   - Verify ERDDAP server status: https://erddap.marine.ie/erddap/

2. **No Data Available**:
   - ERDDAP server may be under maintenance
   - Dataset IDs may have changed
   - Try with shorter time ranges

3. **Import Errors**:
   - Ensure all dependencies are installed: `pip install -r requirements.txt`
   - Check Python path if running from different directory

### Mock Data

When the ERDDAP server is unavailable, the module provides realistic mock data for testing and demonstration. Mock data is clearly labeled in the output.

## Contributing

To extend this module:

1. Add new dataset IDs to the `datasets` dictionary
2. Create new methods following the existing pattern
3. Include error handling and mock data fallbacks
4. Add tests for new functionality
5. Update documentation

## License

This module is provided for educational and research purposes. Please respect the Irish Marine Institute's data usage policies when accessing their ERDDAP server.

## Support

- **ERDDAP Server**: https://erddap.marine.ie/erddap/
- **Irish Marine Institute**: https://www.marine.ie/
- **Dataset Catalog**: Browse available datasets on the ERDDAP server

---

**Note**: This module is designed to be beginner-friendly while providing professional-grade functionality. All functions include detailed error handling and user-friendly output formatting.