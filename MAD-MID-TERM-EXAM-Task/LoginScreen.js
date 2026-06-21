import React from "react";
import { View, Text, Button } from "react-native";
import { GoogleAuthProvider, signInWithPopup } from "firebase/auth";
import { auth, provider } from "/firebaseConfig";
import axios from "axios";

const LoginScreen = ({ navigation }) => {
  const handleGoogleLogin = async () => {
    try {
      const result = await signInWithPopup(auth, provider);
      const user = result.user;
      const userData = {
        name: user.displayName,
        email: user.email,
        profilePicture: user.photoURL,
      };

      await axios.post("http://localhost:5000/api/auth", userData);
      navigation.navigate("JobListings", { user: userData });
    } catch (error) {
      console.error(error);
    }
  };

  return (
    <View>
      <Text>Login</Text>
      <Button title="Sign in with Google" onPress={handleGoogleLogin} />
    </View>
  );
};

export default LoginScreen;
