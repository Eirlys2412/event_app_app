import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/comment_repository.dart';
import '../models/comment.dart';

final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  return CommentRepository();
});

class CommentListNotifier extends StateNotifier<List<Comment>> {
  final CommentRepository repo;
  final int itemId;
  final String itemCode;

  CommentListNotifier(this.repo, this.itemId, this.itemCode) : super([]) {
    loadComments();
  }

  Future<void> loadComments() async {
    try {
      final comments =
          await repo.fetchComments(itemId: itemId, itemCode: itemCode);
      print(
          'Fetched ${comments.length} comments for itemId: $itemId, itemCode: $itemCode');
      state = comments;
    } catch (e) {
      // Xử lý lỗi nếu cần
    }
  }

  Future<void> addComment({required String content, int? parentId}) async {
    await repo.createComment({
      'item_id': itemId,
      'item_code': itemCode,
      'content': content,
      if (parentId != null) 'parent_id': parentId,
    });
    await loadComments();
  }

  Future<void> deleteComment(int id) async {
    await repo.deleteComment(id);
    await loadComments();
  }

  Future<void> updateComment({required int id, required String content}) async {
    await repo.updateComment(id: id, content: content);
    await loadComments();
  }
}

// Provider family để truyền tham số động (ví dụ: id sự kiện, loại sự kiện)
final commentListProvider = StateNotifierProvider.family<CommentListNotifier,
    List<Comment>, Map<String, dynamic>>(
  (ref, params) {
    final repo = ref.watch(commentRepositoryProvider);
    return CommentListNotifier(repo, params['itemId'], params['itemCode']);
  },
);

class CommentProvider with ChangeNotifier {
  final CommentRepository commentRepository;
  List<Comment> _comments = [];
  bool _isLoading = false;
  String _errorMessage = '';

  CommentProvider({required this.commentRepository});

  List<Comment> get comments => _comments;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchComments({
    required int itemId,
    required String itemCode,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _comments = await commentRepository.fetchComments(
        itemId: itemId,
        itemCode: itemCode,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createComment({
    required int itemId,
    required String itemCode,
    required String content,
    int? parentId,
    String? commentResources,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await commentRepository.createComment({
        'item_id': itemId,
        'item_code': itemCode,
        'content': content,
      });
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateComment({
    required int id,
    required String content,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final updatedComment = await commentRepository.updateComment(
        id: id,
        content: content,
      );
      final index = _comments.indexWhere((c) => c.id == id);
      if (index != -1) {
        _comments[index] = updatedComment;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteComment(int id) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await commentRepository.deleteComment(id);
      _comments.removeWhere((c) => c.id == id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
