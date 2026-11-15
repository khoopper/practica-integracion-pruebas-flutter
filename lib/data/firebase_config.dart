import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

const _demoOptions = FirebaseOptions(
  apiKey: 'demo-web-api-key',
  appId: '1:123456789012:web:a0a0a0a0a0a0a0a0a0a0a0',
  messagingSenderId: '123456789012',
  projectId: 'demo-practica-flutter',
  authDomain: 'demo-practica-flutter.firebaseapp.com',
);

FirebaseOptions _cloudOptions() {
  const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  const appId = String.fromEnvironment('FIREBASE_APP_ID');
  const senderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  const authDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
  if ([apiKey, appId, senderId, projectId, authDomain].any((v) => v.isEmpty)) {
    throw StateError('Faltan valores de la configuración web de Firebase.');
  }
  return const FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: senderId,
    projectId: projectId,
    authDomain: authDomain,
  );
}

Future<void> initializeFirebase() async {
  const useEmulators = bool.fromEnvironment(
    'FIREBASE_USE_EMULATORS',
    defaultValue: true,
  );

  await Firebase.initializeApp(
    options: useEmulators ? _demoOptions : _cloudOptions(),
  );
  if (!useEmulators) return;

  const host = String.fromEnvironment(
    'FIREBASE_EMULATOR_HOST',
    defaultValue: '127.0.0.1',
  );
  await FirebaseAuth.instance.useAuthEmulator(host, 9099);
  FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
}
