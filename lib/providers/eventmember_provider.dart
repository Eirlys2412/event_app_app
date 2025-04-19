import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/eventmember_repository.dart';
import '../models/eventmanager.dart';
import '../models/eventmember.dart';
import 'dart:async';

final EventMemberRepositoryProvider =
    StateNotifierProvider<EventMemberNotifier, AsyncValue<EventMember?>>(
  (ref) => EventMemberNotifier(EventMemberRepository()),
);

class EventMemberNotifier extends StateNotifier<AsyncValue<EventMember?>> {
  final EventMemberRepository repository;

  EventMemberNotifier(this.repository) : super(const AsyncValue.data(null));

  Future<void> createEventMember({
    required int userId,
    required int eventId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final eventMember = await repository.createEventMember(
        userId: userId,
        eventId: eventId,
      );
      state = AsyncValue.data(eventMember);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e.toString(), stackTrace);
      rethrow;
    }
  }
}
