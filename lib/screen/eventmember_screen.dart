import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../navigation/main_page.dart';
import '../../screen/register_screen.dart';
import '../providers/eventmember_provider.dart';
import '../providers/eventmanager_provider.dart';

class EventMemberScreen extends ConsumerStatefulWidget {
  const EventMemberScreen({super.key});

  @override
  ConsumerState<EventMemberScreen> createState() => _EventMemberScreenState();
}

class _EventMemberScreenState extends ConsumerState<EventMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _slugController = TextEditingController();

  int userId = 0;
  int eventId = 0;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  @override
  void dispose() {
    _slugController.dispose();
    super.dispose();
  }

  // Hàm tải thông tin userId từ SharedPreferences
  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getInt('userId');
    debugPrint('Saved userId: $savedUserId');

    if (savedUserId == null || savedUserId <= 0) {
      if (mounted) {
        _showErrorAndRedirect();
      }
      return;
    }

    setState(() {
      userId = savedUserId;
    });
  }

  // Hiển thị thông báo lỗi và chuyển hướng đến màn hình đăng ký
  void _showErrorAndRedirect() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('User ID not found. Please register again.'),
        backgroundColor: Colors.red,
      ),
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SignupPage()),
    );
  }

  // Hàm xử lý submit form
  Future<void> _submitForm(WidgetRef ref) async {
    if (!_formKey.currentState!.validate()) return;

    if (userId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid user ID.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Hiển thị dialog loading khi đang xử lý
    _showLoadingDialog();

    try {
      final eventMemberNotifier =
          ref.read(EventMemberRepositoryProvider.notifier);
      await eventMemberNotifier.createEventMember(
        userId: userId,
        eventId: eventId,
      );

      if (mounted) {
        Navigator.of(context).pop(); // Tắt dialog loading
        _showSuccessMessage();
        _redirectToMainPage();
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Tắt dialog loading
        _showErrorMessage(e.toString());
      }
    }
  }

  // Hiển thị dialog loading
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  // Hiển thị thông báo thành công
  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tạo Event Member thành công!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Chuyển hướng đến trang chính
  void _redirectToMainPage() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainPage()),
      (route) => false,
    );
  }

  // Hiển thị thông báo lỗi
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lỗi: ${message.replaceAll('Exception: ', '')}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Column(
          children: [
            const Text(
              "Create Event Member",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Please enter your event member information",
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 30),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _slugController,
                    decoration: const InputDecoration(
                      labelText: 'Slug (unique identifier)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Slug is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => _submitForm(ref),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      backgroundColor: const Color(0xFF3254FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
