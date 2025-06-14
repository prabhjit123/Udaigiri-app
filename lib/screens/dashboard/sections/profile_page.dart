import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isEditing = false;
  bool _isSaving = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user == null) return;
    // Load Firestore data
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    setState(() {
      nameController.text = user?.displayName ?? '';
      phoneController.text = doc.data()?['phone'] ?? '';
      genderController.text = doc.data()?['gender'] ?? '';
      dobController.text = doc.data()?['dob'] ?? '';
    });
  }

  Future<void> _pickImage() async {
    if (!_isEditing) return;
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _imageFile = File(image.path));
    }
  }

  Future<void> _saveProfile() async {
    if (user == null) return;
    setState(() => _isSaving = true);

    try {
      // 1. Upload image to Firebase Storage (if changed)
      String? photoUrl;
      if (_imageFile != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('user_profile_images/${user!.uid}.jpg');
        await ref.putFile(_imageFile!);
        photoUrl = await ref.getDownloadURL();
      }

      // 2. Update Firebase Auth profile
      await user!.updateDisplayName(nameController.text);
      if (photoUrl != null) await user!.updatePhotoURL(photoUrl);
      await user!.reload();

      // 3. Update Firestore user document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .set({
            'phone': phoneController.text,
            'gender': genderController.text,
            'dob': dobController.text,
            'photoUrl': photoUrl ?? user!.photoURL,
          }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.of(context).pop(); // Go back to previous screen (Dashboard)
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _loadUserData(); // Reset changes if canceled
        _imageFile = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF8F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF222B45),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _isSaving
              ? null
              : () {
                  Navigator.of(context).pop();
                },
        ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : _isEditing
                  ? IconButton(
                      icon: const Icon(Icons.save, color: Colors.white),
                      onPressed: _saveProfile,
                    )
                  : IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: _toggleEditing,
                    ),
        ],
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Container(
                  color: const Color(0xFF222B45),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 56,
                              backgroundColor: Colors.amberAccent,
                              backgroundImage: _imageFile != null
                                  ? FileImage(_imageFile!)
                                  : (user?.photoURL != null
                                      ? NetworkImage(user!.photoURL!)
                                      : null) as ImageProvider<Object>?,
                              child: _imageFile == null && user?.photoURL == null
                                  ? Text(
                                      (user?.displayName ?? 'U')[0].toUpperCase(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                        fontSize: 40,
                                      ),
                                    )
                                  : null,
                            ),
                            if (_isEditing)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF16A085),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 22),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildEditableField(
                          label: "Full Name",
                          controller: nameController,
                        ),
                        _divider(),
                        _buildEditableField(
                          label: "Phone Number",
                          controller: phoneController,
                        ),
                        _divider(),
                        _buildEditableField(
                          label: "Gender",
                          controller: genderController,
                        ),
                        _divider(),
                        _buildEditableField(
                          label: "Date of Birth",
                          controller: dobController,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8F9BB3),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        TextFormField(
          controller: controller,
          enabled: _isEditing,
          style: TextStyle(
            color: const Color(0xFF222B45),
            fontWeight: _isEditing ? FontWeight.normal : FontWeight.bold,
            fontSize: 16,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return const Divider(
      height: 28,
      thickness: 1,
      color: Color(0xFFEAF8F3),
    );
  }
}
