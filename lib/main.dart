import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import 'data/firebase_config.dart';
import 'data/task_repository.dart';
import 'ui/auth_page.dart';
import 'ui/task_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (const bool.fromEnvironment('ENABLE_TEST_SEMANTICS')) {
    SemanticsBinding.instance.ensureSemantics();
  }

  try {
    await initializeFirebase();
    runApp(const ClassroomTasksApp(home: _SessionGate()));
  } catch (error) {
    debugPrint('Firebase no se pudo iniciar: ${error.runtimeType}.');
    runApp(
      const ClassroomTasksApp(
        home: Scaffold(
          body: Center(child: Text('No se pudo iniciar Firebase.')),
        ),
      ),
    );
  }
}

class ClassroomTasksApp extends StatelessWidget {
  const ClassroomTasksApp({super.key, required this.home});

  final Widget home;

  @override
  Widget build(BuildContext context) {
    final colors = ColorScheme.fromSeed(seedColor: const Color(0xff17684c));
    return MaterialApp(
      title: 'Pendientes de clase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colors,
        scaffoldBackgroundColor: const Color(0xfff4f7f3),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          ),
        ),
      ),
      home: home,
    );
  }
}

class _SessionGate extends StatefulWidget {
  const _SessionGate();

  @override
  State<_SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<_SessionGate> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final Stream<User?> _session = _auth.authStateChanges();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _session,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('No se pudo recuperar la sesión.')),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
        if (user == null) return AuthPage(auth: _auth);
        return TaskListPage(
          key: ValueKey(user.uid),
          repository: FirestoreTaskRepository(
            FirebaseFirestore.instance,
            user.uid,
          ),
          signOut: _auth.signOut,
        );
      },
    );
  }
}
