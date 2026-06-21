import React, { useEffect, useState } from "react";
import { View, Text, FlatList, Image, TouchableOpacity, StyleSheet } from "react-native";
import { fetchDisneyMovies } from "../api";
import { storeMovies, getStoredMovies } from "../utils/storage";

const HomeScreen = ({ navigation }) => {
  const [movies, setMovies] = useState([]);

  useEffect(() => {
    loadMovies();
  }, []);

  const loadMovies = async () => {
    const storedMovies = await getStoredMovies();
    if (storedMovies.length > 0) {
      setMovies(storedMovies);
    } else {
      const fetchedMovies = await fetchDisneyMovies();
      setMovies(fetchedMovies);
      storeMovies(fetchedMovies);
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Disney Movies</Text>
      <FlatList
        data={movies}
        keyExtractor={(item) => item.id.toString()}
        renderItem={({ item }) => (
          <TouchableOpacity
            style={styles.card}
            onPress={() => navigation.navigate("MovieDetail", { movie: item })}
          >
            <Image source={{ uri: `https://image.tmdb.org/t/p/w500${item.poster_path}` }} style={styles.image} />
            <Text style={styles.movieTitle}>{item.title}</Text>
          </TouchableOpacity>
        )}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: "#fff", padding: 10 },
  title: { fontSize: 24, fontWeight: "bold", textAlign: "center", marginBottom: 10 },
  card: { marginBottom: 20, alignItems: "center" },
  image: { width: 150, height: 225, borderRadius: 10 },
  movieTitle: { fontSize: 18, fontWeight: "bold", marginTop: 5, textAlign: "center" },
});

export default HomeScreen;
