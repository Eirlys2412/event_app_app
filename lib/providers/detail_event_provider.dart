import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_app/repositories/event_repository.dart';
import 'package:event_app/repositories/detail_event_repository.dart';
import 'package:event_app/models/detail_event.dart';
import 'package:event_app/constants/apilist.dart';

final detailEventRepositoryProvider = Provider<DetailEventRepository>((ref) {
  return DetailEventRepository(baseUrl: api_event_detail(0));
});

// Tạo FutureProvider nhận vào eventId để fetch chi tiết
final detailEventProvider =
    FutureProvider.family<Detailevent, int>((ref, eventId) async {
  final repo = ref.read(detailEventRepositoryProvider);
  return await repo.fetchDetailEvent(eventId);
});
