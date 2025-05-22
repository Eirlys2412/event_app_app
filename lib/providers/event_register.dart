import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/event_registration.dart';
import '../models/event_register.dart';
import '../models/my_event.dart';

final eventRegisterRepositoryProvider =
    Provider<EventRegistrationRepository>((ref) {
  return EventRegistrationRepository(
      baseUrl: ''); // baseUrl không cần vì bạn có sẵn URL
});

/// Provider tạm thời lưu kết quả đăng ký sau khi gọi hàm `registerEventProvider`
final registeredEventProvider =
    StateProvider<EventRegistration?>((ref) => null);

/// FutureProvider.family để gọi API đăng ký sự kiện
final registerEventProvider = FutureProvider.family.autoDispose<
    EventRegistration, ({int eventId, String? reason, String token})>(
  (ref, params) async {
    final repo = ref.watch(eventRegisterRepositoryProvider);
    final result = await repo.register(
      eventId: params.eventId,
      reason: params.reason,
      token: params.token,
    );

    // Lưu kết quả lại vào state để dùng lại nếu cần
    ref.read(registeredEventProvider.notifier).state = result;
    return result;
  },
);
final myEventRegistrationsProvider =
    FutureProvider<List<MyEventRegistration>>((ref) async {
  final repo = ref.read(eventRegisterRepositoryProvider);
  return repo.fetchMyRegistrations();
});
