// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyAPITnF9On6Q55zDheO5C36G2ZtkptF_BI",
  authDomain: "ibuy-bym.firebaseapp.com",
  projectId: "ibuy-bym",
  storageBucket: "ibuy-bym.appspot.com",
  messagingSenderId: "212413751533",
  appId: "1:212413751533:web:72c9b5ca9327854d22ece4",
  measurementId: "G-ZWQ4PQ1CE0"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);
