import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/vote_repository.dart';

final voteRepositoryProvider = Provider((ref) => VoteRepository());

final voteStateProvider =
    StateNotifierProviderFamily<VoteNotifier, double, Map<String, dynamic>>(
        (ref, params) {
  return VoteNotifier(
      ref.read(voteRepositoryProvider), params['type'], params['id']);
});

class VoteNotifier extends StateNotifier<double> {
  final VoteRepository repository;
  final String type;
  final int id;

  VoteNotifier(this.repository, this.type, this.id) : super(0.0) {
    loadAverage();
  }

  Future<void> loadAverage() async {
    state = await repository.fetchAverageVote(type, id);
  }

  Future<void> vote(int score) async {
    await repository.vote(type, id, score);
    await loadAverage();
  }
}
