import 'dart:async';
import 'dart:io';

import 'package:asnan_hub/extensions/snackbar_extension.dart';
import 'package:asnan_hub/models/case.dart';
import 'package:asnan_hub/services/auth_serrvice.dart';
import 'package:asnan_hub/widgets/camera_input.dart';
import 'package:asnan_hub/widgets/case_types_grid.dart';
import 'package:asnan_hub/widgets/date_picker_field.dart';
import 'package:asnan_hub/widgets/description_field.dart';
import 'package:asnan_hub/widgets/time_shift_selector.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AddCase extends StatefulWidget {
  const AddCase({super.key});

  @override
  State<AddCase> createState() => _AddCaseState();
}

class _AddCaseState extends State<AddCase> {


  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  CaseType? _selectedCaseType;
  DateTime? _selectedDate;
  bool loading = false;
  var authService = AuthService();
  TimeShift? _selectedShift;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  
  Future<String?> uploadImage(File imageFile) async {
    try {
      print('Starting image upload to Firebase Storage...');
      print('File path: ${imageFile.path}');
      
      // Verify file exists before uploading
      if (!imageFile.existsSync()) {
        print('Error: File does not exist at path: ${imageFile.path}');
        return null;
      }
      
      // Get file size for logging
      final fileSize = await imageFile.length();
      print('File size: $fileSize bytes');
      
      if (fileSize == 0) {
        print('Error: File is empty');
        return null;
      }
      
      // Read file as bytes to avoid path issues
      print('Reading file bytes...');
      final fileBytes = await imageFile.readAsBytes();
      print('File bytes read: ${fileBytes.length} bytes');
      
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('cases')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      // Upload using putData instead of putFile to avoid path issues
      print('Uploading to Firebase Storage...');
      final uploadTask = storageRef.putData(
        fileBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      
      // Listen to upload progress
      uploadTask.snapshotEvents.listen((taskSnapshot) {
        final progress = (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes) * 100;
        print('Upload progress: ${progress.toStringAsFixed(2)}%');
      });
      
      // Wait for upload to complete with timeout
      print('Waiting for upload to complete...');
      final snapshot = await uploadTask.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('Upload timeout after 30 seconds');
          throw TimeoutException('Upload timeout', const Duration(seconds: 30));
        },
      );
      
      print('Upload completed: ${snapshot.bytesTransferred} bytes');

      // Get URL with timeout
      print('Getting download URL...');
      String downloadUrl = await snapshot.ref.getDownloadURL().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('Get URL timeout');
          throw TimeoutException('Get URL timeout', const Duration(seconds: 10));
        },
      );
      print('Download URL obtained: $downloadUrl');
      
      return downloadUrl;
    } catch (ex) {
      print("Image upload failed: $ex");
      return null; // Return null on error
    }
  }

  Future<void> _submitCase() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCaseType == null) {
      context.showErrorSnackBar('Please select a problem type', Colors.red);
      return;
    }

    if (_selectedImage == null) {
      context.showErrorSnackBar('Please take a photo', Colors.red);
      return;
    }

    if (_selectedDate == null) {
      context.showErrorSnackBar('Please select a preferred date', Colors.red);
      return;
    }

    if (_selectedShift == null) {
      context.showErrorSnackBar('Please select a preferred time', Colors.red);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          context.showErrorSnackBar('Please login first', Colors.red);
        }
        return;
      }

      print('Starting case submission...');

      // Upload image to Firebase Storage and get URL
      String? imageUrl = await uploadImage(_selectedImage!);
      
      if (imageUrl == null) {
        if (mounted) {
          context.showErrorSnackBar(
            'Failed to upload image. Please try again.',
            Colors.red,
          );
        }
        return;
      }

      print('Image uploaded successfully, saving to Firestore...');

      final newCase = Case(
        type: _selectedCaseType!,
        
        shift: _selectedShift!,
        imageUrl: imageUrl,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        state: CaseState.pending,
        date: _selectedDate!,
      );

      // Save to Firestore
      await FirebaseFirestore.instance.collection('cases').add({
        'type': _selectedCaseType!.name,
        'shift': _selectedShift!.name,
        'imageUrl': imageUrl,
        'description': newCase.description,
        'state': CaseState.pending.name,
        'date': Timestamp.fromDate(_selectedDate!),
        'patientId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('Case saved to Firestore successfully');

      if (!mounted) return;

      context.showErrorSnackBar('Case submitted successfully!', Colors.green);

      // Reset form
      setState(() {
        _selectedCaseType = null;
        _selectedImage = null;
        _selectedDate = null;
        _selectedShift = null;
        _descriptionController.clear();
      });
    } catch (e) {
      print('Error submitting case: $e');
      if (!mounted) return;
      context.showErrorSnackBar('Error: ${e.toString()}', Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Case'),
      ),
      body:  Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Problem Type Section
              Text(
                'Problem Type *',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(color: scheme.primary),
              ),
              const SizedBox(height: 12),
              CaseTypesGrid(
                selectedType: _selectedCaseType,
                onSelected: (CaseType type) {
                  setState(() => _selectedCaseType = type);
                },
              ),
              const SizedBox(height: 24),

              // Description Section
              DescriptionField(
                
                controller: _descriptionController,
                label: 'Problem Description',
                hint:
                    'Explain your problem in detail... Example: I suffer from pain in the lower left molar since a week',
                
                helperText:
                    'The clearer the description, the more accurate the diagnosis',
                isOptional: true,
              ),
              const SizedBox(height: 24),

              // Photos Section
              Text(
                'Photos *',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(color: scheme.primary),
              ),
              const SizedBox(height: 8),
              CameraInput(
                onPickedImage: (image) {
                  setState(() => _selectedImage = image);
                },
              ),
              const SizedBox(height: 24),

              // Preferred Date
              DatePickerField(
                selectedDate: _selectedDate,
                onDateSelected: (date) {
                  setState(() => _selectedDate = date);
                },
                label: 'Preferred Date *',
              ),
              const SizedBox(height: 24),

              // Preferred Time
              TimeShiftSelector(
                selectedShift: _selectedShift,
                onShiftSelected: (shift) {
                  setState(() => _selectedShift = shift);
                },
                label: 'Preferred Time *',
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitCase,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.upload),
                  label: Text(
                    _isSubmitting ? 'Submitting...' : 'Submit Case',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}