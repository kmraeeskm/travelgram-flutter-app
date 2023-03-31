// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:io';
import 'package:boxicons/boxicons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:travelgram/screen/home_screen.dart';
import 'package:travelgram/utils/button_widget.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

class AddPost extends StatefulWidget {
  const AddPost({super.key});

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  final TextEditingController _descController = TextEditingController();

  PlatformFile? pickedFile;
  UploadTask? task;
  File? file;
  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result == null) return;
    final path = result.files.first;

    setState(() => pickedFile = path);
  }

  Future uploadFile() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser!;
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final file = File(pickedFile!.path!);
    final destination = 'posts/${pickedFile!.name}';

    task = FirebaseApi.uploadFile(destination, file);
    setState(() {});

    final snapshot = await task!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();

    String postId = const Uuid().v1();
    try {
      _firestore.collection('posts').doc(postId).set({
        'postId': postId,
        'uId': user.uid,
        'imageUrl': urlDownload,
        'location': 'location',
        'time': DateTime.now(),
        'description': _descController.text,
      });
    } catch (e) {
      print(e.toString());
    }

    try {
      _firestore.collection('users').doc(user.uid).update({
        'posts': FieldValue.arrayUnion([postId])
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileName =
        pickedFile != null ? basename(pickedFile!.name) : 'No File Selected';
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Travelgram',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          AppBarIcon(
            iconData: Boxicons.bx_bell,
            color: Colors.white,
            iconColor: Colors.black,
          ),
          SizedBox(
            width: 16,
          ),
          AppBarIcon(
            iconData: Boxicons.bx_message,
            color: Colors.white,
            iconColor: Colors.black,
          ),
          SizedBox(
            width: 16,
          ),
        ],
      ),
      body: Column(
        children: [
          if (pickedFile == null)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image(
                image: AssetImage('assets/upload_image.gif'),
              ),
            ),
          if (pickedFile != null)
            SizedBox(
              height: 300,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(
                  File(
                    pickedFile!.path!,
                  ),
                ),
              ),
            ),
          if (pickedFile == null)
            ButtonWidget(
              text: 'Select File',
              icon: Icons.attach_file,
              onClicked: selectFile,
            ),
          if (pickedFile != null)
            ButtonWidget(
              text: 'Replace File',
              icon: Icons.attach_file,
              onClicked: selectFile,
            ),
          const SizedBox(height: 8),
          TextField(
            controller: _descController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              hintText: 'Say something about the place',
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () {
              uploadFile();
            },
            child: Text('upload'),
          ),
        ],
      ),
    );
  }
}

class FirebaseApi {
  static UploadTask? uploadFile(String destination, File file) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);

      return ref.putFile(file);
    } on FirebaseException catch (e) {
      print(e);
    }
  }
}
