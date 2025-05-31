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
  bool _isLoading = false; // Add internal loading state

  // Getter for loading state
  bool get isLoading => _isLoading;

  BlogListNotifier(this.repo) : super([]) {
    print('BlogListNotifier created, loading blogs...');
    loadBlogs();
  }

  Future<void> loadBlogs() async {
    print('Attempting to load blogs...');
    _isLoading = true; // Set loading to true
    try {
      final result = await repo.getApprovedBlogs();
      print(
          'Blogs loaded successfully. Number of blogs: ${result.data.length}');
      state = result.data; // Lấy data từ BlogApprovedPagination
    } catch (e) {
      print('Error loading blogs: $e');
      state = []; // Clear state on error
    } finally {
      _isLoading = false; // Set loading to false in finally
      // No need to notify listeners explicitly for _isLoading here if watching the provider state itself handles rebuilds.
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

  void updateLikeStatus(int blogId, bool isLiked, int likesCount) {
    print(
        'Updating like status for blog ID: $blogId, isLiked: $isLiked, likesCount: $likesCount');
    state = state.map((blog) {
      if (blog.id == blogId) {
        print('Found blog to update: ${blog.id}');
        return BlogApproved(
          id: blog.id,
          title: blog.title,
          slug: blog.slug,
          summary: blog.summary,
          content: blog.content,
          catId: blog.catId,
          photo: blog.photo,
          createdAt: blog.createdAt,
          updatedAt: blog.updatedAt,
          userId: blog.userId,
          authorName: blog.authorName,
          authorPhoto: blog.authorPhoto,
          authorId: blog.authorId,
          countBookmarked: blog.countBookmarked,
          countLike: likesCount,
          countComment: blog.countComment,
          tags: blog.tags,
          is_liked: isLiked,
          likes_count: likesCount,
        );
      }
      return blog;
    }).toList();
    print(
        'State after update: ${state.map((b) => '(${b.id}, liked: ${b.is_liked}, count: ${b.countLike})').join(', ')}');
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
