import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:event_app/screen/login_screen.dart';
// import '../constants/pref_data.dart';
import '../constants/pref_data.dart';
import '../models/user.dart';
import '../providers/registration_provider.dart';
import '../providers/profile_provider.dart';
import 'policy_screen.dart';
import 'package:event_app/screen/eventmanager_screen.dart';
import 'package:event_app/screen/eventmember_screen.dart';

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
  void _registerUser() async {
    if (!_formKey.currentState!.validate() || !_isAgreed) {
      if (!_isAgreed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Please agree to the terms and policies.")),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final user = User(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      full_name: _fullNameController.text.trim(),
      phone: _phoneController.text.trim(),
      role: _selectedRole,
    );

    // Gọi hàm đăng ký
    await ref.read(registrationProvider.notifier).register(user);
    final registrationStatus = ref.watch(registrationProvider);

    if (registrationStatus == RegistrationStatus.success) {
      // Lấy token từ RegistrationNotifier
      final registrationNotifier = ref.read(registrationProvider.notifier);
      final token = registrationNotifier.token;

      if (token != null) {
        // Lưu trạng thái đăng nhập
        await PrefData.setToken(token);

        // Lấy thông tin user mới
        await ref.read(profileProvider.notifier).fetchProfile();

        // Chuyển hướng
        _redirectToHome();
      } else {
        _showErrorSnackBar("Failed to retrieve token.");
      }
    } else {
      String errorMsg = ref.read(registrationProvider.notifier).errorMessage ??
          "Registration failed.";
      _showErrorSnackBar(errorMsg);
    }

    setState(() {
      _isLoading = false;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          height: MediaQuery.of(context).size.height - 50,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  const Text(
                    "Sign up",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Create an account, it's free",
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  ),
                ],
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(_fullNameController, "Full Name",
                        "Please enter your full name"),
                    const SizedBox(height: 20),
                    _buildTextField(
                        _emailController, "Email", "Please enter your email",
                        isEmail: true),
                    const SizedBox(height: 20),
                    _buildTextField(_passwordController, "Password",
                        "Please enter your password",
                        isPassword: true),
                    const SizedBox(height: 20),
                    _buildTextField(_phoneController, "Phone",
                        "Please enter your phone number"),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        border: OutlineInputBorder(),
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
                    const SizedBox(height: 20),
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
                                      decoration: TextDecoration.underline),
                                ),
                              ),
                              const Text("of the application."),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _buildSignUpButton(),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen())),
                    child: const Text("Login"),
                  ),
                ],
              ),
            ],
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
      decoration:
          InputDecoration(labelText: label, border: const OutlineInputBorder()),
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      obscureText: isPassword,
      validator: (value) => value == null || value.isEmpty ? error : null,
    );
  }

  // Helper: Build SignUp Button
  Widget _buildSignUpButton() {
    return Container(
      padding: const EdgeInsets.only(top: 3, left: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        border: const Border(
          bottom: BorderSide(color: Colors.black),
          top: BorderSide(color: Colors.black),
          left: BorderSide(color: Colors.black),
          right: BorderSide(color: Colors.black),
        ),
      ),
      child: MaterialButton(
        minWidth: double.infinity,
        height: 60,
        onPressed: _registerUser,
        color: const Color.fromARGB(255, 50, 84, 255),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        child: const Text(
          "Sign up",
          style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
