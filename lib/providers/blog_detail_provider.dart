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

  void updateLikeStatus(int blogId, bool isLiked, int likesCount) {
    if (state.blog != null && state.blog!.id == blogId) {
      final updatedBlog = BlogDetail(
        id: state.blog!.id,
        title: state.blog!.title,
        slug: state.blog!.slug,
        summary: state.blog!.summary,
        content: state.blog!.content,
        catId: state.blog!.catId,
        photo: state.blog!.photo,
        createdAt: state.blog!.createdAt,
        updatedAt: state.blog!.updatedAt,
        userId: state.blog!.userId,
        authorName: state.blog!.authorName,
        authorPhoto: state.blog!.authorPhoto,
        authorId: state.blog!.authorId,
        countBookmarked: state.blog!.countBookmarked,
        countLike: likesCount,
        countComment: state.blog!.countComment,
        tags: state.blog!.tags,
        isBookmarked: state.blog!.isBookmarked,
        reactions: state.blog!.reactions,
        hasComment: state.blog!.hasComment,
        comments: state.blog!.comments,
        voteRecord: state.blog!.voteRecord,
        is_liked: isLiked,
        likes_count: likesCount,
      );
      state = state.copyWith(blog: updatedBlog);
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
