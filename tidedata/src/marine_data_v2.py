#!/usr/bin/env python3
"""
Irish Marine Data Client V2 - WORKING VERSION
A simple, beginner-friendly Python module for accessing Irish Marine Institute ERDDAP data.
No API key required! Free, open-source marine data from Ireland's coast.
"""

import requests
import csv
from io import StringIO
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any
import time

class IrishMarineDataClient:
    """
    Simple client for accessing Irish Marine Institute ERDDAP data.
    
    This makes it easy to get:
    - Wave heights and conditions from buoys M1-M6
    - Tide levels from Galway Harbor
    - Weather data (wind, temperature, pressure)
    - Sea temperature readings
    """
    
    def __init__(self):
        """Initialize the client with ERDDAP base URL."""
        self.base_url = "https://erddap.marine.ie/erddap/tabledap"
        self.timeout = 30  # seconds to wait for response
        
    def get_wave_buoy_data(self, buoy_id: str = "M2", hours_back: int = 24) -> Dict:
        """
        Get wave and weather data from Irish weather buoys (M1-M6).
        
        Args:
            buoy_id: Buoy identifier (M1, M2, M3, M4, M5, M6)
            hours_back: How many hours of historical data to retrieve
            
        Returns:
            Dictionary with latest readings and historical data
            
        Example:
            >>> client = IrishMarineDataClient()
            >>> data = client.get_wave_buoy_data("M2", 6)
            >>> print(f"Wave height: {data['latest']['wave_height']}m")
        """
        
        # Calculate time range
        end_time = datetime.utcnow()
        start_time = end_time - timedelta(hours=hours_back)
        
        # Format times for ERDDAP (ISO 8601)
        time_start = start_time.strftime("%Y-%m-%dT%H:%M:%SZ")
        
        # Build the WORKING query URL
        dataset = "IWBNetwork"
        # Note: WaveHeight is in meters, WindSpeed in knots
        variables = "station_id,time,WaveHeight,WavePeriod,MeanWaveDirection,WindSpeed,WindDirection,SeaTemperature,AirTemperature,AtmosphericPressure"
        
        # Build URL with proper encoding (> must be %3E, quotes must be %22)
        url = f"{self.base_url}/{dataset}.csv"
        # WORKING FORMAT: Use %3E for >= and %22 for quotes
        query = f"?{variables}&station_id=%22{buoy_id}%22&time%3E={time_start}"
        full_url = url + query
        
        try:
            print(f"🌊 Fetching data from buoy {buoy_id}...")
            response = requests.get(full_url, timeout=self.timeout)
            
            if response.status_code == 200:
                return self._parse_buoy_csv(response.text, buoy_id)
            else:
                print(f"⚠️ Error: Server returned status {response.status_code}")
                print("📊 Using sample data for demonstration...")
                return self._get_mock_buoy_data(buoy_id)
                
        except Exception as e:
            print(f"⚠️ Connection error: {str(e)}")
            print("📊 Using sample data for demonstration...")
            return self._get_mock_buoy_data(buoy_id)
    
    def get_galway_tide_data(self, hours_back: int = 24) -> Dict:
        """
        Get tide level data from Galway Harbor.
        
        Args:
            hours_back: How many hours of historical data to retrieve
            
        Returns:
            Dictionary with current tide level and historical data
            
        Example:
            >>> client = IrishMarineDataClient()
            >>> tides = client.get_galway_tide_data(12)
            >>> print(f"Current tide level: {tides['latest']['water_level']}m")
        """
        
        # Calculate time range
        end_time = datetime.utcnow()
        start_time = end_time - timedelta(hours=hours_back)
        
        # Format times for ERDDAP
        time_start = start_time.strftime("%Y-%m-%dT%H:%M:%SZ")
        
        # Build the WORKING query URL
        dataset = "IrishNationalTideGaugeNetwork"
        variables = "station_id,time,Water_Level_LAT,Water_Level_OD_Malin"
        
        # Build URL with proper encoding
        url = f"{self.base_url}/{dataset}.csv"
        # WORKING FORMAT: Use %3E for >= and %20 for spaces in "Galway Port"
        query = f"?{variables}&station_id=%22Galway%20Port%22&time%3E={time_start}"
        full_url = url + query
        
        try:
            print(f"📈 Fetching tide data from Galway Harbor...")
            response = requests.get(full_url, timeout=self.timeout)
            
            if response.status_code == 200:
                return self._parse_tide_csv(response.text)
            else:
                print(f"⚠️ Error: Server returned status {response.status_code}")
                print("📊 Using sample data for demonstration...")
                return self._get_mock_tide_data()
                
        except Exception as e:
            print(f"⚠️ Connection error: {str(e)}")
            print("📊 Using sample data for demonstration...")
            return self._get_mock_tide_data()
    
    def get_all_buoy_data(self, hours_back: int = 1) -> List[Dict]:
        """
        Get latest data from all M-series buoys (M1-M6).
        
        Args:
            hours_back: How many hours of data to retrieve
            
        Returns:
            List of dictionaries, one for each buoy
            
        Example:
            >>> client = IrishMarineDataClient()
            >>> all_buoys = client.get_all_buoy_data(1)
            >>> for buoy in all_buoys:
            >>>     print(f"{buoy['buoy_id']}: {buoy['wave_height']}m waves")
        """
        
        buoys = ["M1", "M2", "M3", "M4", "M5", "M6"]
        results = []
        
        for buoy_id in buoys:
            print(f"📍 Checking buoy {buoy_id}...")
            data = self.get_wave_buoy_data(buoy_id, hours_back)
            
            if data and data.get('latest'):
                summary = {
                    'buoy_id': buoy_id,
                    'timestamp': data['latest'].get('timestamp', 'N/A'),
                    'wave_height': data['latest'].get('wave_height', 0),
                    'wind_speed': data['latest'].get('wind_speed', 0),
                    'sea_temp': data['latest'].get('sea_temperature', 0),
                    'location': data.get('location', 'Irish Waters')
                }
                results.append(summary)
            
            time.sleep(0.5)  # Be nice to the server
        
        return results
    
    def get_weather_data(self, station: str = "M2", hours_back: int = 6) -> Dict:
        """
        Get weather data (wind, temperature, pressure) from a marine station.
        
        Args:
            station: Station ID (M1-M6 or coastal station name)
            hours_back: Hours of historical data
            
        Returns:
            Dictionary with weather parameters
            
        Example:
            >>> client = IrishMarineDataClient()
            >>> weather = client.get_weather_data("M3", 3)
            >>> print(f"Wind: {weather['latest']['wind_speed']} knots")
        """
        
        # For M-series buoys, use the buoy data function
        if station.startswith("M") and len(station) == 2:
            return self.get_wave_buoy_data(station, hours_back)
        
        # For other stations, use a different dataset
        # This is a placeholder for coastal weather stations
        return self._get_mock_weather_data(station)
    
    def _parse_buoy_csv(self, csv_text: str, buoy_id: str) -> Dict:
        """Parse ERDDAP CSV response for buoy data."""
        
        try:
            # Parse CSV using csv module
            reader = csv.DictReader(StringIO(csv_text))
            rows = list(reader)
            
            # Skip units row if present
            if rows and not rows[0].get('time', '').startswith('20'):
                rows = rows[1:]
            
            if not rows:
                return self._get_mock_buoy_data(buoy_id)
            
            # Get the latest row
            latest_row = rows[-1]
            
            # Extract and convert values with proper field names
            latest_data = {
                'timestamp': latest_row.get('time', ''),
                'wave_height': float(latest_row.get('WaveHeight', 0) or 0),
                'peak_period': float(latest_row.get('WavePeriod', 0) or 0),
                'wave_direction': float(latest_row.get('MeanWaveDirection', 0) or 0),
                'wind_speed': float(latest_row.get('WindSpeed', 0) or 0),
                'wind_direction': float(latest_row.get('WindDirection', 0) or 0),
                'sea_temperature': float(latest_row.get('SeaTemperature', 0) or 0),
                'air_temperature': float(latest_row.get('AirTemperature', 0) or 0),
                'pressure': float(latest_row.get('AtmosphericPressure', 0) or 0)
            }
            
            # Get historical data
            historical = []
            for row in rows:
                if row.get('time', '').startswith('20'):  # Valid timestamp
                    historical.append({
                        'time': row.get('time', ''),
                        'wave_height': float(row.get('WaveHeight', 0) or 0),
                        'wind_speed': float(row.get('WindSpeed', 0) or 0)
                    })
            
            return {
                'buoy_id': buoy_id,
                'location': self._get_buoy_location(buoy_id),
                'latest': latest_data,
                'historical': historical,
                'data_points': len(rows)
            }
            
        except Exception as e:
            print(f"⚠️ Error parsing data: {str(e)}")
            return self._get_mock_buoy_data(buoy_id)
    
    def _parse_tide_csv(self, csv_text: str) -> Dict:
        """Parse ERDDAP CSV response for tide data."""
        
        try:
            # Parse CSV using csv module
            reader = csv.DictReader(StringIO(csv_text))
            rows = list(reader)
            
            # Skip units row if present
            if rows and not rows[0].get('time', '').startswith('20'):
                rows = rows[1:]
            
            if not rows:
                return self._get_mock_tide_data()
            
            # Get latest reading
            latest_row = rows[-1]
            
            latest_data = {
                'timestamp': latest_row.get('time', ''),
                'water_level': float(latest_row.get('Water_Level_LAT', 0) or 0),
                'water_level_malin': float(latest_row.get('Water_Level_OD_Malin', 0) or 0)
            }
            
            # Get historical for tide chart
            historical = []
            for row in rows:
                if row.get('time', '').startswith('20'):  # Valid timestamp
                    historical.append({
                        'time': row.get('time', ''),
                        'level': float(row.get('Water_Level_LAT', 0) or 0)
                    })
            
            return {
                'station': 'Galway Port',
                'latest': latest_data,
                'historical': historical,
                'data_points': len(rows),
                'tide_state': self._calculate_tide_state(historical)
            }
            
        except Exception as e:
            print(f"⚠️ Error parsing tide data: {str(e)}")
            return self._get_mock_tide_data()
    
    def _calculate_tide_state(self, historical: List[Dict]) -> str:
        """Determine if tide is rising or falling."""
        if len(historical) < 2:
            return "Unknown"
        
        recent_levels = [h['level'] for h in historical[-5:]]
        if recent_levels[-1] > recent_levels[0]:
            return "Rising 📈"
        else:
            return "Falling 📉"
    
    def _get_buoy_location(self, buoy_id: str) -> str:
        """Get human-readable location for buoy."""
        locations = {
            'M1': 'Southwest of Ireland',
            'M2': 'West of Ireland', 
            'M3': 'Southwest of Ireland',
            'M4': 'Southeast of Ireland',
            'M5': 'West of Ireland',
            'M6': 'Northwest of Ireland'
        }
        return locations.get(buoy_id, 'Irish Waters')
    
    def _get_mock_buoy_data(self, buoy_id: str) -> Dict:
        """Return realistic mock data for demonstration."""
        import random
        
        now = datetime.utcnow()
        
        # Generate realistic values based on buoy location
        base_wave_height = {
            'M1': 2.5, 'M2': 2.8, 'M3': 2.2,
            'M4': 1.8, 'M5': 3.0, 'M6': 2.6
        }.get(buoy_id, 2.0)
        
        latest = {
            'timestamp': now.isoformat() + 'Z',
            'wave_height': round(base_wave_height + random.uniform(-0.5, 0.5), 1),
            'peak_period': round(8 + random.uniform(-2, 2), 1),
            'wave_direction': round(random.uniform(0, 360), 0),
            'wind_speed': round(10 + random.uniform(-5, 10), 1),
            'wind_direction': round(random.uniform(0, 360), 0),
            'sea_temperature': round(12 + random.uniform(-2, 2), 1),
            'air_temperature': round(14 + random.uniform(-3, 3), 1),
            'pressure': round(1013 + random.uniform(-10, 10), 1)
        }
        
        # Generate historical data
        historical = []
        for i in range(24):
            time_point = now - timedelta(hours=i)
            historical.append({
                'time': time_point.isoformat() + 'Z',
                'wave_height': round(base_wave_height + random.uniform(-0.5, 0.5), 1),
                'wind_speed': round(10 + random.uniform(-5, 10), 1)
            })
        
        return {
            'buoy_id': buoy_id,
            'location': self._get_buoy_location(buoy_id),
            'latest': latest,
            'historical': list(reversed(historical)),
            'data_points': 24,
            'note': 'Sample data for demonstration'
        }
    
    def _get_mock_tide_data(self) -> Dict:
        """Return realistic mock tide data."""
        import random
        import math
        
        now = datetime.utcnow()
        
        # Generate realistic tidal pattern (semi-diurnal)
        historical = []
        for i in range(48):  # 48 half-hour readings = 24 hours
            time_point = now - timedelta(minutes=i*30)
            # Create sinusoidal tide pattern
            tide_level = 2.5 + 2.0 * math.sin(i * math.pi / 12)  # ~12 hour cycle
            tide_level += random.uniform(-0.1, 0.1)  # Add some noise
            
            historical.append({
                'time': time_point.isoformat() + 'Z',
                'level': round(tide_level, 2)
            })
        
        historical = list(reversed(historical))
        
        latest = {
            'timestamp': now.isoformat() + 'Z',
            'water_level': historical[-1]['level'],
            'water_level_malin': historical[-1]['level'] + 3.08  # Malin datum offset
        }
        
        return {
            'station': 'Galway Port',
            'latest': latest,
            'historical': historical,
            'data_points': 48,
            'tide_state': self._calculate_tide_state(historical),
            'note': 'Sample data for demonstration'
        }
    
    def _get_mock_weather_data(self, station: str) -> Dict:
        """Return realistic mock weather data."""
        import random
        
        now = datetime.utcnow()
        
        latest = {
            'timestamp': now.isoformat() + 'Z',
            'wind_speed': round(8 + random.uniform(-3, 8), 1),
            'wind_direction': round(random.uniform(0, 360), 0),
            'air_temperature': round(13 + random.uniform(-3, 3), 1),
            'pressure': round(1013 + random.uniform(-10, 10), 1),
            'humidity': round(70 + random.uniform(-10, 20), 0),
            'visibility': round(10 + random.uniform(-5, 5), 1)
        }
        
        return {
            'station': station,
            'latest': latest,
            'note': 'Sample data for demonstration'
        }

# Utility functions for data export and formatting

def save_to_csv(data: Dict, filename: str):
    """
    Save marine data to CSV file.
    
    Args:
        data: Dictionary of marine data
        filename: Output CSV filename
    """
    
    if 'historical' in data and data['historical']:
        import csv
        with open(filename, 'w', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=data['historical'][0].keys())
            writer.writeheader()
            writer.writerows(data['historical'])
        print(f"💾 Data saved to {filename}")

def format_for_display(data: Dict) -> str:
    """
    Format marine data for console display.
    
    Args:
        data: Dictionary of marine data
        
    Returns:
        Formatted string for printing
    """
    
    output = []
    
    if 'buoy_id' in data:
        output.append(f"\n🌊 Buoy {data['buoy_id']} - {data['location']}")
        output.append("=" * 50)
        
        if 'latest' in data:
            latest = data['latest']
            output.append(f"📍 Last Update: {latest.get('timestamp', 'N/A')}")
            output.append(f"🌊 Wave Height: {latest.get('wave_height', 0):.1f}m")
            output.append(f"💨 Wind Speed: {latest.get('wind_speed', 0):.1f} knots")
            output.append(f"🌡️ Sea Temperature: {latest.get('sea_temperature', 0):.1f}°C")
            output.append(f"📊 Pressure: {latest.get('pressure', 0):.1f} mbar")
    
    elif 'station' in data and data['station'] == 'Galway Port':
        output.append(f"\n📈 Tide Station: {data['station']}")
        output.append("=" * 50)
        
        if 'latest' in data:
            latest = data['latest']
            output.append(f"📍 Last Update: {latest.get('timestamp', 'N/A')}")
            output.append(f"🌊 Water Level: {latest.get('water_level', 0):.2f}m LAT")
            output.append(f"📊 Tide State: {data.get('tide_state', 'Unknown')}")
    
    return "\n".join(output)

def convert_timestamp(iso_string: str) -> str:
    """
    Convert ISO timestamp to human-readable format.
    
    Args:
        iso_string: ISO 8601 timestamp
        
    Returns:
        Formatted date/time string
    """
    
    try:
        dt = datetime.fromisoformat(iso_string.replace('Z', '+00:00'))
        return dt.strftime("%Y-%m-%d %H:%M UTC")
    except:
        return iso_string

def get_working_urls() -> Dict[str, str]:
    """
    Get dictionary of working ERDDAP URLs for common queries.
    
    Returns:
        Dictionary with descriptive keys and working URLs
    """
    
    return {
        "M2_waves": "https://erddap.marine.ie/erddap/tabledap/IWBNetwork.csv?station_id,time,WaveHeight,WindSpeed,SeaTemperature&station_id=%22M2%22&time%3E=2024-11-01",
        "M3_waves": "https://erddap.marine.ie/erddap/tabledap/IWBNetwork.csv?station_id,time,WaveHeight,WindSpeed,SeaTemperature&station_id=%22M3%22&time%3E=2024-11-01",
        "M4_waves": "https://erddap.marine.ie/erddap/tabledap/IWBNetwork.csv?station_id,time,WaveHeight,WindSpeed,SeaTemperature&station_id=%22M4%22&time%3E=2024-11-01",
        "M5_waves": "https://erddap.marine.ie/erddap/tabledap/IWBNetwork.csv?station_id,time,WaveHeight,WindSpeed,SeaTemperature&station_id=%22M5%22&time%3E=2024-11-01",
        "M6_waves": "https://erddap.marine.ie/erddap/tabledap/IWBNetwork.csv?station_id,time,WaveHeight,WindSpeed,SeaTemperature&station_id=%22M6%22&time%3E=2024-11-01",
        "galway_tides": "https://erddap.marine.ie/erddap/tabledap/IrishNationalTideGaugeNetwork.csv?station_id,time,Water_Level_LAT&station_id=%22Galway%20Port%22&time%3E=2024-11-01",
        "smartbay_waves": "https://erddap.marine.ie/erddap/tabledap/IWaveBNetwork.csv?station_id,time,SignificantWaveHeight&station_id=%22SmartBay%20Wave%20Buoy%22&time%3E=2024-11-01"
    }

if __name__ == "__main__":
    # Quick test
    print("🌊 Irish Marine Data Client V2 - Testing Working URLs")
    print("=" * 60)
    
    client = IrishMarineDataClient()
    
    # Test M2 buoy
    print("\nTesting M2 buoy data...")
    data = client.get_wave_buoy_data("M2", hours_back=2)
    if data and 'latest' in data:
        print(format_for_display(data))
    
    # Test Galway tides
    print("\nTesting Galway tide data...")
    tides = client.get_galway_tide_data(hours_back=6)
    if tides and 'latest' in tides:
        print(format_for_display(tides))
    
    # Show working URLs
    print("\n" + "=" * 60)
    print("WORKING URLS - Copy and paste these into your browser:")
    print("=" * 60)
    urls = get_working_urls()
    for name, url in urls.items():
        print(f"\n{name}:")
        print(url)