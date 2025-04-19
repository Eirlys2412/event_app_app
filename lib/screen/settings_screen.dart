import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/logout_provider.dart';
import '../screen/profile_screen.dart';
import '../screen/notifications_screen.dart';
import '../screen/policy_screen.dart';
import '../screen/login_screen.dart';
import '../widget/drawer_custom.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.watch(themeProvider);
    final isDarkMode = themeNotifier.isDarkMode;

    return Scaffold(
      drawer: const DrawerCustom(userName: '', userEmail: '', avatarUrl: ''),

      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu), // Nút 3 gạch
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: const Text('Cài Đặt'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Tài khoản", context),
              _buildSettingsTile(
                context,
                title: "Thông tin cá nhân",
                icon: Icons.person,
                onTap: () => _navigateTo(context, const ProfileScreen()),
              ),
              _buildSettingsTile(
                context,
                title: "Thông báo",
                icon: Icons.notifications,
                onTap: () => _navigateTo(context, const NotificationsScreen()),
              ),
              _buildSettingsTile(
                context,
                title: "Điều khoản & Chính sách",
                icon: Icons.policy,
                onTap: () => _navigateTo(context, const PolicyScreen()),
              ),
              const Divider(),
              _buildSectionTitle("Tùy chỉnh", context),
              _buildSettingsTile(
                context,
                title: "Chế độ tối",
                icon: Icons.dark_mode,
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: (value) =>
                      ref.read(themeProvider.notifier).toggleTheme(),
                ),
                onTap: null,
              ),
              const Divider(),
              _buildSectionTitle("Hỗ trợ", context),
              _buildSettingsTile(
                context,
                title: "Báo lỗi",
                icon: Icons.bug_report,
                onTap: () {},
              ),
              _buildSettingsTile(
                context,
                title: "Gửi phản hồi",
                icon: Icons.feedback,
                onTap: () {},
              ),
              const Divider(),
              _buildSectionTitle("Tài khoản", context),
              _buildSettingsTile(
                context,
                title: "Đăng xuất",
                icon: Icons.logout,
                iconColor: Colors.red,
                onTap: () => _handleLogout(context, ref),
              ),
              _buildSettingsTile(
                context,
                title: "Xoá tài khoản",
                icon: Icons.delete,
                iconColor: Colors.redAccent,
                onTap: () {},
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    Color? iconColor,
    required VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading:
          Icon(icon, color: iconColor ?? Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: trailing ??
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  void _handleLogout(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng Xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await ref.read(authProvider.notifier).logout();
      ref.read(profileProvider.notifier).resetProfile();

      if (ref.read(authProvider).status == AuthStatus.unauthenticated) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  ref.read(authProvider).errorMessage ?? 'Đăng xuất thất bại')),
        );
      }
    }
  }
}
