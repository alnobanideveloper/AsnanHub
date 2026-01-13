import 'package:flutter/material.dart';

class DoctorMyCases extends StatefulWidget {
  const DoctorMyCases({super.key});

  @override
  State<DoctorMyCases> createState() => _DoctorMyCasesState();
}

class _DoctorMyCasesState extends State<DoctorMyCases> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cases'),
      ),
      body: const Center(
        child: Text('My Cases - To be implemented'),
      ),
    );
  }
}

