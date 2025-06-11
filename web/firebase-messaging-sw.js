// Scripts for firebase and firebase messaging
importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-messaging-compat.js');

// Initialize the Firebase app in the service worker
// "Default" Firebase app is used if no name is provided
firebase.initializeApp({
  apiKey: "AIzaSyDz6d1z4BnINppGC6_5OsxwL570vWSMdbU",
  authDomain: "cure-app-ddfd9.firebaseapp.com",
  projectId: "cure-app-ddfd9",
  storageBucket: "cure-app-ddfd9.appspot.com",
  messagingSenderId: "997897806633",
  appId: "1:997897806633:web:3a1a01e9d1082bc59acd38",
  measurementId: "G-36LW8FDP2P"
});

// Retrieve an instance of Firebase Messaging so that it can handle background messages.
const messaging = firebase.messaging();

// (Optional) You can add a background message handler here if you need to
messaging.onBackgroundMessage((payload) => {
  console.log(
    '[firebase-messaging-sw.js] Received background message ',
    payload,
  );
  // Customize notification here
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/favicon.png' // You can change this to your app's icon
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});