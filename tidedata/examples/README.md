# Irish Marine Institute Data Examples

This directory contains example scripts demonstrating how to use the Irish Marine Institute ERDDAP data access module.

## Files

- **`quick_examples.py`** - Seven focused examples showing different use cases
- **`README.md`** - This documentation file

## Quick Examples Overview

### Example 1: Single Wave Buoy Data
Shows how to get data from one specific wave buoy (M1-M6) and access individual values.

### Example 2: Weather Comparison
Demonstrates fetching weather data from multiple locations and comparing conditions.

### Example 3: Tidal Monitoring
Shows how to monitor tidal conditions at Galway Harbor with basic analysis.

### Example 4: Wave Buoys Summary
Gets data from all wave buoys and calculates wave statistics.

### Example 5: Save Data to CSV
Demonstrates how to save collected data to CSV files for further analysis.

### Example 6: Error Handling
Shows proper error handling and graceful degradation when APIs are unavailable.

### Example 7: Basic Data Analysis
Performs simple statistical analysis on weather data.

## Usage

Run all examples:
```bash
python examples/quick_examples.py
```

Or import specific examples in your own code:
```python
from examples.quick_examples import example_1_single_buoy
example_1_single_buoy()
```

## Requirements

Make sure you have installed the required dependencies:
```bash
pip install -r requirements.txt
```

## Data Sources

These examples access data from:
- Wave Buoys: M1, M2, M3, M4, M5, M6
- Weather Stations: Galway, Dublin Airport  
- Tide Gauges: Galway Harbor

## Notes

- Examples include fallback mock data if the ERDDAP server is unavailable
- All examples are beginner-friendly with detailed comments
- Output includes colored emojis for better readability
- CSV files are saved to the `docs/` directory