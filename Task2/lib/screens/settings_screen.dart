import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hotuanphuoc_2224802010872_lab4/controllers/user_service.dart';
import 'package:image_picker/image_picker.dart';



class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final UserService _userService = UserService();

  final TextEditingController nicknameController =
      TextEditingController();

  final TextEditingController aboutController =
      TextEditingController();

  File? imageFile;

  String photoUrl = "";

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    var data = await _userService.getUserInfo();

    if (data != null) {
      nicknameController.text = data['nickname'] ?? '';
      aboutController.text = data['aboutMe'] ?? '';
      photoUrl = data['photoUrl'] ?? '';

      setState(() {});
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final picked =
        await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  Future<void> saveProfile() async {
    setState(() {
      isLoading = true;
    });

    try {
      String imageUrl = photoUrl;

      if (imageFile != null) {
        imageUrl =
            await _userService.uploadAvatar(imageFile!);
      }

      await _userService.updateProfile(
        nickname: nicknameController.text.trim(),
        aboutMe: aboutController.text.trim(),
        photoUrl: imageUrl,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Update success"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: imageFile != null
                    ? FileImage(imageFile!)
                    : (photoUrl.isNotEmpty
                            ? NetworkImage(photoUrl)
                            : null)
                        as ImageProvider?,
                child: photoUrl.isEmpty && imageFile == null
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: nicknameController,
              decoration: const InputDecoration(
                labelText: "Nickname",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: aboutController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "About Me",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveProfile,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Save"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}