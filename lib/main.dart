
import 'package:asnan_hub/pages/auth/auth_gate.dart';
import 'package:asnan_hub/pages/auth/role_selection.dart';
import 'package:asnan_hub/theme/theme_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("🔥 Firebase connected successfully");
  } catch (e) {
    print("❌ Firebase connection failed: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AsnanHub',
      theme: asnanTheme,
      home: const RoleSelectionGate(),
    );
  }
}

class RoleSelectionGate extends StatelessWidget {
  const RoleSelectionGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Not logged in - show role selection
        if (!snapshot.hasData) {
          return const RoleSelection();
        }

        // Logged in - show auth gate (which will show main page)
        return const AuthGate();
      },
    );
  }
}
