import AsyncStorage from "@react-native-async-storage/async-storage";

export const storeMovies = async (movies) => {
  try {
    await AsyncStorage.setItem("disneyMovies", JSON.stringify(movies));
  } catch (error) {
    console.error("Error storing movies:", error);
  }
};

export const getStoredMovies = async () => {
  try {
    const movies = await AsyncStorage.getItem("disneyMovies");
    return movies ? JSON.parse(movies) : [];
  } catch (error) {
    console.error("Error retrieving movies:", error);
    return [];
  }
};
