import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'edit_profile_screen.dart';
import '../constants/enum.dart';
import '../providers/profile_provider.dart';

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

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Thông tin cá nhân',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.primary, colorScheme.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: profileState.updateStatus == UpdateStatus.updating
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Ảnh đại diện với hiệu ứng bóng
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 55,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        backgroundImage: profileState.profile.photo.isNotEmpty
                            ? NetworkImage(getFullAvatarUrl(
                                profileState.profile.photo)) as ImageProvider
                            : const AssetImage("assets/default_avatar.png")
                                as ImageProvider,
                        onBackgroundImageError: (exception, stackTrace) {
                          print('Error loading avatar: $exception');
                          // Fallback to default avatar on error
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Họ tên và email
                  Text(
                    profileState.profile.full_name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    profileState.profile.email,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Divider(color: colorScheme.outline),
                  const SizedBox(height: 10),

                  // Các thông tin cá nhân
                  _buildProfileInfoTile(Icons.phone, 'Số điện thoại',
                      profileState.profile.phone, colorScheme),
                  _buildProfileInfoTile(Icons.location_on, 'Địa chỉ',
                      profileState.profile.address, colorScheme),
                  _buildProfileInfoTile(Icons.person, 'Tên đăng nhập',
                      profileState.profile.username, colorScheme),

                  const SizedBox(height: 30),

                  // Nút chỉnh sửa thông tin
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const EditProfileScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20),
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      textStyle: const TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Chỉnh sửa thông tin cá nhân'),
                  ),
                ],
              ),
            ),
    );
  }

  // Widget hiển thị thông tin với icon đẹp mắt
  Widget _buildProfileInfoTile(
      IconData icon, String label, String value, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: colorScheme.surface,
      child: ListTile(
        leading: Icon(icon, color: colorScheme.primary),
        title: Text(
          label,
          style: TextStyle(
              fontWeight: FontWeight.w600, color: colorScheme.onSurface),
        ),
        subtitle: Text(
          value,
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}
