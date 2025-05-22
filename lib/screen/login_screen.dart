import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:event_app/constants/pref_data.dart';
import 'package:event_app/main.dart';
import '../constants/apilist.dart';
import '../providers/profile_provider.dart';
import '../repositories/auth_repository.dart';
import '../navigation/main_page.dart';
import 'register_screen.dart';
import '../constants/pref_data.dart';
import '../widgets/theme_button.dart';
import '../widgets/theme_selector.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import '../providers/logout_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends ConsumerStatefulWidget {
  final String? prefilledEmail;
  const LoginScreen({super.key, this.prefilledEmail});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool loading = false;
  bool rememberMe = false;

  @override
  @override
  void initState() {
    super.initState();
    if (widget.prefilledEmail != null) {
      _emailController.text = widget.prefilledEmail!;
    }
  }

  void _loginUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      loading = true;
    });

    // Gọi AuthRepository để xử lý đăng nhập
    try {
      bool isLoggedIn = await AuthRepository().login(
        _emailController.text,
        _passwordController.text,
      );

      if (isLoggedIn) {
        // Lấy token từ SharedPreferences
        SharedPreferences pref = await SharedPreferences.getInstance();
        String? token = await PrefData.getToken(); // Thay vì 'token'
        String? role = await PrefData.getRole(); // Thay vì 'role'

        if (token != null &&
            token.isNotEmpty &&
            role != null &&
            role.isNotEmpty) {
          // Lấy thông tin người dùng sau khi đăng nhập thành công
          await ref
              .read(profileProvider.notifier)
              .fetchProfile(); // Lưu ý sử dụng `ref.read`

          // Sau khi đã lấy thông tin người dùng, thực hiện chuyển hướng
          _saveAndRedirectToHome(token, role);
        } else {
          setState(() {
            loading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Failed to retrieve token. Please try again.')),
          );
        }
      } else {
        setState(() {
          loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Login failed. Please check your credentials.')),
        );
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  void _saveAndRedirectToHome(String token, String role) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setBool('isLoggedIn', true);
    await pref.setString('token', token);
    await pref.setString('role', role);

    // Chờ cho frame hiện tại kết thúc rồi mới điều hướng
    if (!mounted) return;

    ref.read(userRoleProvider.notifier).state = role;
    ref.read(authStateProvider.notifier).setAuthenticated();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MainPage()),
      (route) => false,
    );
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId:
            '408011482773-7rijo0ur6fpulekb1allifq8poc91o37.apps.googleusercontent.com',
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return; // User canceled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken != null) {
        final response = await http.post(
          Uri.parse(api_loginGoogle),
          body: {'token': idToken},
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          // ✔️ Lưu token và role
          //await PrefData.setToken(data['token']);
          await PrefData.setRole(data['role'] ?? 'member');
          await PrefData.setToken(data['access_token']);

          // ✔️ Lấy thông tin profile nếu cần
          await ref.read(profileProvider.notifier).fetchProfile();

          // ✔️ Chuyển hướng về trang chính
          _saveAndRedirectToHome(data['token'], data['role']);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Google login failed')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google login error: $e')),
      );
    }
  }

  Future<void> _signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final accessToken = result.accessToken!.tokenString;
        // Gửi accessToken lên backend để xác thực
        // (Bạn cần hỏi backend endpoint, ví dụ: api_loginFacebook)
        final response = await http.post(
          Uri.parse('YOUR_FACEBOOK_LOGIN_API'),
          body: {'token': accessToken},
        );
        if (response.statusCode == 200) {
          // Xử lý đăng nhập thành công
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Facebook login failed')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Facebook login cancelled')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Facebook login error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ref.watch(themeProvider);
    final currentTheme = themeNotifier.themePresets.entries.firstWhere(
      (entry) => entry.value[0] == themeNotifier.gradientStart,
      orElse: () => themeNotifier.themePresets.entries.first,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.palette, color: Colors.white),
            itemBuilder: (context) =>
                themeNotifier.themePresets.keys.map((themeName) {
              return PopupMenuItem<String>(
                value: themeName,
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            themeNotifier.themePresets[themeName]![0],
                            themeNotifier.themePresets[themeName]![1],
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(themeName),
                  ],
                ),
              );
            }).toList(),
            onSelected: (themeName) {
              ref.read(themeProvider.notifier).changeTheme(themeName);
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              themeNotifier.gradientStart,
              themeNotifier.gradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Background stars/particles can be added here
              Positioned(
                top: 0,
                right: 0,
                child: Row(
                  children: const [
                    ThemeButton(),
                    ThemeSelector(),
                  ],
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 32),
                              TextFormField(
                                controller: _emailController,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  labelStyle:
                                      const TextStyle(color: Colors.white70),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white.withOpacity(0.5)),
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  suffixIcon: const Icon(Icons.email,
                                      color: Colors.white70),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              TextFormField(
                                controller: _passwordController,
                                style: const TextStyle(color: Colors.white),
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  labelStyle:
                                      const TextStyle(color: Colors.white70),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white.withOpacity(0.5)),
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  suffixIcon: const Icon(Icons.lock,
                                      color: Colors.white70),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: rememberMe,
                                        onChanged: (value) {
                                          setState(() {
                                            rememberMe = value ?? false;
                                          });
                                        },
                                        fillColor: MaterialStateProperty.all(
                                            Colors.white),
                                        checkColor: const Color(0xFF2A1B5D),
                                      ),
                                      const Text(
                                        'Remember Me',
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Handle forgot password
                                    },
                                    child: const Text(
                                      'FORGET PASSWORD',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: loading ? null : _loginUser,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                  child: loading
                                      ? const CircularProgressIndicator()
                                      : const Text(
                                          'Log In',
                                          style: TextStyle(
                                            color: Color(0xFF2A1B5D),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: const [
                                  Expanded(
                                      child: Divider(color: Colors.white70)),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8),
                                    child: Text("Or Login with",
                                        style:
                                            TextStyle(color: Colors.white70)),
                                  ),
                                  Expanded(
                                      child: Divider(color: Colors.white70)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildSocialButton(
                                    icon: Icons.g_mobiledata,
                                    color: Colors.red,
                                    label: "Google",
                                    onTap: _signInWithGoogle,
                                  ),
                                  const SizedBox(width: 16),
                                  _buildSocialButton(
                                    icon: Icons.facebook,
                                    color: Colors.blue,
                                    label: "Facebook",
                                    onTap: _signInWithFacebook,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Don't have a account ",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const SignupPage(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'REGISTER',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeButton(String imagePath) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: color, size: 28),
      label: Text(label, style: const TextStyle(color: Colors.black)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
