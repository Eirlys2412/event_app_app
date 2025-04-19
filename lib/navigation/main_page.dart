import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screen/eventmanager_screen.dart';
import '../screen/eventmember_screen.dart';
import '../screen/notifications_screen.dart';
import '../screen/settings_screen.dart';
import '../screen/blog_feed_screen.dart';
import '../screen/event_screen.dart';
import '../providers/user_provider.dart';
import '../screen/qr_screen.dart';

// Giúp thao tác với SharedPreferences

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  int _currentIndex = 0;
  List<Widget> _pages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePagesBasedOnRole();
  }

  // Hàm khởi tạo các trang tùy theo role người dùng
  Future<void> _initializePagesBasedOnRole() async {
    final role = await ref
        .read(userRoleProvider.notifier)
        .state; // Lấy role từ SharedPreferences

    switch (role) {
      case 'eventmanager':
        _pages = [
          const EventManagerHomeScreen(),
          const NotificationsScreen(),
          const SettingsScreen(),
        ];
        break;
      case 'eventmember':
        _pages = [
          // const EventMemberScreen(),
          const BlogFeedScreen(),
          const EventScreen(),
          const CheckInQRPage(),
          const NotificationsScreen(),
          const SettingsScreen(),
        ];
        break;
      default:
        _redirectToLogin();
        return;
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Chuyển hướng người dùng đến màn hình đăng nhập nếu không có role hợp lệ
  void _redirectToLogin() {
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Nếu dữ liệu chưa sẵn sàng, hiển thị loading indicator
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Xây dựng thanh điều hướng dưới (BottomNavigationBar) tùy theo role
  Widget _buildBottomNavigationBar() {
    if (_pages.length == 3) {
      return _buildEventManagerNavBar();
    } else {
      return _buildEventMemberNavBar();
    }
  }

  // BottomNavigationBar dành cho eventmanager
  Widget _buildEventManagerNavBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF6D3CC9),
      unselectedItemColor: Colors.grey[500],
      backgroundColor: Colors.white,
      showSelectedLabels: true,
      showUnselectedLabels: false,
      elevation: 10,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Quản lý'),
        BottomNavigationBarItem(
            icon: Icon(Icons.notifications), label: 'Thông báo'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Cài đặt'),
        BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Event'),
      ],
    );
  }

  // BottomNavigationBar dành cho eventmember
  Widget _buildEventMemberNavBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF6D3CC9),
      unselectedItemColor: Colors.grey[500],
      backgroundColor: Colors.white,
      showSelectedLabels: true,
      showUnselectedLabels: false,
      elevation: 10,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.book_online), label: 'Blog'),
        BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Event'),
        BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: 'QR Code'),
        BottomNavigationBarItem(
            icon: Icon(Icons.notifications), label: 'Thông báo'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Cài đặt'),
      ],
    );
  }
}
