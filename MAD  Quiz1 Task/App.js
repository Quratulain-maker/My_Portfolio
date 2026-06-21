import React, { useState, useEffect } from 'react';
import { View, Text, Image, Button, StyleSheet, StatusBar, Platform } from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';

// FakeStore API URL (Simulating fetching data)
const API_URL = 'https://fakestoreapi.com/products'; // Replace with your actual weather API URL when available

const Stack = createStackNavigator();

const HomeScreen = ({ navigation }) => {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>Welcome to the Weather App</Text>
      <Button 
        title="Check Weather"
        onPress={() => navigation.navigate('Weather')} // Navigate to WeatherScreen
      />
    </View>
  );
};

const WeatherScreen = () => {
  const [weatherData, setWeatherData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null); // To handle error state

  useEffect(() => {
    fetchWeatherData();
  }, []);

  const fetchWeatherData = async () => {
    try {
      const response = await fetch(API_URL); // Fetching data from FakeStore API
      const data = await response.json();

      // For now, we simulate weather data (you should replace this logic to fetch actual weather data)
      setWeatherData({
        main: {
          temp: 22, // Example temperature
        },
        weather: [
          {
            description: 'Clear Sky',
            icon: '01d',
          },
        ],
        wind: {
          speed: 3.6,
        },
        sys: {
          country: 'PK',
        },
      });
      setLoading(false);
    } catch (error) {
      setError(error.message); // If there's an error, set the error state
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <View style={styles.loadingContainer}>
        <Text style={styles.loadingText}>Loading...</Text>
      </View>
    );
  }

  if (error) {
    return (
      <View style={styles.errorContainer}>
        <Text style={styles.errorText}>Error: {error}</Text>
      </View>
    );
  }

  // Ensure weatherData exists and has the necessary structure
  const { main, weather, wind, sys } = weatherData || {}; // Destructuring with fallback to empty object
  const temperature = main ? main.temp : null; // Safely access temp
  const description = weather && weather[0] ? weather[0].description : '';
  const icon = weather && weather[0] ? `http://openweathermap.org/img/wn/${weather[0].icon}.png` : '';
  const country = sys ? sys.country : '';

  if (temperature === null) {
    return (
      <View style={styles.errorContainer}>
        <Text style={styles.errorText}>Weather data is not available</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <StatusBar barStyle="light-content" />
      <View style={styles.weatherContainer}>
        {icon ? <Image source={{ uri: icon }} style={styles.icon} /> : null}
        <Text style={styles.temperature}>{temperature}°C</Text>
        <Text style={styles.description}>{description}</Text>
        <Text style={styles.city}>{'Islamabad'}, {country}</Text>
        <Text style={styles.wind}>Wind Speed: {wind ? wind.speed : 'N/A'} m/s</Text>
      </View>
    </View>
  );
};

export default function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator initialRouteName="Home">
        <Stack.Screen name="Home" component={HomeScreen} />
        <Stack.Screen name="Weather" component={WeatherScreen} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 2,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'plum',
    paddingTop: Platform.OS === 'android' ? 20 : 0, // StatusBar adjustment for Android
  },
  title: {
    fontSize: 40,
    fontWeight: 'bold',
    color: 'purple',
    marginBottom: 20,
  },
  weatherContainer: {
    alignItems: 'center',
    justifyContent: 'center',
    padding: 60,
    backgroundColor: 'purple', // Transparent background to make text pop
    borderRadius: 30,
    paddingVertical: 50,
    paddingHorizontal: 50,
  },
  icon: {
    width: 100,
    height: 100,
    marginBottom: 10,
  },
  temperature: {
    fontSize: '150',
    fontWeight: 'bold',
    color: 'white',
  },
  description: {
    fontSize: 30,
    color: 'white',
    marginBottom: 10,
  },
  city: {
    fontSize: 28,
    fontWeight: '600',
    color: 'white',
    marginBottom: 10,
  },
  wind: {
    fontSize: 18,
    color: 'white',
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'skyblue',
  },
  loadingText: {
    fontSize: 24,
    fontWeight: 'bold',
    color: 'luxury',
  },
  errorContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'violet',
  },
  errorText: {
    fontSize: 20,
    fontWeight: 'bold',
    color: 'luxury',
  },
});
