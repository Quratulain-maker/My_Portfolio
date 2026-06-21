import React from "react";
import { View, Text, Image, StyleSheet } from "react-native";

const MovieDetailScreen = ({ route }) => {
  const { movie } = route.params;

  return (
    <View style={styles.container}>
      <Image source={{ uri: `https://image.tmdb.org/t/p/w500${movie.poster_path}` }} style={styles.image} />
      <Text style={styles.title}>{movie.title}</Text>
      <Text style={styles.rating}>⭐ {movie.vote_average}</Text>
      <Text style={styles.description}>{movie.overview}</Text>
    </View>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: "#fff", padding: 10, alignItems: "center" },
  image: { width: 200, height: 300, borderRadius: 10 },
  title: { fontSize: 24, fontWeight: "bold", textAlign: "center", marginVertical: 10 },
  rating: { fontSize: 18, fontWeight: "bold", marginBottom: 10 },
  description: { fontSize: 16, textAlign: "center", paddingHorizontal: 20 },
});

export default MovieDetailScreen;
