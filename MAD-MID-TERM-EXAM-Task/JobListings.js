import React, { useEffect, useState } from "react";
import { View, Text, Image, Button, FlatList } from "react-native";
import axios from "axios";
import { signOut } from "firebase/auth";
import { auth } from "/firebaseConfig";

const JobListings = ({ route, navigation }) => {
  const { user } = route.params;
  const [jobs, setJobs] = useState([]);

  useEffect(() => {
    axios.get("http://localhost:5000/api/jobs").then((response) => {
      setJobs(response.data);
    });
  }, []);

  const handleLogout = async () => {
    await signOut(auth);
    navigation.navigate("Login");
  };

  return (
    <View>
      <Image source={{ uri: user.profilePicture }} style={{ width: 50, height: 50, borderRadius: 25 }} />
      <Text>{user.name}</Text>
      <FlatList
        data={jobs}
        keyExtractor={(item) => item._id}
        renderItem={({ item }) => (
          <View>
            <Text>{item.title} - {item.company}</Text>
            <Text>{item.location}</Text>
          </View>
        )}
      />
      <Button title="Logout" onPress={handleLogout} />
    </View>
  );
};

export default JobListings;
