import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event.dart';
import '../repositories/event_repository.dart'; // Bạn cần tạo repository này

// Provider cho EventRepository
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository();
});

class EventListNotifier extends StateNotifier<List<Event>> {
  final EventRepository repo;
  EventListNotifier(this.repo) : super([]) {
    loadEvents();
  }

  Future<void> loadEvents() async {
    try {
      final events = await repo.fetchEvents();
      state = events;
    } catch (e) {
      // Xử lý lỗi nếu cần
    }
  }

  Future<void> addEvent(Map<String, dynamic> data) async {
    await repo.createEvent(data);
    await loadEvents();
  }

  Future<void> deleteEvent(int id) async {
    await repo.deleteEvent(id);
    await loadEvents();
  }

  // Có thể thêm updateEvent, reload, ...
}

// FutureProvider cho danh sách sự kiện
final eventListProvider =
    StateNotifierProvider<EventListNotifier, List<Event>>((ref) {
  final repo = ref.watch(eventRepositoryProvider);
  return EventListNotifier(repo);
});
