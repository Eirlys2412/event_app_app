import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widget/drawer_custom.dart';
import '../providers/theme_provider.dart';
import '../screen/login_screen.dart'; // Thêm import cho màn hình đăng nhập
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import '../constants/pref_data.dart';

const String api_qr = 'http://10.0.2.2:8000/api/v1/';
//const String api_qr = 'http://127.0.0.1:8000/api/v1/';

class CheckInQRPage extends ConsumerStatefulWidget {
  const CheckInQRPage({super.key});

  @override
  ConsumerState<CheckInQRPage> createState() => _CheckInQRPageState();
}

class _CheckInQRPageState extends ConsumerState<CheckInQRPage> {
  final storage = const FlutterSecureStorage();
  final dio = Dio(BaseOptions(baseUrl: api_qr));
  bool scanned = false;
  bool isScanning = false;
  bool isCameraOn = false;
  String? scannedContent;
  late MobileScannerController _scannerController;
  File? _selectedImage;
  String? _selectedImageFileName;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController();
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    try {
      final token = await PrefData.getToken();
      print(
          'Auth token: ${token?.substring(0, 10)}...'); // Debug log - only show first 10 chars

      if (token == null || token.isEmpty) {
        throw Exception('Vui lòng đăng nhập để thực hiện chức năng này');
      }

      return {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
    } catch (e) {
      print('Error getting auth headers: $e'); // Debug log
      throw Exception('Lỗi xác thực: ${e.toString()}');
    }
  }

  void _startScan() {
    setState(() {
      isScanning = true;
      isCameraOn = true;
      scannedContent = null;
      _scannerController.start();
    });
  }

  void _stopScan() {
    setState(() {
      isScanning = false;
      isCameraOn = false;
      _scannerController.stop();
    });
  }

  Future<void> _handleBarcode(String rawValue) async {
    if (scanned) return;
    setState(() {
      scanned = true;
      scannedContent = rawValue;
    });

    try {
      final qrData = jsonDecode(rawValue);

      if (qrData['event_id'] == null ||
          qrData['qr_token'] == null ||
          qrData['expires_at'] == null) {
        _showDialog('Mã QR không hợp lệ!');
        return;
      }

      final token = await PrefData.getToken();
      if (token == null || token.isEmpty) {
        _showDialogAndNavigate('Không tìm thấy token. Vui lòng đăng nhập lại.');
        return;
      }

      final response = await dio.post(
        'event-attendance/check-in',
        data: {
          'event_id': qrData['event_id'],
          'qr_token': qrData['qr_token'],
          'expires_at': qrData['expires_at'],
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => true,
        ),
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        final eventName = response.data['data']?['event_name'] ?? '';
        _showDialog(
            'Điểm danh thành công${eventName.isNotEmpty ? ' cho sự kiện: $eventName' : ''}!');
      } else {
        _showDialog(
            'Lỗi điểm danh: ${response.data['message'] ?? 'Không rõ lỗi'}');
      }
    } catch (e) {
      _showDialog('Lỗi khi xử lý mã QR: ${e.toString()}');
    }

    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      scanned = false;
      isScanning = false;
      isCameraOn = false;
      _scannerController.stop();
    });
  }

  Future<void> _pickImageForAttendance() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path!);
        _selectedImageFileName = pickedFile.name;
      });
      // Sau khi chọn ảnh, tự động quét QR
      await _scanQRCodeFromImage(_selectedImage!);
    }
  }

  Future<void> _scanQRCodeFromImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final barcodeScanner = BarcodeScanner();
      final barcodes = await barcodeScanner.processImage(inputImage);
      await barcodeScanner.close();
      if (barcodes.isEmpty) {
        _showDialog('Không tìm thấy mã QR trong ảnh!');
        return;
      }
      // Lấy mã đầu tiên (nếu có nhiều mã)
      final qrRawValue = barcodes.first.rawValue;
      if (qrRawValue == null) {
        _showDialog('Không đọc được nội dung mã QR!');
        return;
      }
      // Gửi thông tin lên API như khi quét camera
      await _handleBarcode(qrRawValue);
    } catch (e) {
      _showDialog('Lỗi khi quét mã QR từ ảnh: \\${e.toString()}');
    }
  }

  void _showDialog(String message) {
    final themeState = ref.read(themeProvider);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: themeState.surfaceColor,
        title: Text(
          'Kết quả điểm danh',
          style: TextStyle(color: themeState.primaryTextColor),
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 16,
            color: themeState.bodyTextColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Đóng',
              style: TextStyle(color: themeState.primaryColor),
            ),
          )
        ],
      ),
    );
  }

  void _showDialogAndNavigate(String message) {
    final themeState = ref.read(themeProvider);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: themeState.surfaceColor,
        title: Text(
          'Kết quả điểm danh',
          style: TextStyle(color: themeState.primaryTextColor),
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 16,
            color: themeState.bodyTextColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(
                  context, '/login'); // Điều hướng về màn hình đăng nhập
            },
            child: Text(
              'Đăng nhập',
              style: TextStyle(color: themeState.primaryColor),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeState.appBarTextColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "QR Code Reader",
          style: TextStyle(
            color: themeState.appBarTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: themeState.appBarColor,
        elevation: 0,
        actions: [
          if (isCameraOn)
            TextButton(
              onPressed: _stopScan,
              child: Text(
                'CANCEL',
                style: TextStyle(color: themeState.appBarTextColor),
              ),
            ),
        ],
      ),
      backgroundColor: themeState.backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                if (isCameraOn)
                  MobileScanner(
                    onDetect: (capture) {
                      if (capture.barcodes.isNotEmpty) {
                        final value = capture.barcodes.first.rawValue;
                        if (value != null) _handleBarcode(value);
                      }
                    },
                  ),
                if (isCameraOn)
                  CustomPaint(
                    painter: QRScannerOverlayPainter(themeState: themeState),
                    child: Container(),
                  ),
                if (!isCameraOn)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (scannedContent != null) ...[
                          Container(
                            padding: const EdgeInsets.all(20),
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: themeState.surfaceColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.qr_code_2,
                                  size: 100,
                                  color: themeState.secondaryTextColor,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Contents:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: themeState.primaryTextColor,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  scannedContent!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: themeState.bodyTextColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ] else
                          Container(
                            padding: const EdgeInsets.all(20),
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: themeState.surfaceColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.qr_code_2,
                              size: 150,
                              color: themeState.secondaryTextColor,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (!isCameraOn)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _startScan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeState.primaryColor,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      'Scan QR',
                      style: TextStyle(
                        fontSize: 18,
                        color: themeState.buttonTextColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _pickImageForAttendance,
                    icon: const Icon(Icons.image),
                    label: const Text('Chọn ảnh để điểm danh'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeState.primaryColor,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                  if (_selectedImageFileName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Đã chọn: \\${_selectedImageFileName!}',
                        style: TextStyle(color: themeState.primaryTextColor),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class QRScannerOverlayPainter extends CustomPainter {
  final ThemeState themeState;

  QRScannerOverlayPainter({required this.themeState});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = themeState.primaryColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final double scanAreaSize = size.width * 0.7;
    final double left = (size.width - scanAreaSize) / 2;
    final double top = (size.height - scanAreaSize) / 2;

    // Draw scan area border
    final scanRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize),
      const Radius.circular(12),
    );
    canvas.drawRRect(scanRect, paint);

    // Draw corner markers
    final markerLength = scanAreaSize * 0.1;
    final cornerPaint = Paint()
      ..color = themeState.primaryColor
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    // Top left corner
    canvas.drawLine(
      Offset(left, top + markerLength),
      Offset(left, top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left, top),
      Offset(left + markerLength, top),
      cornerPaint,
    );

    // Top right corner
    canvas.drawLine(
      Offset(left + scanAreaSize - markerLength, top),
      Offset(left + scanAreaSize, top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + scanAreaSize, top),
      Offset(left + scanAreaSize, top + markerLength),
      cornerPaint,
    );

    // Bottom left corner
    canvas.drawLine(
      Offset(left, top + scanAreaSize - markerLength),
      Offset(left, top + scanAreaSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left, top + scanAreaSize),
      Offset(left + markerLength, top + scanAreaSize),
      cornerPaint,
    );

    // Bottom right corner
    canvas.drawLine(
      Offset(left + scanAreaSize - markerLength, top + scanAreaSize),
      Offset(left + scanAreaSize, top + scanAreaSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + scanAreaSize, top + scanAreaSize - markerLength),
      Offset(left + scanAreaSize, top + scanAreaSize),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
