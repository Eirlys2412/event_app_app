import 'package:flutter/material.dart';
import '../screen/ticketdetail_screen.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> transactions = [
    {
      'event': 'Festival Âm Nhạc 2025',
      'date': '2/4/2025 8:31',
      'quantity': 1,
      'type': 'Vé thường',
      'code': 'EV1743578586',
      'price': 650000,
      'status': 'Đang xử lý',
    },
    {
      'event': 'Festival Âm Nhạc 2025',
      'date': '2/4/2025 8:01',
      'quantity': 1,
      'type': 'Vé thường',
      'code': 'EV1743580800',
      'price': 650000,
      'status': 'Đang xử lý',
    },
    {
      'event': 'Triển lãm Âm nhạc và Công nghệ',
      'date': '2/4/2025 7:27',
      'quantity': 1,
      'type': 'Vé thường',
      'code': 'EV1743578888',
      'price': 300000,
      'status': 'Thành công',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử thanh toán'),
        backgroundColor: Colors.brown,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Đang xử lý'),
            Tab(text: 'Thành công'),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.brown[100],
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: const Text(
              'Xem lại các giao dịch của bạn',
              style:
                  TextStyle(color: Colors.brown, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionList(transactions),
                _buildTransactionList(transactions
                    .where((t) => t['status'] == 'Đang xử lý')
                    .toList()),
                _buildTransactionList(transactions
                    .where((t) => t['status'] == 'Thành công')
                    .toList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(List<Map<String, dynamic>> list) {
    if (list.isEmpty) {
      return const Center(child: Text('Không có giao dịch nào.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final t = list[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t['event'],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(t['date'], style: const TextStyle(fontSize: 13)),
                  ],
                ),
                Row(
                  children: [
                    Text('SL: ${t['quantity']} | ${t['type']}',
                        style: const TextStyle(fontSize: 13)),
                    const Spacer(),
                    Text(
                      t['status'],
                      style: TextStyle(
                        color: t['status'] == 'Thành công'
                            ? Colors.green
                            : t['status'] == 'Đang xử lý'
                                ? Colors.orange
                                : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text('Mã: ${t['code']}',
                        style: const TextStyle(fontSize: 13)),
                    const Spacer(),
                    Text(
                      '${t['price'].toStringAsFixed(0)}đ',
                      style: const TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (t['status'] == 'Thành công')
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TicketDetailScreen(transaction: t),
                          ),
                        );
                      },
                      child: const Text('Xem vé'),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
