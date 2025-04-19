import 'dart:io';
import 'package:flutter/material.dart';
import '../constants/enum.dart';
import '../constants/apilist.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _usernameController = TextEditingController();
  File? _avatarFile;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider).profile;
    _fullNameController.text = profile.full_name;
    _addressController.text = profile.address;
    _usernameController.text = profile.username;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _addressController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatarFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final profileNotifier = ref.read(profileProvider.notifier);
      profileNotifier.updatefull_name(_fullNameController.text);
      profileNotifier.updateAddress(_addressController.text);
      profileNotifier.updateUsername(_usernameController.text);

      if (_avatarFile != null) {
        await profileNotifier.uploadAndUpdatePhoto(_avatarFile!);
      }

      await profileNotifier.saveProfile();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Color.fromARGB(255, 146, 157, 251),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Chỉnh sửa thông tin cá nhân'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: profileState.updateStatus == UpdateStatus.updating
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 55,
                              backgroundColor: colorScheme.secondaryContainer,
                              backgroundImage: _avatarFile != null
                                  ? FileImage(_avatarFile!)
                                  : (profileState.profile.photo
                                          .startsWith('http')
                                      ? NetworkImage(profileState.profile.photo)
                                      : NetworkImage(url_image +
                                          profileState
                                              .profile.photo)) as ImageProvider,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: colorScheme.onPrimary, width: 2),
                                ),
                                child: const Icon(Icons.camera_alt,
                                    size: 20, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(_fullNameController, 'Họ và tên',
                        Icons.person, colorScheme),
                    const SizedBox(height: 20),
                    _buildTextField(_addressController, 'Địa chỉ',
                        Icons.location_on, colorScheme),
                    const SizedBox(height: 20),
                    _buildTextField(_usernameController, 'Tên đăng nhập',
                        Icons.account_circle, colorScheme),
                    const SizedBox(height: 30),
                    _buildSaveButton(colorScheme),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSaveButton(ColorScheme colorScheme) {
    return Center(
      child: GestureDetector(
        onTap: _saveProfile,
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [colorScheme.primary, colorScheme.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'Lưu thông tin',
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon, ColorScheme colorScheme) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: colorScheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập $label';
        }
        return null;
      },
    );
  }
}
