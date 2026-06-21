import React from "react";
import { NavigationContainer } from "@react-navigation/native";
import { createStackNavigator } from "@react-navigation/stack";
import LoginScreen from "./src/screens/LoginScreen";
import SignupScreen from "./src/screens/SignupScreen";
import HomeScreen from "./src/screens/HomeScreen";
import { CartProvider } from "./src/context/CartContext";
import CartScreen from "./src/screens/CartScreen";
import ProductDetailsScreen from "./src/screens/ProductDetailsScreen"; // Import ProductDetails


const Stack = createStackNavigator();

export default function App() {
  return (
    <CartProvider>
      <NavigationContainer>
        <Stack.Navigator initialRouteName="Login">
          <Stack.Screen name="Login" component={LoginScreen} />
          <Stack.Screen name="Signup" component={SignupScreen} />
          <Stack.Screen name="Home" component={HomeScreen} />
          <Stack.Screen name="ProductDetails" component={ProductDetailsScreen} /> 
          <Stack.Screen name="Cart" component={CartScreen} />
          {/* Add this line */}
        </Stack.Navigator>
      </NavigationContainer>
    </CartProvider>
  );
}
