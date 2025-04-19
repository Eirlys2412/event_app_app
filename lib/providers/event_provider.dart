import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_app/repositories/event_repository.dart';
import 'package:event_app/models/event.dart'; // Import model Event

// Provider cho EventRepository
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository();
});

// FutureProvider cho danh sách sự kiện
final eventFutureProvider = FutureProvider<List<Event>>((ref) async {
  final repository = ref.watch(eventRepositoryProvider);
  return await repository
      .fetchEvents(); // Sử dụng fetchEvents để lấy List<Event>
});
