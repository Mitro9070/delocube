import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/capsule_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'dart:io';

class FeedbackScreen extends StatefulWidget {
  final Capsule capsule;

  FeedbackScreen({required this.capsule});

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _reviewController = TextEditingController();
  bool _isLoading = false;
  List<File> _images = [];

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _submitFeedback() async {
    setState(() {
      _isLoading = true;
    });

    List<String> imageUrls = [];
    for (File image in _images) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('capsule_images')
          .child('${widget.capsule.id}_${DateTime.now().toIso8601String()}.jpg');
      await ref.putFile(image);
      final url = await ref.getDownloadURL();
      imageUrls.add(url);
    }

    await FirebaseFirestore.instance
        .collection('capsules')
        .doc(widget.capsule.id)
        .update({
      'reviews': FieldValue.arrayUnion([_reviewController.text]),
      'images': FieldValue.arrayUnion(imageUrls),
    });

    setState(() {
      _isLoading = false;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Обратная связь'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Оставьте отзыв о капсуле "${widget.capsule.name}"',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            CustomTextField(
              controller: _reviewController,
              hintText: 'Ваш отзыв',
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 10,
              children: _images.map((image) {
                return Image.file(image, width: 100, height: 100);
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Добавить фото'),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : CustomButton(
              text: 'Отправить отзыв',
              onPressed: _submitFeedback,
            ),
          ],
        ),
      ),
    );
  }
}