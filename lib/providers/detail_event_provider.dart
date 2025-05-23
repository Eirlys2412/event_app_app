import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_app/repositories/event_repository.dart';
import 'package:event_app/repositories/detail_event_repository.dart';
import 'package:event_app/models/event.dart' show Detailevent;
import 'package:event_app/constants/apilist.dart';

final detailEventRepositoryProvider = Provider<DetailEventRepository>((ref) {
  return DetailEventRepository(baseUrl: base);
});

// Tạo FutureProvider nhận vào eventId để fetch chi tiết
final detailEventProvider =
    FutureProvider.family<Detailevent, int>((ref, eventId) async {
  final repo = ref.read(detailEventRepositoryProvider);
  return await repo.fetchDetailEvent(eventId);
});
