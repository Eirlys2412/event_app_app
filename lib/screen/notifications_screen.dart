import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widget/drawer_custom.dart';
import '../widgets/theme_button.dart';
import '../widgets/theme_selector.dart';
import '../providers/theme_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return Scaffold(
      drawer: DrawerCustom(),
      backgroundColor: themeState.backgroundColor,
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        backgroundColor: themeState.appBarColor,
        title: Text(
          'Thông báo',
          style: TextStyle(color: themeState.primaryTextColor),
        ),
        centerTitle: true,
        actions: const [
          ThemeButton(),
          ThemeSelector(),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10, // Số lượng thông báo mẫu
        itemBuilder: (context, index) {
          return Card(
            color: Colors.white, // Giữ màu trắng cố định cho card
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue[100],
                child: const Icon(Icons.notifications, color: Colors.blue),
              ),
              title: Text(
                'Thông báo ${index + 1}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              subtitle: Text(
                'Nội dung thông báo ${index + 1}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              trailing: Text(
                '10:00',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
