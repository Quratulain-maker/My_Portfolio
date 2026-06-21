import React, { useState, useEffect } from 'react';
import { View, Text, TextInput, Button, FlatList, TouchableOpacity, ActivityIndicator, Image, StyleSheet } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { createStackNavigator } from '@react-navigation/stack';
import { NavigationContainer } from '@react-navigation/native';
import { app, auth, db } from "./src/firebaseConfig";
console.log("Firebase Initialized:", app ? "Yes" : "No");

const Stack = createStackNavigator();

const LoginScreen = ({ navigation }) => {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');

  const handleLogin = () => {
    if (username && password) {
      navigation.replace('JobList');
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Login</Text>
      <TextInput placeholder="Username" value={username} onChangeText={setUsername} style={styles.input} />
      <TextInput placeholder="Password" value={password} onChangeText={setPassword} secureTextEntry style={styles.input} />
      <Button title="Login" onPress={handleLogin} color="#007BFF" />
    </View>
  );
};

const JobListScreen = ({ navigation }) => {
  const [jobs, setJobs] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchJobs = async () => {
      try {
        const response = await fetch('https://jsonfakery.com/jobs');
        const data = await response.json();
        if (Array.isArray(data)) {
          setJobs(data);
          await AsyncStorage.setItem('jobs', JSON.stringify(data));
        } else {
          console.error('Unexpected API response:', data);
        }
      } catch (error) {
        console.error('Error fetching jobs:', error);
        const cachedJobs = await AsyncStorage.getItem('jobs');
        if (cachedJobs) setJobs(JSON.parse(cachedJobs));
      } finally {
        setLoading(false);
      }
    };
    fetchJobs();
  }, []);

  if (loading) {
    return <ActivityIndicator size="large" color="#007BFF" style={{ marginTop: 20 }} />;
  }

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Job Listings</Text>
      <FlatList
        data={jobs}
        keyExtractor={(item, index) => (item.id ? item.id.toString() : index.toString())}
        renderItem={({ item }) => (
          <TouchableOpacity onPress={() => navigation.navigate('JobDetail', { job: item })} style={styles.jobItem}>
            {item.logo && <Image source={{ uri: item.logo }} style={styles.logo} />}
            <View>
              <Text style={styles.jobTitle}>{item.title}</Text>
              <Text style={styles.company}>{item.company}</Text>
              <Text style={styles.location}>{item.location}</Text>
            </View>
          </TouchableOpacity>
        )}
      />
    </View>
  );
};

const JobDetailScreen = ({ route }) => {
  const { job } = route.params;

  return (
    <View style={styles.container}>
      <Text style={styles.title}>{job.title}</Text>
      {job.logo && <Image source={{ uri: job.logo }} style={styles.detailLogo} />}
      <Text style={styles.detailText}>Company: {job.company}</Text>
      <Text style={styles.detailText}>Location: {job.location}</Text>
      <Text style={styles.detailText}>Description: {job.description || 'No description available'}</Text>
      <Text style={styles.detailText}>Requirements: {job.requirements || 'No specific requirements'}</Text>
      <Button title="Apply Now" onPress={() => alert('Application link: ' + (job.apply_link || 'Not provided'))} color="#28A745" />
    </View>
  );
};

export default function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator screenOptions={{ headerStyle: { backgroundColor: '#007BFF' }, headerTintColor: '#fff' }}>
        <Stack.Screen name="Login" component={LoginScreen} />
        <Stack.Screen name="JobList" component={JobListScreen} />
        <Stack.Screen name="JobDetail" component={JobDetailScreen} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    padding: 20,
    backgroundColor: '#F8F9FA',
  },
  title: {
    fontSize: 26,
    fontWeight: 'bold',
    textAlign: 'center',
    color: '#007BFF',
    marginBottom: 20,
  },
  input: {
    borderWidth: 1,
    borderColor: '#CED4DA',
    padding: 12,
    marginBottom: 10,
    borderRadius: 8,
    backgroundColor: '#FFF',
  },
  jobItem: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 12,
    borderBottomWidth: 1,
    borderColor: '#CED4DA',
    backgroundColor: '#FFF',
    borderRadius: 8,
    marginBottom: 10,
  },
  logo: {
    width: 50,
    height: 50,
    marginRight: 10,
    borderRadius: 25,
  },
  jobTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#343A40',
  },
  company: {
    color: '#6C757D',
  },
  location: {
    color: '#495057',
  },
  detailLogo: {
    width: 100,
    height: 100,
    alignSelf: 'center',
    marginBottom: 10,
  },
  detailText: {
    fontSize: 16,
    marginBottom: 10,
    color: '#495057',
  },
});
