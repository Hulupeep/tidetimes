#!/usr/bin/env python3
"""
Test Suite for Irish Marine Data Client
Tests all functionality of the marine_data module.
"""

import unittest
import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

from marine_data import IrishMarineDataClient, save_to_csv, format_for_display, convert_timestamp
from datetime import datetime, timedelta
import tempfile

class TestIrishMarineDataClient(unittest.TestCase):
    """Test cases for the Irish Marine Data Client."""
    
    def setUp(self):
        """Set up test client."""
        self.client = IrishMarineDataClient()
    
    def test_client_initialization(self):
        """Test that client initializes with correct base URL."""
        self.assertEqual(self.client.base_url, "https://erddap.marine.ie/erddap/tabledap")
        self.assertEqual(self.client.timeout, 30)
    
    def test_get_wave_buoy_data_returns_dict(self):
        """Test that wave buoy data returns a dictionary."""
        data = self.client.get_wave_buoy_data("M2", hours_back=1)
        self.assertIsInstance(data, dict)
        self.assertIn('buoy_id', data)
        self.assertIn('location', data)
        self.assertIn('latest', data)
    
    def test_wave_buoy_data_has_required_fields(self):
        """Test that wave buoy data contains all required fields."""
        data = self.client.get_wave_buoy_data("M1", hours_back=1)
        
        # Check main structure
        self.assertIn('buoy_id', data)
        self.assertIn('location', data)
        self.assertIn('latest', data)
        self.assertIn('data_points', data)
        
        # Check latest data fields
        if 'latest' in data and data['latest']:
            latest = data['latest']
            self.assertIn('timestamp', latest)
            self.assertIn('wave_height', latest)
            self.assertIn('wind_speed', latest)
            self.assertIn('sea_temperature', latest)
    
    def test_get_all_buoy_data(self):
        """Test getting data from all buoys."""
        all_data = self.client.get_all_buoy_data(hours_back=1)
        
        self.assertIsInstance(all_data, list)
        self.assertGreater(len(all_data), 0)
        
        # Check each buoy has required fields
        for buoy_data in all_data:
            self.assertIn('buoy_id', buoy_data)
            self.assertIn('wave_height', buoy_data)
            self.assertIn('wind_speed', buoy_data)
            self.assertIn('location', buoy_data)
    
    def test_get_galway_tide_data(self):
        """Test getting tide data from Galway Harbor."""
        tide_data = self.client.get_galway_tide_data(hours_back=6)
        
        self.assertIsInstance(tide_data, dict)
        self.assertIn('station', tide_data)
        self.assertIn('latest', tide_data)
        self.assertIn('tide_state', tide_data)
        
        # Check tide state is valid
        tide_state = tide_data.get('tide_state', '')
        self.assertIn(tide_state, ['Rising 📈', 'Falling 📉', 'Unknown'])
    
    def test_get_weather_data(self):
        """Test getting weather data."""
        weather = self.client.get_weather_data("M3", hours_back=3)
        
        self.assertIsInstance(weather, dict)
        self.assertIn('latest', weather)
        
        if 'latest' in weather:
            latest = weather['latest']
            self.assertIn('wind_speed', latest)
            self.assertIn('air_temperature', latest)
    
    def test_buoy_location_mapping(self):
        """Test that buoy locations are correctly mapped."""
        locations = {
            'M1': 'Southwest of Ireland',
            'M2': 'West of Ireland',
            'M3': 'Southwest of Ireland',
            'M4': 'Southeast of Ireland',
            'M5': 'West of Ireland',
            'M6': 'Northwest of Ireland'
        }
        
        for buoy_id, expected_location in locations.items():
            location = self.client._get_buoy_location(buoy_id)
            self.assertEqual(location, expected_location)
    
    def test_tide_state_calculation(self):
        """Test tide state calculation."""
        # Test rising tide
        rising_data = [
            {'level': 1.0},
            {'level': 1.2},
            {'level': 1.4},
            {'level': 1.6},
            {'level': 1.8}
        ]
        state = self.client._calculate_tide_state(rising_data)
        self.assertEqual(state, "Rising 📈")
        
        # Test falling tide
        falling_data = [
            {'level': 2.0},
            {'level': 1.8},
            {'level': 1.6},
            {'level': 1.4},
            {'level': 1.2}
        ]
        state = self.client._calculate_tide_state(falling_data)
        self.assertEqual(state, "Falling 📉")
    
    def test_mock_data_structure(self):
        """Test that mock data has correct structure."""
        mock_buoy = self.client._get_mock_buoy_data("M2")
        
        self.assertIn('buoy_id', mock_buoy)
        self.assertIn('location', mock_buoy)
        self.assertIn('latest', mock_buoy)
        self.assertIn('historical', mock_buoy)
        self.assertIn('note', mock_buoy)
        
        # Check historical data
        self.assertIsInstance(mock_buoy['historical'], list)
        self.assertGreater(len(mock_buoy['historical']), 0)
    
    def test_save_to_csv(self):
        """Test saving data to CSV."""
        # Create sample data
        data = {
            'historical': [
                {'time': '2024-01-01T00:00:00Z', 'wave_height': 2.5, 'wind_speed': 10},
                {'time': '2024-01-01T01:00:00Z', 'wave_height': 2.6, 'wind_speed': 11}
            ]
        }
        
        # Save to temporary file
        with tempfile.NamedTemporaryFile(mode='w', suffix='.csv', delete=False) as f:
            temp_file = f.name
        
        try:
            save_to_csv(data, temp_file)
            
            # Check file was created and has content
            self.assertTrue(os.path.exists(temp_file))
            with open(temp_file, 'r') as f:
                content = f.read()
                self.assertIn('wave_height', content)
                self.assertIn('2.5', content)
        finally:
            # Clean up
            if os.path.exists(temp_file):
                os.remove(temp_file)
    
    def test_format_for_display(self):
        """Test formatting data for display."""
        # Test buoy data formatting
        buoy_data = {
            'buoy_id': 'M2',
            'location': 'West of Ireland',
            'latest': {
                'timestamp': '2024-01-01T12:00:00Z',
                'wave_height': 2.5,
                'wind_speed': 15,
                'sea_temperature': 12,
                'pressure': 1013
            }
        }
        
        output = format_for_display(buoy_data)
        self.assertIn('M2', output)
        self.assertIn('West of Ireland', output)
        self.assertIn('2.5', output)
        self.assertIn('15', output)
    
    def test_convert_timestamp(self):
        """Test timestamp conversion."""
        # Test valid ISO timestamp
        iso_time = '2024-01-01T12:30:45Z'
        formatted = convert_timestamp(iso_time)
        self.assertIn('2024-01-01', formatted)
        self.assertIn('12:30', formatted)
        self.assertIn('UTC', formatted)
        
        # Test invalid timestamp
        invalid_time = 'not-a-timestamp'
        result = convert_timestamp(invalid_time)
        self.assertEqual(result, invalid_time)
    
    def test_data_types(self):
        """Test that numeric fields are actually numbers."""
        data = self.client.get_wave_buoy_data("M3", hours_back=1)
        
        if 'latest' in data and data['latest']:
            latest = data['latest']
            
            # Check numeric fields are float/int
            self.assertIsInstance(latest.get('wave_height', 0), (int, float))
            self.assertIsInstance(latest.get('wind_speed', 0), (int, float))
            self.assertIsInstance(latest.get('sea_temperature', 0), (int, float))
            self.assertIsInstance(latest.get('pressure', 0), (int, float))
    
    def test_error_handling(self):
        """Test that errors return mock data gracefully."""
        # Test with invalid buoy ID - should still return mock data
        data = self.client.get_wave_buoy_data("INVALID", hours_back=1)
        
        self.assertIsInstance(data, dict)
        self.assertIn('buoy_id', data)
        self.assertEqual(data['buoy_id'], 'INVALID')
        self.assertIn('note', data)  # Mock data includes a note
    
    def test_time_range_calculation(self):
        """Test that time range is calculated correctly."""
        hours_back = 6
        data = self.client.get_wave_buoy_data("M1", hours_back=hours_back)
        
        if 'historical' in data and len(data['historical']) > 0:
            # Check we have some historical data
            self.assertGreater(len(data['historical']), 0)
            
            # In mock data, we should have ~hours_back data points
            # (depending on the sampling interval)
            self.assertLessEqual(len(data['historical']), hours_back * 2)

if __name__ == '__main__':
    # Run tests with verbose output
    unittest.main(verbosity=2)