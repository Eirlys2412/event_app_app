import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TicketDetailScreen extends StatelessWidget {
  final Map<String, dynamic> transaction;
  const TicketDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết vé'),
        backgroundColor: Colors.brown,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.brown[100],
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.brown),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Trung tâm Hội nghị Quốc gia, Hà Nội',
                          style: TextStyle(color: Colors.brown[800]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Text('Số lượng vé: ', style: TextStyle(fontWeight: FontWeight.w500)),
                      Text('${transaction['quantity']}'),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Loại vé: ', style: TextStyle(fontWeight: FontWeight.w500)),
                      Text(transaction['type']),
                    ],
                  ),
                  const SizedBox(height: 12),
                  QrImageView(
                    data: transaction['code'],
                    version: QrVersions.auto,
                    size: 180.0,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mã vé: ${transaction['code']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.brown[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Thông tin thanh toán', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _infoRow('Mã giao dịch', transaction['code']),
                  _infoRow('Ngày mua', transaction['date']),
                  _infoRow('Trạng thái', 'Đã thanh toán'),
                  _infoRow('Tổng tiền', '${transaction['price'].toStringAsFixed(0)}đ'),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {},
                icon: const Icon(Icons.download),
                label: const Text('Lưu vé'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}