import 'package:asnan_hub/models/case.dart';
import 'package:asnan_hub/models/user.dart';
import 'package:asnan_hub/services/auth_serrvice.dart';
import 'package:asnan_hub/widgets/case_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyCases extends StatefulWidget {
  const MyCases({super.key});

  @override
  State<MyCases> createState() => _MyCasesState();
}

class _MyCasesState extends State<MyCases> {
  UserModel? user;
  var authService = AuthService();
  bool loading = false;
  List<Case> patientCases = []; // ✅ initialize empty

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    setState(() => loading = true);

    await _fetchUser();
    await _fetchCases();

    if (!mounted) return;
    setState(() => loading = false);
  }

  Future<void> _fetchUser() async {
    try {
      user = await authService.getUserProfile();
      print("user is ${user?.name ?? 'null'}");
    } catch (e) {
      print("Error fetching user: $e");
    }
  }

  Future<void> _fetchCases() async {
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('cases')
        .where('patientId', isEqualTo: user!.uid)
        .get();

    patientCases =
        snapshot.docs.map((doc) => Case.fromFirestore(doc)).toList();
  }



  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'User profile not found',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Please make sure you have completed your profile',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    if (patientCases.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No cases found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Cases')),
      body: ListView.builder(
        itemCount: patientCases.length,
        itemBuilder: (context, index) {
          return CaseCard(caseItem: patientCases[index]);
        },
      ),
    );
  }
}
