import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/eventmanager_reponsitory.dart';
import '../models/eventmanager.dart';
import 'dart:async';

final eventManagerRepositoryProvider =
    StateNotifierProvider<EventManagerNotifier, AsyncValue<EventManager?>>(
  (ref) => EventManagerNotifier(EventManagerRepository()),
);

class EventManagerNotifier extends StateNotifier<AsyncValue<EventManager?>> {
  final EventManagerRepository repository;

  EventManagerNotifier(this.repository) : super(const AsyncValue.data(null));

  Future<void> createEventManager({
    required int userId,
    required String slug,
  }) async {
    state = const AsyncValue.loading();
    try {
      final eventManager = await repository.createEventManager(
        userId: userId,
        slug: slug,
      );
      state = AsyncValue.data(eventManager);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e.toString(), stackTrace);
      rethrow;
    }
  }
}
