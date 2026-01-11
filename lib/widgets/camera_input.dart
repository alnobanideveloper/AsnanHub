import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraInput extends StatefulWidget {
  const CameraInput({super.key ,required this.onPickedImage});

  final void Function(File image) onPickedImage;

  @override
  State<CameraInput> createState() => _CameraInputState();
}

class _CameraInputState extends State<CameraInput> {
   File? _selectedFile;

  Future<void> _saveImage() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 600,
      imageQuality: 85,
    );

    if (pickedImage != null) {
      // Create File object and verify it exists
      final file = File(pickedImage.path);
      
      if (file.existsSync()) {
        setState(() {
          _selectedFile = file;
        });
        widget.onPickedImage(file);
      } else {
        print('Error: Picked image file does not exist at: ${pickedImage.path}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = TextButton.icon(
        icon: Icon(Icons.camera),
        onPressed: _saveImage, 
        label: Text("Take a photo" ,style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.white),));
    
    if(_selectedFile != null){
        content = InkWell(
          onTap: _saveImage,
          child: Image.file(
            _selectedFile! , 
            fit: BoxFit.cover ,
            width: double.infinity,
            height: double.infinity,
            ));
    }
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 1 , color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
    
        borderRadius: BorderRadius.circular(15)
      ),
      alignment: Alignment.center,
      height: 250 ,
      width: double.infinity,
      child: content
    );
  }
}