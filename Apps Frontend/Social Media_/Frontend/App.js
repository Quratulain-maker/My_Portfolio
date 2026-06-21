import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { Ionicons } from '@expo/vector-icons';

// Import Screens
import FeedScreen from './src/screens/FeedScreen';
import PostDetailsScreen from './src/screens/PostDetailsScreen';
import ProfileScreen from './src/screens/ProfileScreen';

const Stack = createStackNavigator();
const Tab = createBottomTabNavigator();

// 🛠 Fix: Unique screen names & correct navigator setup
function FeedStack() {
  return (
    <Stack.Navigator>
      <Stack.Screen name="FeedScreen" component={FeedScreen} options={{ headerShown: false }} />
      <Stack.Screen name="PostDetailsScreen" component={PostDetailsScreen} options={{ title: 'Post Details' }} />
    </Stack.Navigator>
  );
}

export default function App() {
  return (
    <NavigationContainer>
      <Tab.Navigator
        screenOptions={({ route }) => ({
          tabBarIcon: ({ color, size }) => {
            let iconName = route.name === 'Feed' ? 'list' : 'person';
            return <Ionicons name={iconName} size={size} color={color} />;
          },
          tabBarActiveTintColor: '#4CAF50',
          tabBarInactiveTintColor: 'gray',
        })}
      >
        <Tab.Screen name="Feed" component={FeedStack} options={{ headerShown: false }} />
        <Tab.Screen name="ProfileScreen" component={ProfileScreen} />
      </Tab.Navigator>
    </NavigationContainer>
  );
}
