import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/like_repository.dart';

final likeRepositoryProvider = Provider((ref) => LikeRepository());

final likeStateProvider =
    StateNotifierProviderFamily<LikeNotifier, bool, Map<String, dynamic>>(
        (ref, params) {
  return LikeNotifier(
      ref.read(likeRepositoryProvider), params['type'], params['id']);
});

final commentLikeStateProvider =
    StateNotifierProviderFamily<CommentLikeNotifier, bool, int>(
        (ref, commentId) {
  return CommentLikeNotifier(ref.read(likeRepositoryProvider), commentId);
});

class LikeNotifier extends StateNotifier<bool> {
  final LikeRepository repository;
  final String type;
  final int id;

  LikeNotifier(this.repository, this.type, this.id) : super(false);

  Future<void> toggle() async {
    try {
      final liked = await repository.toggleLike(type, id);
      state = liked;
    } catch (e, stack) {
      // Log any errors when toggling like
      print('Error toggling like: $e');
      print(stack);
      rethrow;
    }
  }
}

class CommentLikeNotifier extends StateNotifier<bool> {
  final LikeRepository repository;
  final int commentId;

  CommentLikeNotifier(this.repository, this.commentId) : super(false);

  Future<void> toggle() async {
    try {
      final liked = await repository.toggleCommentLike(commentId);
      state = liked;
    } catch (e, stack) {
      print('Error toggling comment like: $e');
      print(stack);
      rethrow;
    }
  }
}
