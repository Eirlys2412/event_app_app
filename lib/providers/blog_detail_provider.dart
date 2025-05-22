import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/blog_detail.dart';
import '../repositories/blog_repository.dart';

class BlogDetailState {
  final bool isLoading;
  final BlogDetail? blog;

  BlogDetailState({
    this.isLoading = false,
    this.blog,
  });

  BlogDetailState copyWith({
    bool? isLoading,
    BlogDetail? blog,
  }) {
    return BlogDetailState(
      isLoading: isLoading ?? this.isLoading,
      blog: blog ?? this.blog,
    );
  }
}

class BlogDetailNotifier extends StateNotifier<BlogDetailState> {
  final BlogRepository repository;

  BlogDetailNotifier(this.repository) : super(BlogDetailState());

  Future<void> fetchBlogDetail({int? id, String? slug}) async {
    state = state.copyWith(isLoading: true);

    try {
      final blog = await repository.getBlogDetail(id: id, slug: slug);
      state = state.copyWith(blog: blog, isLoading: false);
    } catch (_) {
      state = state.copyWith(blog: null, isLoading: false);
    }
  }
}

final blogRepositoryProvider = Provider<BlogRepository>((ref) {
  return BlogRepository();
});

final blogDetailProvider =
    StateNotifierProvider<BlogDetailNotifier, BlogDetailState>((ref) {
  final repository = ref.watch(blogRepositoryProvider);
  return BlogDetailNotifier(repository);
});
