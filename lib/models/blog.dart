import 'dart:convert';

class Tag {
  final int id;
  final String slug;
  final String title;

  Tag({
    required this.id,
    required this.slug,
    required this.title,
  });
  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as int,
      slug: json['slug'] as String,
      title: json['title'] as String,
    );
  }
}

class Blog {
  final int id;
  final String title;
  final String slug;
  final int hit;
  final String? photo;
  final String summary;
  final String content;
  final int catId;
  final int userId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;

  Blog({
    required this.id,
    required this.title,
    required this.slug,
    required this.hit,
    this.photo,
    required this.summary,
    required this.content,
    required this.catId,
    required this.userId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.tags,
  });

  factory Blog.fromJson(Map<String, dynamic> json) {
    String photo = json['photo'] ?? '';
    if (photo.startsWith('http://127.0.0.1:8000/')) {
      photo =
          photo.replaceFirst('http://127.0.0.1:8000/', 'http://10.0.2.2:8000/');
    }
    return Blog(
      id: json['id'] as int,
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      hit: json['hit'] ?? 0,
      photo: json['photo'],
      summary: json['summary'] ?? '',
      content: json['content'] ?? '',
      catId: json['cat_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      tags: json['tags'] is String
          ? List<String>.from(jsonDecode(json['tags']))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'hit': hit,
      'photo': photo,
      'summary': summary,
      'content': content,
      'cat_id': catId,
      'user_id': userId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'tags': jsonEncode(tags),
    };
  }
}
