import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../config/vnpay_config.dart';

class VNPayService {
  static String createPaymentUrl({
    required double amount,
    required String orderInfo,
    required String clientIp,
  }) {
    if (amount <= 0) {
      throw Exception('Amount must be greater than 0');
    }

    final txnRef =
        'EV${(DateTime.now().millisecondsSinceEpoch / 1000).floor()}${_generateRandomString(6)}';

    final inputData = {
      "vnp_Version": "2.1.0",
      "vnp_TmnCode": VNPayConfig.tmnCode,
      "vnp_Amount": (amount * 100).round().toString(), // Nhân 100 cho VND
      "vnp_Command": "pay",
      "vnp_CreateDate": DateFormat('yyyyMMddHHmmss').format(DateTime.now()),
      "vnp_CurrCode": "VND",
      "vnp_IpAddr": clientIp,
      "vnp_Locale": "vn",
      "vnp_OrderInfo": orderInfo,
      "vnp_OrderType": "event_ticket",
      "vnp_ReturnUrl": VNPayConfig.returnUrl,
      "vnp_TxnRef": txnRef,
    };

    // Log dữ liệu gửi lên
    print('VNPay inputData: $inputData');

    _validateParams(inputData);

    final sortedKeys = inputData.keys.toList()..sort();
    var hashData = "";
    var query = "";

    for (var key in sortedKeys) {
      final value = inputData[key]!;
      if (value.isNotEmpty) {
        hashData += (hashData.isEmpty ? '' : '&') + key + "=" + value;
        query +=
            Uri.encodeComponent(key) + "=" + Uri.encodeComponent(value) + '&';
      }
    }

    // Log hashData để kiểm tra chữ ký
    print('Hash data before signing: $hashData');

    final hmac = Hmac(sha512, utf8.encode(VNPayConfig.hashSecret));
    final hash = hmac.convert(utf8.encode(hashData));
    final vnpSecureHash = hash.toString().toUpperCase();

    final paymentUrl =
        '${VNPayConfig.vnpUrl}?$query' + 'vnp_SecureHash=$vnpSecureHash';
    print('Generated paymentUrl: $paymentUrl');

    return paymentUrl;
  }

  static Future<String> getResponseStatus(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Response Data: $responseData');
        return responseData['responseStatus'] ?? 'unknown';
      } else {
        print('Failed to load response status: ${response.statusCode}');
        throw Exception('Failed to load response status');
      }
    } catch (e) {
      print('Error fetching response status: $e');
      throw Exception('Error fetching response status: $e');
    }
  }

  static String _generateRandomString(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  static void _validateParams(Map<String, String> params) {
    final requiredParams = [
      'vnp_Version',
      'vnp_Command',
      'vnp_TmnCode',
      'vnp_Amount',
      'vnp_CreateDate',
      'vnp_CurrCode',
      'vnp_IpAddr',
      'vnp_Locale',
      'vnp_OrderInfo',
      'vnp_OrderType',
      'vnp_ReturnUrl',
      'vnp_TxnRef'
    ];

    for (var param in requiredParams) {
      if (!params.containsKey(param) || params[param]!.isEmpty) {
        print('Missing required parameter: $param');
        throw Exception('Missing required parameter: $param');
      }
    }
  }
}
