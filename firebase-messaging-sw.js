importScripts('https://www.gstatic.com/firebasejs/7.6.0/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/7.6.0/firebase-messaging.js');

firebase.initializeApp({
    apiKey: 'AIzaSyAkmPm2DpVcfIg6uXMUuj7uLIxGd371qqM', // sostituisci con la tua chiave API
    authDomain: 'your-auth-domain', // sostituisci con il tuo dominio di autenticazione
    projectId: 'club-60d94', // sostituisci con il tuo ID progetto
    storageBucket: 'club-60d94.appspot.com', // sostituisci con il tuo bucket di storage
    messagingSenderId: 'your-messaging-sender-id', // sostituisci con il tuo ID mittente di messaggistica
    appId: 'your-app-id', // sostituisci con il tuo ID app
});

const messaging = firebase.messaging();