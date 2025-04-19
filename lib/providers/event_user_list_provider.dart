import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_app/repositories/event_user_list_repository.dart';
import 'package:event_app/models/event_user_list.dart';

// Repository provider
final eventUserRepositoryProvider = Provider<EventUserRepository>((ref) {
  return EventUserRepository();
});

// Future provider cho danh sách user của 1 sự kiện
final eventUserListProvider = FutureProvider.family<List<EventUser>, int>((ref, eventId) async {
  final repository = ref.watch(eventUserRepositoryProvider);
  return await repository.fetchEventUsers(eventId);
});
