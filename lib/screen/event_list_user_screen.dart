import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/event_user_list_provider.dart';
import 'package:event_app/screen/event_profile_screen.dart'; // Thêm import màn hình hồ sơ người dùng
import '../providers/theme_provider.dart';

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

class EventUserListScreen extends ConsumerWidget {
  final int eventId;
  final String eventTitle;

  const EventUserListScreen(
      {super.key, required this.eventId, required this.eventTitle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userListAsync = ref.watch(eventUserListProvider(eventId));
    final themeState = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thành viên: $eventTitle',
          style: TextStyle(color: themeState.appBarTextColor),
        ),
        backgroundColor: themeState.appBarColor,
      ),
      backgroundColor: themeState.backgroundColor,
      body: userListAsync.when(
        data: (users) => ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: themeState.primaryColor.withOpacity(0.2),
                  backgroundImage:
                      (user.user.photo != null && user.user.photo!.isNotEmpty)
                          ? NetworkImage(getFullAvatarUrl(user.user.photo!))
                              as ImageProvider
                          : const AssetImage("assets/default_avatar.png")
                              as ImageProvider,
                  onBackgroundImageError: (exception, stackTrace) {
                    print('Error loading user avatar: $exception');
                    // Fallback to default avatar on error
                  },
                ),
                title: Text(
                  user.user.fullName ?? 'Không rõ',
                  style: TextStyle(color: themeState.primaryTextColor),
                ),
                subtitle: Text(
                  '${user.user.email ?? 'Email chưa cập nhật'} | ${user.role.title ?? ''}',
                  style: TextStyle(color: themeState.secondaryTextColor),
                ),
                onTap: () {
                  // Khi ấn vào tên thành viên, điều hướng đến màn hình hồ sơ của họ
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EventUserProfileScreen(userId: user.user.id),
                    ),
                  );
                },
              ),
            );
          },
        ),
        loading: () => Center(
          child: CircularProgressIndicator(
            color: themeState.primaryColor,
          ),
        ),
        error: (err, _) => Center(
          child: Text(
            'Lỗi: $err',
            style: TextStyle(color: themeState.errorColor),
          ),
        ),
      ),
    );
  }
}
