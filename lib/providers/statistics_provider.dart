import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/statistics.dart';
import '../repositories/statistics_repository.dart';

final statisticsRepositoryProvider = Provider<StatisticsRepository>((ref) {
  return StatisticsRepository();
});

class StatisticsNotifier extends StateNotifier<AsyncValue<StatisticsData>> {
  final StatisticsRepository _repository;

  StatisticsNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchStatistics();
  }

  Future<void> fetchStatistics() async {
    try {
      state = const AsyncValue.loading();
      final response = await _repository.getStatisticsTop();

      if (response.success && response.data != null) {
        state = AsyncValue.data(response.data!);
      } else {
        state = AsyncValue.error(
            'Failed to fetch statistics: API returned success=false or null data',
            StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final statisticsProvider =
    StateNotifierProvider<StatisticsNotifier, AsyncValue<StatisticsData>>(
        (ref) {
  final repository = ref.watch(statisticsRepositoryProvider);
  return StatisticsNotifier(repository);
});
