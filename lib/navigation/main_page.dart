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
import '../providers/theme_provider.dart';
import '../screen/qr_screen.dart';
import '../screen/home_screen.dart';
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
    final role = ref
        .read(userRoleProvider.notifier)
        .state; // Lấy role từ SharedPreferences

    if (role == 'eventmanager') {
      _pages = [
        const EventManagerHomeScreen(),
        const NotificationsScreen(),
        const SettingsScreen(),
        const EventScreen(),
      ];
    } else if (role == 'eventmember') {
      _pages = [
        const HomeScreen(),
        const EventScreen(),
        const BlogFeedScreen(),
        const NotificationsScreen(),
        const SettingsScreen(),
      ];
    } else {
      // Khi không có role hợp lệ, để _pages trống và chờ build hoàn tất
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _redirectToLogin();
      });
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
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);

    // Nếu dữ liệu chưa sẵn sàng, hiển thị loading indicator
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(
        cardTheme: CardTheme(
          color: themeState.themeMode == ThemeMode.dark
              ? const Color(0xFF1F1F1F)
              : Colors.white,
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.2),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  // Xây dựng thanh điều hướng dưới (BottomNavigationBar) tùy theo role
  Widget _buildBottomNavigationBar() {
    final themeState = ref.watch(themeProvider);

    if (_pages.length == 4) {
      return _buildEventManagerNavBar();
    } else {
      return _buildEventMemberNavBar();
    }
  }

  // BottomNavigationBar dành cho eventmanager
  Widget _buildEventManagerNavBar() {
    final themeState = ref.watch(themeProvider);

    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: themeState.navBarSelectedColor,
      unselectedItemColor: themeState.navBarUnselectedColor,
      backgroundColor: themeState.navBarColor,
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
    final themeState = ref.watch(themeProvider);

    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: themeState.navBarSelectedColor,
      unselectedItemColor: themeState.navBarUnselectedColor,
      backgroundColor: themeState.navBarColor,
      showSelectedLabels: true,
      showUnselectedLabels: false,
      elevation: 10,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Event'),
        BottomNavigationBarItem(icon: Icon(Icons.book_online), label: 'Blog'),
        BottomNavigationBarItem(
            icon: Icon(Icons.notifications), label: 'Thông báo'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Cài đặt'),
      ],
    );
  }
}
