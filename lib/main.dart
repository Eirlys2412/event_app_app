import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'navigation/main_page.dart';
import 'providers/profile_provider.dart';
import 'providers/logout_provider.dart';
import 'providers/theme_provider.dart';
import 'repositories/auth_repository.dart';
import 'screen/login_screen.dart';
import 'constants/pref_data.dart';
import 'screen/eventmanager_screen.dart';
import 'screen/eventmember_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.watch(themeProvider);

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Event App',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          primarySwatch: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        themeMode: themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/main': (context) => const MainPage(),
        } // Đặt SplashScreen làm màn hình khởi chạy
        );
  }
}

// Provider để quản lý trạng thái đăng nhập
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(AuthRepository());
});

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String? token = prefs.getString('token');
    String? role =
        prefs.getString('role'); // Lấy vai trò người dùng từ SharedPreferences

    print('isLoggedIn: $isLoggedIn');
    print('token: $token');
    print('role: $role'); // In ra vai trò để kiểm tra

    if (isLoggedIn && token != null && role != null) {
      // Cập nhật trạng thái trong authProvider
      ref.read(authStateProvider.notifier).setAuthenticated();

      // Fetch profile nếu cần
      await ref.read(profileProvider.notifier).fetchProfile();

      // Điều hướng tới màn hình phù hợp dựa trên vai trò
      if (role == 'eventmanager') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) => const EventManagerHomeScreen()),
        );
      } else if (role == 'eventmember') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const EventMemberScreen()),
        );
      } else {
        // Điều hướng về Login nếu không có vai trò
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } else {
      // Cập nhật trạng thái trong authProvider
      ref.read(authStateProvider.notifier).setUnauthenticated();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
