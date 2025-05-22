import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/blog_approved.dart';
import '../repositories/blog_repository.dart';
import '../models/blog_detail.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

final blogRepositoryProvider = Provider<BlogRepository>((ref) {
  return BlogRepository();
});

// StateNotifier quản lý danh sách blog động
class BlogListNotifier extends StateNotifier<List<BlogApproved>> {
  final BlogRepository repo;
  BlogListNotifier(this.repo) : super([]) {
    loadBlogs();
  }

  Future<void> loadBlogs() async {
    try {
      final result = await repo.getApprovedBlogs();
      state = result.data; // Lấy data từ BlogApprovedPagination
    } catch (e) {
      print('Lỗi load blogs: $e');
    }
  }

  Future<void> addBlog(Map<String, dynamic> data) async {
    await repo.createPost(data);
    await loadBlogs();
  }

  Future<void> deleteBlog(int id) async {
    await repo.deletePost(id);
    await loadBlogs();
  }

  // Có thể thêm updateBlog, reload, ...
}

// Provider toàn cục cho danh sách blog
final blogListProvider =
    StateNotifierProvider<BlogListNotifier, List<BlogApproved>>((ref) {
  final repo = ref.watch(blogRepositoryProvider);
  return BlogListNotifier(repo);
});

final myBlogsProvider =
    FutureProvider.family<List<BlogApproved>, String>((ref, token) async {
  final repo = ref.read(blogRepositoryProvider);
  return repo.fetchMyBlogs();
});

final blogsByUserProvider =
    FutureProvider.family<List<BlogApproved>, int>((ref, userId) async {
  final repo = ref.read(blogRepositoryProvider);
  return repo.fetchUserBlogs(userId);
});
