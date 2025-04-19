import 'package:flutter/material.dart';
import '../screen/event_screen.dart';
import '../screen/blog_feed_screen.dart';
import '../screen/notifications_screen.dart';
import '../screen/settings_screen.dart';

class DrawerCustom extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String avatarUrl;

  const DrawerCustom({
    Key? key,
    required this.userName,
    required this.userEmail,
    required this.avatarUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.primaryColor,
                  theme.primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundImage: NetworkImage(avatarUrl),
                  backgroundColor: Colors.white,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userEmail,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            icon: Icons.event,
            title: 'Sự kiện',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EventScreen(),
              ),
            ),
          ),
          _buildMenuItem(
            icon: Icons.bookmark,
            title: 'Bài viết đã lưu',
            onTap: () => Navigator.pushNamed(context, '/blog_feed'),
          ),
          _buildMenuItem(
            icon: Icons.notifications,
            title: 'Thông báo',
            onTap: () => Navigator.pushNamed(context, '/notifications'),
          ),
          _buildMenuItem(
            icon: Icons.settings,
            title: 'Cài đặt',
            onTap: () => Navigator.pushNamed(context, '/settings'),
          ),
          const Spacer(),
          const Divider(),
          _buildMenuItem(
            icon: Icons.logout,
            title: 'Đăng xuất',
            onTap: () {
              // TODO: Gọi AuthProvider hoặc xử lý logout
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      hoverColor: const Color.fromARGB(255, 167, 142, 244).withOpacity(0.1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }
}
