import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class CheckInQRPage extends StatefulWidget {
  const CheckInQRPage({super.key});

  @override
  State<CheckInQRPage> createState() => _CheckInQRPageState();
}

class _CheckInQRPageState extends State<CheckInQRPage> {
  final storage = const FlutterSecureStorage();
  final dio = Dio(BaseOptions(
      baseUrl: 'http://10.55.64.59:8080/api/v1/check-in/{eventId}'));
  bool scanned = false;

  void _handleBarcode(String rawValue) async {
    if (scanned) return;
    setState(() => scanned = true);

    try {
      final data = json.decode(rawValue);
      final qrToken = data['qr_token'];
      final eventId = data['event_id'];

      final token = await storage.read(key: 'token');
      dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await dio.post(
        'event-attendance/check-in/$eventId',
        data: {'qr_token': qrToken, 'location': 'Mobile App'},
      );

      _showDialog(response.data['message']);
    } catch (e) {
      _showDialog('Lỗi khi xử lý QR: ${e.toString()}');
    }

    await Future.delayed(const Duration(seconds: 2));
    setState(() => scanned = false);
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Kết quả điểm danh'),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu), // Nút 3 gạch
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: const Text("Quét mã QR")),
      body: MobileScanner(
        onDetect: (barcode) {
          if (barcode.barcodes.isNotEmpty) {
            final value = barcode.barcodes.first.rawValue;
            if (value != null) {
              _handleBarcode(value);
            }
          }
        },
      ),
    );
  }
}
