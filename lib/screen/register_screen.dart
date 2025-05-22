import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:event_app/screen/login_screen.dart';
import 'package:dio/dio.dart';
// import '../constants/pref_data.dart';
import '../constants/pref_data.dart';
import '../models/user.dart';
import '../providers/registration_provider.dart';
import '../providers/profile_provider.dart';
import 'policy_screen.dart';
import 'package:event_app/screen/eventmanager_screen.dart';
import 'package:event_app/screen/eventmember_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/apilist.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _isAgreed = false;
  String _selectedRole = 'manager';

  // Register User
  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate() || !_isAgreed) {
      if (!_isAgreed) {
        _showErrorSnackBar("Vui lòng đồng ý với điều khoản.");
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 10);
      dio.options.sendTimeout = const Duration(seconds: 10);

      final response = await dio.post(
        api_register,
        data: {
          'full_name': _fullNameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
          'phone': _phoneController.text.trim(),
          'role': _selectedRole == 'manager' ? 'eventmanager' : 'eventmember',
        },
        options: Options(
          followRedirects: false,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("🎉 Đăng ký thành công! Hãy đăng nhập.")),
        );
        // 👉 Chuyển sang màn hình đăng nhập
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        final message = response.data['message'] ?? 'Đăng ký thất bại';
        _showErrorSnackBar(message);
      }
    } catch (e) {
      _showErrorSnackBar("Lỗi kết nối: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Redirect to Home
  void _redirectToHome() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setBool('isLoggedIn', true);
    await pref.setString('userRole', _selectedRole);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => _selectedRole == 'Event Manager'
            ? const EventManagerHomeScreen()
            : const EventMemberScreen(),
      ),
      (route) => false,
    );
  }

  // Show SnackBar Error
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // User canceled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken != null) {
        // Gửi idToken lên backend để xác thực
        final response = await http.post(
          Uri.parse(api_loginGoogle),
          body: {'token': idToken},
        );

        if (response.statusCode == 200) {
          // Xử lý đăng nhập thành công (lưu token, chuyển hướng, ...)
          final data = json.decode(response.body);
          // Ví dụ: lưu token, chuyển hướng...
          // await PrefData.setToken(data['token']);
          // ...
        } else {
          // Xử lý lỗi
          _showErrorSnackBar('Google login failed');
        }
      }
    } catch (e) {
      _showErrorSnackBar('Google login error: $e');
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
          _showErrorSnackBar('Facebook login failed');
        }
      } else {
        _showErrorSnackBar('Facebook login cancelled');
      }
    } catch (e) {
      _showErrorSnackBar('Facebook login error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB993F4), // tím nhạt
              Color(0xFF8CA6DB), // xanh nhạt
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "to get started now!",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 16,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(_fullNameController, "Full Name",
                            "Please enter your full name"),
                        const SizedBox(height: 16),
                        _buildTextField(_emailController, "Email Address",
                            "Please enter your email",
                            isEmail: true),
                        const SizedBox(height: 16),
                        _buildTextField(_passwordController, "Password",
                            "Please enter your password",
                            isPassword: true),
                        const SizedBox(height: 16),
                        _buildTextField(_phoneController, "Phone",
                            "Please enter your phone number"),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedRole,
                          decoration: InputDecoration(
                            labelText: 'Role',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: const [
                            DropdownMenuItem(
                                value: 'manager', child: Text('Manager')),
                            DropdownMenuItem(
                                value: 'member', child: Text('Member')),
                          ],
                          onChanged: (value) =>
                              setState(() => _selectedRole = value!),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please select a role'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: _isAgreed,
                              onChanged: (value) =>
                                  setState(() => _isAgreed = value ?? false),
                            ),
                            Expanded(
                              child: Wrap(
                                children: [
                                  const Text("I agree to the"),
                                  GestureDetector(
                                    onTap: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const PolicyScreen())),
                                    child: const Text(
                                      " terms and policies ",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                  const Text("of the application."),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _registerUser,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: const Text(
                                    "Sign Up",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                        const SizedBox(height: 16),
                        Row(
                          children: const [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text("Or Sign Up with"),
                            ),
                            Expanded(child: Divider()),
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
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account?",
                      style: TextStyle(color: Colors.white),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen())),
                      child: const Text(
                        "Login Now",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
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
    );
  }

  // Helper: Build TextField
  Widget _buildTextField(
      TextEditingController controller, String label, String error,
      {bool isEmail = false, bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      obscureText: isPassword,
      validator: (value) => value == null || value.isEmpty ? error : null,
      textInputAction: TextInputAction.next,
      enableSuggestions: true,
      autocorrect: true,
    );
  }

  // Social button helper
  Widget _buildSocialButton(
      {required IconData icon,
      required Color color,
      required String label,
      required VoidCallback onTap}) {
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
