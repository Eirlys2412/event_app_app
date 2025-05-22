import 'package:event_app/providers/user_provider.dart';
import 'package:event_app/screen/blog_feed_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'navigation/main_page.dart';
import 'providers/profile_provider.dart';
import 'providers/logout_provider.dart';
import 'providers/theme_provider.dart';
import 'repositories/auth_repository.dart';
import 'repositories/profile_repository.dart';
import 'screen/login_screen.dart';
import 'constants/pref_data.dart';
import 'screen/eventmanager_screen.dart';
import 'screen/eventmember_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    if (_initialized) return;

    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final role = prefs.getString('role');
    final token = prefs.getString('token');

    if (mounted && isLoggedIn && role != null && token != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        ref.read(userRoleProvider.notifier).state = role;
        ref.read(authStateProvider.notifier).setAuthenticated();

        // Load profile data
        final profileRepo = ProfileRepository();
        final profile = await profileRepo.getProfile();
        if (profile != null) {
          ref.read(profileProvider.notifier).state =
              ProfileState(profile: profile);
        }
      });
    }

    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Event App',
      themeMode: themeState.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: themeState.primaryColor,
        scaffoldBackgroundColor: themeState.backgroundColor,
        colorScheme: ColorScheme.light(
          primary: themeState.primaryColor,
          secondary: themeState.accentColor,
          surface: themeState.surfaceColor,
          background: themeState.backgroundColor,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: themeState.primaryTextColor,
          onBackground: themeState.primaryTextColor,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: themeState.appBarColor,
          foregroundColor: themeState.appBarTextColor,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: themeState.appBarTextColor,
          ),
          iconTheme: IconThemeData(color: themeState.appBarTextColor),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: themeState.navBarColor,
          selectedItemColor: themeState.navBarSelectedColor,
          unselectedItemColor: themeState.navBarUnselectedColor,
          selectedLabelStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          showSelectedLabels: true,
          showUnselectedLabels: true,
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: themeState.primaryTextColor,
          ),
          displayMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: themeState.primaryTextColor,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: themeState.bodyTextColor,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: themeState.bodyTextColor,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: themeState.buttonTextColor,
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            color: themeState.captionTextColor,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: themeState.buttonColor,
            foregroundColor: themeState.buttonTextColor,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: themeState.primaryColor,
        scaffoldBackgroundColor: themeState.backgroundColor,
        colorScheme: ColorScheme.dark(
          primary: themeState.primaryColor,
          secondary: themeState.accentColor,
          surface: themeState.surfaceColor,
          background: themeState.backgroundColor,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: themeState.primaryTextColor,
          onBackground: themeState.primaryTextColor,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: themeState.appBarColor,
          foregroundColor: themeState.appBarTextColor,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: themeState.appBarTextColor,
          ),
          iconTheme: IconThemeData(color: themeState.appBarTextColor),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: themeState.navBarColor,
          selectedItemColor: themeState.navBarSelectedColor,
          unselectedItemColor: themeState.navBarUnselectedColor,
          selectedLabelStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          showSelectedLabels: true,
          showUnselectedLabels: true,
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: themeState.primaryTextColor,
          ),
          displayMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: themeState.primaryTextColor,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: themeState.bodyTextColor,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: themeState.bodyTextColor,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: themeState.buttonTextColor,
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            color: themeState.captionTextColor,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: themeState.buttonColor,
            foregroundColor: themeState.buttonTextColor,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
      initialRoute:
          authState.status == AuthStatus.authenticated ? '/main' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(
            builder: (context) => authState.status == AuthStatus.authenticated
                ? const MainPage()
                : const LoginScreen(),
          );
        }
        return null;
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        );
      },
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
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      String? token = prefs.getString('token');
      String? role = prefs.getString('role');

      print('Debug - Login Status:');
      print('isLoggedIn: $isLoggedIn');
      print('token: $token');
      print('role: $role');

      if (isLoggedIn && token != null && role != null) {
        try {
          // Cập nhật trạng thái trong authProvider
          ref.read(authStateProvider.notifier).setAuthenticated();

          // Fetch profile nếu cần
          await ref.read(profileProvider.notifier).fetchProfile();

          // Điều hướng tới màn hình phù hợp dựa trên vai trò
          if (role == 'eventmanager' || role == 'eventmember') {
            // Lưu role vào provider để MainPage dùng
            ref.read(userRoleProvider.notifier).state = role;

            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const MainPage()),
              );
            }
          } else {
            print('Debug - Invalid role: $role');
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            }
          }
        } catch (e) {
          print('Debug - Error during authentication: $e');
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          }
        }
      } else {
        print('Debug - Not logged in or missing credentials');
        // Cập nhật trạng thái trong authProvider
        ref.read(authStateProvider.notifier).setUnauthenticated();

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    } catch (e) {
      print('Debug - Error in _checkLoginStatus: $e');
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
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
