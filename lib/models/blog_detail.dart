import 'blog_approved.dart';
import 'dart:convert';

class BlogDetail extends BlogApproved {
  final bool isBookmarked;
  final List<dynamic> reactions;
  final int hasComment;
  final List<dynamic> comments;
  final dynamic voteRecord;

  BlogDetail({
    required int id,
    required String title,
    required String slug,
    required String summary,
    required String content,
    required int catId,
    required String photo,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String userId,
    required String authorName,
    required String authorPhoto,
    required String authorId,
    required int countBookmarked,
    required int countLike,
    required int countComment,
    required List<String> tags,
    required this.isBookmarked,
    required this.reactions,
    required this.hasComment,
    required this.comments,
    required this.voteRecord,
  }) : super(
          id: id,
          title: title,
          slug: slug,
          summary: summary,
          content: content,
          catId: catId,
          photo: photo,
          createdAt: createdAt,
          updatedAt: updatedAt,
          userId: userId,
          authorName: authorName,
          authorPhoto: authorPhoto,
          authorId: authorId,
          countBookmarked: countBookmarked,
          countLike: countLike,
          countComment: countComment,
          tags: tags,
        );

  factory BlogDetail.fromJson(Map<String, dynamic> json) {
    final tuongtac = json['tuongtac'] ?? {};
    List<String> tagsList = [];
    if (json['tags'] != null) {
      if (json['tags'] is String) {
        try {
          final List<dynamic> decodedTags = jsonDecode(json['tags']);
          tagsList = decodedTags.map((tag) => tag.toString()).toList();
        } catch (e) {
          tagsList = [json['tags'].toString()];
        }
      } else if (json['tags'] is List) {
        tagsList = List<String>.from(json['tags']);
      }
    }
    String photo = json['photo'] ?? '';
    if (photo.startsWith('http://127.0.0.1:8000/')) {
      photo =
          photo.replaceFirst('http://127.0.0.1:8000/', 'http://10.0.2.2:8000/');
    }
    return BlogDetail(
      id: int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      summary: json['summary'] ?? '',
      content: json['content'] ?? '',
      catId: json['cat_id'] ?? 0,
      photo: json['photo'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      userId: json['user_id']?.toString() ?? '',
      authorName: json['author_name'] ?? '',
      authorPhoto: json['author_photo'] ?? '',
      authorId: json['author_id']?.toString() ?? '',
      countBookmarked: tuongtac['countBookmarked'] ?? 0,
      countLike: tuongtac['countLike'] ?? 0,
      countComment: tuongtac['countComment'] ?? 0,
      tags: tagsList,
      isBookmarked: tuongtac['isBookmarked'] ?? false,
      reactions: tuongtac['reactions'] ?? [],
      hasComment: tuongtac['hasComment'] ?? 0,
      comments: tuongtac['comments'] ?? [],
      voteRecord: tuongtac['voteRecord'],
    );
  }
}
