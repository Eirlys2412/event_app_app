import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event.dart';
import '../providers/theme_provider.dart';
import '../services/vnpay_service.dart';
import '../widget/vnpay_webview.dart';
import 'package:network_info_plus/network_info_plus.dart';

class BuyTicketBottomSheet extends ConsumerStatefulWidget {
  final Event event;
  final Function(int) onConfirm;

  const BuyTicketBottomSheet(
      {Key? key, required this.event, required this.onConfirm})
      : super(key: key);

  @override
  ConsumerState<BuyTicketBottomSheet> createState() =>
      _BuyTicketBottomSheetState();
}

class _BuyTicketBottomSheetState extends ConsumerState<BuyTicketBottomSheet> {
  int _quantity = 1;

  Future<String> _getClientIp() async {
    try {
      final networkInfo = NetworkInfo();
      final wifiIP = await networkInfo.getWifiIP();
      return wifiIP ?? "113.160.225.251";
    } catch (e) {
      print('Error getting IP: $e, using fallback IP: 113.160.225.251');
      return "113.160.225.251";
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ref.watch(themeProvider.notifier);
    final totalPrice = widget.event.ticketPrice! * _quantity;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Chọn số lượng vé',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  if (_quantity > 1) setState(() => _quantity--);
                },
                icon: const Icon(Icons.remove),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '$_quantity',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () {
                  if (_quantity < widget.event.availableTickets!) {
                    setState(() => _quantity++);
                  }
                },
                icon: const Icon(Icons.add),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Tổng cộng: ${totalPrice.toStringAsFixed(0)}đ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              try {
                final clientIp = await _getClientIp();
                final paymentUrl = VNPayService.createPaymentUrl(
                  amount: totalPrice,
                  orderInfo: widget.event.title,
                  clientIp: clientIp,
                );

                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          VNPayWebView(paymentUrl: paymentUrl)),
                );

                if (result == 'success') {
                  widget.onConfirm(_quantity);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Thanh toán thất bại hoặc bị hủy'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Lỗi thanh toán: $e'),
                      backgroundColor:
                          const Color.fromARGB(255, 154, 144, 243)),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Thanh toán qua VNPay'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
        ],
      ),
    );
  }
}

extension on Event {
  get ticketPrice => null;

  get availableTickets => null;
}
