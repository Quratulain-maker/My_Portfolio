// firebaseConfig.js
import { initializeApp } from "firebase/app";
import { getAuth, initializeAuth, getReactNativePersistence } from "firebase/auth";
import { getFirestore } from "firebase/firestore";
import AsyncStorage from "@react-native-async-storage/async-storage";

const firebaseConfig = {
  apiKey: "AIzaSyCKImGSt6DQO0dwOW--P5OT0LdOongSR1k",
  authDomain: "job-list-f5530.firebaseapp.com",
  projectId: "job-list-f5530",
  storageBucket: "job-list-f5530.firebasestorage.app",
  messagingSenderId: "290565658679",
  appId: "1:290565658679:web:466d2f134b8b33e2e5c7b2",
  measurementId: "G-XV2J862YHC"
};

// Initialize Firebase App
const app = initializeApp(firebaseConfig);

// Initialize Auth with AsyncStorage for persistence
const auth = initializeAuth(app, {
  persistence: getReactNativePersistence(AsyncStorage)
});

// Initialize Firestore
const db = getFirestore(app);

export { app, auth, db };
