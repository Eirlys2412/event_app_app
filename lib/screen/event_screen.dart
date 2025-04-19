import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:event_app/screen/detail_event_screen.dart';
import 'package:event_app/constants/apilist.dart';
import 'package:event_app/utils/date_utils.dart';
import '../widget/drawer_custom.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List allEvents = [];
  List myEvents = [];
  List filteredAllEvents = [];
  List filteredMyEvents = [];
  bool isLoading = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    try {
      final response = await http.get(Uri.parse(api_event));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        List all = responseData['data'] ?? [];

        all.sort((a, b) => DateTime.parse(a['timestart'] ?? '')
            .compareTo(DateTime.parse(b['timestart'] ?? '')));
        List joined = all.where((e) => e['is_joined'] == true).toList();

        setState(() {
          allEvents = all;
          myEvents = joined;
          filteredAllEvents = allEvents;
          filteredMyEvents = myEvents;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _filterEvents(String query) {
    query = query.toLowerCase();
    setState(() {
      filteredAllEvents = allEvents.where((event) {
        final title = event['title']?.toLowerCase() ?? '';
        final desc = event['description']?.toLowerCase() ?? '';
        return title.contains(query) || desc.contains(query);
      }).toList();

      filteredMyEvents = myEvents.where((event) {
        final title = event['title']?.toLowerCase() ?? '';
        final desc = event['description']?.toLowerCase() ?? '';
        return title.contains(query) || desc.contains(query);
      }).toList();
    });
  }

  String getEventStatus(String? timeStart, String? timeEnd) {
    DateTime now = DateTime.now();
    DateTime start = DateTime.parse(timeStart ?? '');
    DateTime end = DateTime.parse(timeEnd ?? '');
    if (now.isBefore(start)) return "Sắp diễn ra";
    if (now.isAfter(end)) return "Đã diễn ra";
    return "Đang diễn ra";
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "Đang diễn ra":
        return Colors.green;
      case "Sắp diễn ra":
        return Colors.orange;
      case "Đã diễn ra":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget buildEventCard(Map event) {
    String status = getEventStatus(event['timestart'], event['timeend']);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Image.network(
            event['image'] ?? '',
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) => const Icon(Icons.image),
          ),
        ),
        title: Text(event['title'] ?? 'Không có tiêu đề',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.access_time, size: 16),
              const SizedBox(width: 5),
              Expanded(child: Text(formatDate(event['timestart'])))
            ]),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.info_outline, size: 16),
              const SizedBox(width: 5),
              Text(
                status,
                style: TextStyle(
                  color: getStatusColor(status),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ]),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    EventDetailScreen(event: event as Map<String, dynamic>),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 99, 19, 237),
          ),
          child: const Text(
            "Chi tiết",
            style: TextStyle(color: Color.fromARGB(255, 255, 254, 254)),
          ),
        ),
      ),
    );
  }

  Widget buildTabContent(List events) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (events.isEmpty) {
      return const Center(child: Text("Không có sự kiện nào"));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (_, i) => buildEventCard(events[i]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerCustom(userName: '', userEmail: '', avatarUrl: ''),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 154, 144, 243),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: "Tìm kiếm...",
                  border: InputBorder.none,
                ),
                onChanged: _filterEvents,
              )
            : const Text("Sự kiện"),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _filterEvents('');
                }
              });
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
          // Đặt chữ đậm
          tabs: const [
            Tab(text: "Tất cả sự kiện"),
            Tab(text: "Sự kiện của tôi"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildTabContent(filteredAllEvents),
          buildTabContent(filteredMyEvents),
        ],
      ),
    );
  }
}
