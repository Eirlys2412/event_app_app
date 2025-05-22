import 'dart:io';
import 'package:flutter/material.dart';
import '../constants/enum.dart';
import '../constants/apilist.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/profile_provider.dart';

// Define the base URL for images
// Sử dụng IP của emulator
const String _baseUrl = 'http://10.0.2.2:8000/';

String getFullAvatarUrl(String? avatarPath) {
  if (avatarPath == null || avatarPath.isEmpty || avatarPath == 'null') {
    // URL ảnh mặc định nếu không có avatar
    return '${_baseUrl}storage/uploads/resources/default.png';
  }
  // Nếu đường dẫn đã là full URL, chỉ thay thế IP/localhost nếu cần
  if (avatarPath.startsWith('http')) {
    return avatarPath
        .replaceFirst('127.0.0.1', '10.0.2.2')
        .replaceFirst('localhost', '10.0.2.2');
  }
  // Nếu là đường dẫn tương đối bắt đầu bằng 'storage/', nối với base URL
  if (avatarPath.startsWith('storage/')) {
    return '$_baseUrl$avatarPath';
  }
  // Xử lý các trường hợp đường dẫn khác nếu có, hoặc mặc định
  return '${_baseUrl}storage/uploads/resources/$avatarPath'; // Giả định nó nằm trong resources nếu không có 'storage/'
}

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

      await profileNotifier.saveProfile().then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Color.fromARGB(255, 146, 157, 251),
          ),
        );
        Navigator.of(context).pop();
      }).catchError((err) {
        print('Lỗi chi tiết: $err');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải hồ sơ: $err'),
            backgroundColor: Colors.red,
          ),
        );
      });
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
                                  ? FileImage(_avatarFile!) as ImageProvider
                                  : (profileState.profile.photo.isNotEmpty
                                      ? NetworkImage(getFullAvatarUrl(
                                              profileState.profile.photo))
                                          as ImageProvider
                                      : const AssetImage(
                                              "assets/default_avatar.png")
                                          as ImageProvider) as ImageProvider,
                              onBackgroundImageError: (exception, stackTrace) {
                                print('Error loading avatar: $exception');
                                // Fallback to default avatar on error
                              },
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
