import axios from "axios";

const API_KEY = "f37b05c99516c1b77d1cb5b887100b9f";
const BASE_URL = "https://api.themoviedb.org/3";

export const fetchDisneyMovies = async () => {
  try {
    const response = await axios.get(
      `${BASE_URL}/discover/movie?api_key=${API_KEY}&with_companies=2`
    );
    return response.data.results;
  } catch (error) {
    console.error("Error fetching movies:", error);
    return [];
  }
};
