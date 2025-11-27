importScripts('https://www.gstatic.com/firebasejs/10.13.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.13.2/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyBuILgQuSMPUbp3Bf1BLkmCrjm47SZ8vFw',
  appId: '1:860043783859:web:220b95113a270dc6be8ac6',
  messagingSenderId: '860043783859',
  projectId: 'sii-admision-uth',
  authDomain: 'sii-admision-uth.firebaseapp.com',
  storageBucket: 'sii-admision-uth.firebasestorage.app',
  measurementId: 'G-KC2RXG5BK0',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const notification = payload.notification ?? {};
  const title = notification.title ?? 'Nueva notificación';
  const options = {
    body: notification.body,
    icon: notification.icon ?? 'icons/Icon-192.png',
    data: payload.data,
    tag: notification.tag ?? payload.messageId,
  };

  self.registration.showNotification(title, options);
});
