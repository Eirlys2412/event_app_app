import 'package:event_app/constants/apilist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EventRegisterScreen extends ConsumerStatefulWidget {
  final int eventId;
  final String eventTitle;

  const EventRegisterScreen({
    Key? key,
    required this.eventId,
    required this.eventTitle,
  }) : super(key: key);

  @override
  ConsumerState<EventRegisterScreen> createState() =>
      _EventRegisterScreenState();
}

class _EventRegisterScreenState extends ConsumerState<EventRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _note;
  bool _isSubmitting = false;

  // API URL của backend Laravel
  final String apiUrl = api_event_register;

  // Lấy token từ SharedPreferences
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ??
        ''; // Lấy token đã lưu, nếu không có trả về chuỗi rỗng
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus(); // Đóng bàn phím

    _formKey.currentState!.save();
    setState(() => _isSubmitting = true);

    try {
      // Lấy token người dùng
      String token = await _getToken();

      if (token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vui lòng đăng nhập lại")),
        );
        return;
      }

      // Gửi yêu cầu đăng ký tới backend
      final response = await _registerEvent(token);

      if (response['status']) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Yêu cầu tham gia đã được gửi")),
        );
        Navigator.pop(context); // Quay về màn chi tiết
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Đăng ký thất bại: ${response['message']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đăng ký thất bại: $e")),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<Map<String, dynamic>> _registerEvent(String token) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'event_id': widget.eventId,
        'reason': _note,
      }),
    );
    print(token);
    print(response.body);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 400) {
      throw Exception('Bad Request: ${response.body}');
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Please log in again');
    } else if (response.statusCode == 500) {
      throw Exception('Server error: Please try again later');
    } else {
      throw Exception('Failed to register event');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("Đăng ký: ${widget.eventTitle}"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Bạn có chắc chắn muốn tham gia sự kiện này không?",
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              TextFormField(
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Lý do tham gia (tùy chọn)",
                  hintText: "Nhập lý do nếu bạn muốn...",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                onSaved: (value) => _note = value?.trim(),
                validator: (value) {
                  if (value != null && value.trim().isEmpty) {
                    return 'Lý do tham gia không được để trống';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitRegistration,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.send),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        _isSubmitting
                            ? "Đang gửi yêu cầu..."
                            : "Gửi yêu cầu đăng ký",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
}
