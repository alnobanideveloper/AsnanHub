import 'package:flutter/material.dart';

enum UserRole {
  patient,
  student,
}

extension UserRoleExtension on UserRole {
  String get label {
    switch (this) {
      case UserRole.patient:
        return 'Patient';
      case UserRole.student:
        return 'Student';
    }
  }

  String get description {
    switch (this) {
      case UserRole.patient:
        return 'I need dental services';
      case UserRole.student:
        return 'I am a dental student';
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.patient:
        return Icons.person;
      case UserRole.student:
        return Icons.school;
    }
  }
}

