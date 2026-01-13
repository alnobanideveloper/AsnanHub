import 'package:asnan_hub/pages/auth/role_selection.dart';
import 'package:asnan_hub/pages/doctor/doctor_main.dart';
import 'package:asnan_hub/pages/patient/patient_main.dart';
import 'package:asnan_hub/services/auth_serrvice.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Not logged in
        if (!snapshot.hasData) {
          return const RoleSelection();
        }

        // Logged in - check role and navigate accordingly
        return FutureBuilder(
          future: _checkUserRole(),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // If user is a student, show student main page
            if (roleSnapshot.data == true) {
              return const StudentMainPage();
            }

            // Otherwise, show patient main page
            return const MainPage();
          },
        );
      },
    );
  }

  Future<bool> _checkUserRole() async {
    final authService = AuthService();
    
    // First check if user is a student
    final studentProfile = await authService.getStudentProfile();
    if (studentProfile != null) {
      return true; // User is a student
    }

    // If not a student, check if user is a patient
    final patientProfile = await authService.getUserProfile();
    if (patientProfile != null) {
      return false; // User is a patient
    }

    // If neither found, default to patient (shouldn't happen in normal flow)
    return false;
  }
}
