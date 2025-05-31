import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/comment_repository.dart';
import '../models/comment.dart';
import 'dart:async';

// State class để quản lý trạng thái comments
class CommentsState {
  final List<Comment> comments;
  final bool isLoading;
  final String? error;

  CommentsState({
    required this.comments,
    this.isLoading = false,
    this.error,
  });

  CommentsState copyWith({
    List<Comment>? comments,
    bool? isLoading,
    String? error,
  }) {
    return CommentsState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Base Notifier class cho comments
class CommentListNotifier extends StateNotifier<CommentsState> {
  final CommentRepository repo;
  final int itemId;
  final String itemType; // 'blog' hoặc 'event'
  Timer? _refreshTimer;
  bool _isDisposed = false;

  CommentListNotifier({
    required this.repo,
    required this.itemId,
    required this.itemType,
  }) : super(CommentsState(comments: [])) {
    print('Khởi tạo CommentListNotifier cho $itemType với id $itemId');
  }

  @override
  void dispose() {
    print('CommentListNotifier đang được dispose cho $itemType với id $itemId');
    _isDisposed = true;
    _cleanupResources();
    super.dispose();
  }

  void _cleanupResources() {
    print('Đang dọn dẹp tài nguyên cho $itemType với id $itemId');
    stopAutoRefresh();
  }

  void startAutoRefresh() {
    if (_isDisposed) {
      print('Không thể start refresh vì notifier đã bị dispose');
      return;
    }

    stopAutoRefresh(); // Đảm bảo không có timer cũ

    print('Bắt đầu auto refresh cho $itemType với id $itemId');
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!_isDisposed) {
        print('Đang refresh comments cho $itemType với id $itemId');
        loadComments();
      } else {
        print('Bỏ qua refresh vì notifier đã bị dispose');
        stopAutoRefresh();
      }
    });
  }

  void stopAutoRefresh() {
    if (_refreshTimer != null) {
      print('Dừng auto refresh cho $itemType với id $itemId');
      _refreshTimer?.cancel();
      _refreshTimer = null;
    }
  }

  Future<void> loadComments() async {
    if (_isDisposed) return;

    try {
      state = state.copyWith(isLoading: true, error: null);
      final comments = await repo.fetchComments(
        itemId: itemId,
        itemCode: itemType,
      );
      if (!_isDisposed) {
        state = state.copyWith(
          comments: comments,
          isLoading: false,
          error: null,
        );
      }
    } catch (e) {
      if (!_isDisposed) {
        state = state.copyWith(
          isLoading: false,
          error: e.toString(),
        );
      }
    }
  }

  Future<void> addComment({required String content, int? parentId}) async {
    if (_isDisposed) return;

    try {
      await repo.createComment({
        'item_id': itemId,
        'item_code': itemType,
        'content': content,
        if (parentId != null) 'parent_id': parentId,
      });
      await loadComments();
    } catch (e) {
      if (!_isDisposed) {
        state = state.copyWith(error: e.toString());
      }
    }
  }

  Future<void> updateComment({required int id, required String content}) async {
    if (_isDisposed) return;

    try {
      await repo.updateComment(id: id, content: content);
      await loadComments();
    } catch (e) {
      if (!_isDisposed) {
        state = state.copyWith(error: e.toString());
      }
    }
  }

  Future<void> deleteComment(int id) async {
    if (_isDisposed) return;

    try {
      await repo.deleteComment(id);
      await loadComments();
    } catch (e) {
      if (!_isDisposed) {
        state = state.copyWith(error: e.toString());
      }
    }
  }
}

// Provider riêng cho Blog Comments
final blogCommentListProvider = StateNotifierProvider.autoDispose
    .family<CommentListNotifier, CommentsState, int>((ref, blogId) {
  final repo = ref.read(commentRepositoryProvider);

  // Tự động cleanup khi provider bị dispose
  ref.onDispose(() {
    print('Blog Comment Provider đã được dispose cho blogId: $blogId');
  });

  return CommentListNotifier(
    repo: repo,
    itemId: blogId,
    itemType: 'blog',
  );
});

// Provider riêng cho Event Comments
final eventCommentListProvider = StateNotifierProvider.autoDispose
    .family<CommentListNotifier, CommentsState, int>((ref, eventId) {
  final repo = ref.read(commentRepositoryProvider);

  ref.onDispose(() {
    print('Event Comment Provider đã được dispose cho eventId: $eventId');
  });

  return CommentListNotifier(
    repo: repo,
    itemId: eventId,
    itemType: 'event',
  );
});
// Provider cho comment repository
final commentRepositoryProvider = Provider((ref) => CommentRepository());
