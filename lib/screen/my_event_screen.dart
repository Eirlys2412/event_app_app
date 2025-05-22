import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/event_register.dart'; // Đảm bảo import đúng provider
import '../models/event_register.dart';
import '../models/my_event.dart';
import '../providers/theme_provider.dart';
import '../widgets/theme_button.dart';
import '../widgets/theme_selector.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/apilist.dart';
import '../screen/detail_event_screen.dart'; // thêm dòng này
import 'package:intl/intl.dart';

class MyRegisteredEventsScreen extends ConsumerStatefulWidget {
  const MyRegisteredEventsScreen({super.key});

  @override
  ConsumerState<MyRegisteredEventsScreen> createState() =>
      _MyRegisteredEventsScreenState();
}

class _MyRegisteredEventsScreenState
    extends ConsumerState<MyRegisteredEventsScreen> {
  final Map<DateTime, List<Map<String, dynamic>>> _events = {};
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  late DateTime firstDay;
  late DateTime lastDay;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeDates();
    loadEvents();
  }

  void _initializeDates() {
    final now = DateTime.now();
    firstDay = DateTime(now.year - 1, 1, 1);
    lastDay = DateTime(now.year + 2, 12, 31);
  }

  Future<void> loadEvents() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse(api_join));
      if (response.statusCode == 200) {
        _processEventData(jsonDecode(response.body)['data'] as List);
      }
    } catch (e) {
      print("Error loading events: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _processEventData(List data) {
    _events.clear();
    for (var event in data) {
      final DateTime date = DateTime.parse(event['timestart']).toLocal();
      final DateTime dayOnly = DateTime(date.year, date.month, date.day);
      _events
          .putIfAbsent(dayOnly, () => [])
          .add(Map<String, dynamic>.from(event));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final myEventsReAsync = ref.watch(myEventRegistrationsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Sự kiện đã tham gia',
            style: TextStyle(color: themeState.appBarTextColor),
          ),
          backgroundColor: themeState.appBarColor,
          actions: const [ThemeButton(), ThemeSelector()],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Chờ duyệt'),
              Tab(text: 'Đã duyệt'),
            ],
          ),
        ),
        body: myEventsReAsync.when(
          data: (events) {
            final pendingEvents =
                events.where((e) => e.status == 'pending').toList();
            final approvedEvents = events
                .where((e) => e.status == 'approved' || e.status == 'accepted')
                .toList();

            return TabBarView(
              children: [
                _buildEventList(pendingEvents, 'Chưa có sự kiện chờ duyệt.'),
                _buildEventList(approvedEvents, 'Chưa có sự kiện đã duyệt.'),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Lỗi: $err')),
        ),
      ),
    );
  }

  Widget _buildEventList(List<MyEventRegistration> events, String emptyText) {
    if (events.isEmpty) {
      return Center(child: Text(emptyText));
    }
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final eventReg = events[index];
        final event = eventReg.event;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              event.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 18, color: Colors.blueGrey),
                    const SizedBox(width: 6),
                    Text(
                      'Bắt đầu: ${formatDate(event.timestart)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 18, color: Colors.orange),
                    const SizedBox(width: 6),
                    Text(
                      'Trạng thái: ${eventReg.status}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                if (event.description != null && event.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      event.description!,
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black87),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EventDetailScreen(event: {
                    'id': event.id,
                    'title': event.title,
                    'summary': event.summary,
                    'description': event.description,
                    'timestart': event.timestart,
                    'timeend': event.timeend,
                    'diadiem': event.diadiem,
                    'resources': event.resources,
                  }),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String formatDate(String? isoDate) {
    if (isoDate == null) return '';
    final date = DateTime.tryParse(isoDate);
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String getEventStatus(String? timestart, String? timeend) {
    if (timestart == null || timeend == null) return 'Không xác định';
    final now = DateTime.now();
    final start = DateTime.tryParse(timestart);
    final end = DateTime.tryParse(timeend);
    if (start == null || end == null) return 'Không xác định';

    if (now.isBefore(start)) {
      return 'Sắp diễn ra';
    } else if (now.isAfter(end)) {
      return 'Đã diễn ra';
    } else {
      return 'Đang diễn ra';
    }
  }
}
