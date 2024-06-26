// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyCQBCK6Jw0Vt6Tn3cXoy52XCr-mQ8nYm8M",
  authDomain: "lista-de-compras-app-ad9fe.firebaseapp.com",
  projectId: "lista-de-compras-app-ad9fe",
  storageBucket: "lista-de-compras-app-ad9fe.appspot.com",
  messagingSenderId: "635604688519",
  appId: "1:635604688519:web:f95976c96ad5325e97e222",
  measurementId: "G-CJY82DC0EK"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);