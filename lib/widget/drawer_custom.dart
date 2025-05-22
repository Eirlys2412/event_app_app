import 'package:event_app/screen/ckeditor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screen/event_screen.dart';
import '../screen/blog_feed_screen.dart';
import '../screen/notifications_screen.dart';
import '../providers/profile_provider.dart';
import '../providers/theme_provider.dart';
import '../screen/qr_screen.dart';
import '../constants/apilist.dart';
import '../screen/my_blog_screen.dart';
import '../screen/my_event_screen.dart';

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

class DrawerCustom extends ConsumerWidget {
  const DrawerCustom({Key? key}) : super(key: key);

  String convertLocalhostUrl(String url) {
    if (url.contains('localhost') ||
        url.contains('127.0.0.1') ||
        url.contains('10.0.2.2')) {
      return url.replaceAll(
          RegExp(
              r'http://localhost:8000|http://127.0.0.1:8000|http://10.0.2.2:8000'),
          url_image);
    }
    return url;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final themeState = ref.watch(themeProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      backgroundColor: themeState.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  themeState.gradientStart,
                  themeState.gradientEnd,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: themeState.surfaceColor,
                  backgroundImage: (profileState.profile.photo != null &&
                          profileState.profile.photo!.isNotEmpty)
                      ? NetworkImage(
                          getFullAvatarUrl(profileState.profile.photo!))
                      : const AssetImage("assets/default_avatar.png"),
                ),
                const SizedBox(height: 12),
                Text(
                  profileState.profile.full_name != null &&
                          profileState.profile.full_name!.isNotEmpty
                      ? profileState.profile.full_name!
                      : "Chưa cập nhật",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: themeState.primaryTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  profileState.profile.email != null &&
                          profileState.profile.email!.isNotEmpty
                      ? profileState.profile.email!
                      : "Email chưa cập nhật",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: themeState.secondaryTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            context,
            ref,
            icon: Icons.event,
            title: 'Sự kiện của tôi',
            destination: const MyRegisteredEventsScreen(),
          ),
          _buildMenuItem(
            context,
            ref,
            icon: Icons.bookmark,
            title: 'Bài viết của tôi',
            destination: const MyBlogScreen(),
          ),
          // _buildMenuItem(
          //   context,
          //   ref,
          //   icon: Icons.notifications,
          //   title: 'Lịch sử thanh toán',
          //   destination: PaymentHistoryScreen(),
          // ),
          _buildMenuItem(
            context,
            ref,
            icon: Icons.settings,
            title: 'Cài đặt',
            routeName: '/settings',
          ),
          _buildMenuItem(
            context,
            ref,
            icon: Icons.qr_code,
            title: 'QR Code',
            destination: const CheckInQRPage(),
          ),
          const Spacer(),
          const Divider(color: Colors.black12),
          _buildMenuItem(
            context,
            ref,
            icon: Icons.logout,
            title: 'Đăng xuất',
            routeName: '/login',
            replace: true,
            isLogout: true,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String title,
    Widget? destination,
    String? routeName,
    bool replace = false,
    bool isLogout = false,
  }) {
    final themeState = ref.watch(themeProvider);

    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? Colors.red : themeState.primaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.red : themeState.primaryTextColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.pop(context); // đóng Drawer
        if (destination != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => destination),
          );
        } else if (routeName != null) {
          if (replace) {
            Navigator.pushReplacementNamed(context, routeName);
          } else {
            Navigator.pushNamed(context, routeName);
          }
        }
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      tileColor: Colors.transparent,
      hoverColor: themeState.primaryColor.withOpacity(0.1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }
}
