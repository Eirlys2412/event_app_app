import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart';
import 'package:event_app/constants/apilist.dart';
import 'package:event_app/screen/detail_event_screen.dart';
import '../utils/event_utils.dart';
import '../constants/pref_data.dart';
import '../widget/drawer_custom.dart';
import '../widgets/theme_button.dart';
import '../widgets/theme_selector.dart';
import '../widgets/event_card.dart';
import '../widgets/calendar_styles.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../models/event.dart';

class EventScreen extends ConsumerStatefulWidget {
  const EventScreen({super.key});

  @override
  ConsumerState<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends ConsumerState<EventScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _events = {};
  bool isLoading = true;

  late final DateTime firstDay;
  late final DateTime lastDay;

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
    _selectedDay = _focusedDay;
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    try {
      final token = await PrefData.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Vui lòng đăng nhập để thực hiện chức năng này');
      }
      return {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
    } catch (e) {
      print('Error getting auth headers: $e');
      throw Exception('Lỗi xác thực: ${e.toString()}');
    }
  }

  Future<void> loadEvents() async {
    setState(() => isLoading = true);
    try {
      final headers = await _getAuthHeaders();
      print('Loading events with headers: $headers');

      final response = await http.get(
        Uri.parse(api_event),
        headers: headers,
      );

      print('Event Response Status: ${response.statusCode}');
      print('Event Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null) {
          final events = data['data'] as List;
          print('Received ${events.length} events from API');
          _processEventData(events);
        } else {
          print('No data field in response');
          _events.clear();
        }
      } else {
        print('Error loading events: ${response.statusCode}');
        print('Error response: ${response.body}');
        _events.clear();
      }
    } catch (e) {
      print("Error loading events: $e");
      _events.clear();
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _processEventData(List data) {
    print('Processing event data: ${data.length} events');
    _events.clear();
    for (var event in data) {
      try {
        if (event == null || event['timestart'] == null) {
          print('Event missing or null timestart: $event');
          continue;
        }

        final DateTime date = DateTime.parse(event['timestart']).toLocal();
        final DateTime dayOnly = DateTime(date.year, date.month, date.day);

        print('Processing event for date: $dayOnly');
        print('Event data: $event');

        if (event['resources_data'] != null &&
            event['resources_data'] is List) {
          for (var res in event['resources_data']) {
            if (res['url'] != null) {
              res['url'] = fixImageUrl(res['url']);
            }
          }
        }

        _events.putIfAbsent(dayOnly, () => []).add(normalizeEvent(event));
      } catch (e) {
        print('Error processing event: $e');
        print('Problematic event data: $event');
      }
    }
    print('Processed events map: $_events');
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final events = _events[DateTime(day.year, day.month, day.day)] ?? [];
    print('Getting events for day $day: ${events.length} events');
    return events;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay.isAfter(lastDay) ? lastDay : focusedDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);

    return Scaffold(
      drawer: const DrawerCustom(),
      appBar: _buildAppBar(themeState),
      backgroundColor: themeState.backgroundColor,
      body: Column(
        children: [
          _buildCalendar(themeState),
          const SizedBox(height: 8),
          _buildEventList(themeState),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeState themeState) {
    return AppBar(
      title: Text(
        'Lịch sự kiện',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: themeState.appBarTextColor,
        ),
      ),
      backgroundColor: themeState.appBarColor,
      centerTitle: true,
      actions: const [ThemeButton(), ThemeSelector()],
    );
  }

  Widget _buildCalendar(ThemeState themeState) {
    return TableCalendar<Map<String, dynamic>>(
      firstDay: firstDay,
      lastDay: lastDay,
      focusedDay: _focusedDay.isAfter(lastDay) ? lastDay : _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      eventLoader: _getEventsForDay,
      onDaySelected: _onDaySelected,
      onFormatChanged: (format) => setState(() => _calendarFormat = format),
      calendarStyle: getCalendarStyle(themeState),
      headerStyle: getHeaderStyle(themeState),
      daysOfWeekStyle: getDaysOfWeekStyle(themeState),
    );
  }

  Widget _buildEventList(ThemeState themeState) {
    if (isLoading) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_selectedDay == null) {
      return Expanded(
        child: _buildCenterText('Chọn ngày để xem sự kiện', themeState),
      );
    }

    final events = _getEventsForDay(_selectedDay!);
    print('Building event list for ${_selectedDay}: ${events.length} events');

    if (events.isEmpty) {
      return Expanded(
        child: _buildCenterText('Không có sự kiện nào', themeState),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: events.length,
        itemBuilder: (context, index) {
          print('Building event card at index $index: ${events[index]}');
          return EventCard(
            event: Event.fromJson(events[index]),
            themeState: themeState,
          );
        },
      ),
    );
  }

  Widget _buildCenterText(String text, ThemeState themeState) {
    return Center(
      child: Text(
        text,
        style: TextStyle(color: themeState.secondaryTextColor),
      ),
    );
  }
}
