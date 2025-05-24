import 'package:event_app/models/like.dart';

import 'user.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class Comment {
  final int id;
  final int itemId;
  final String itemCode;
  final int userId;
  final String content;
  final int? parentId;
  final String? commentResources;
  final String createdAt;
  final String updatedAt;
  final User user;
  final List<Like> likes;
  final List<Comment> replies;

  bool is_liked;
  int likes_count;

  // Getter để lấy URL ảnh đầy đủ
  String? get commentResourcesUrl {
    if (commentResources == null || commentResources!.isEmpty) {
      return null;
    }

    // Xác định base URL dựa trên môi trường
    String baseUrl;
    if (kIsWeb) {
      // Web
      baseUrl = 'http://127.0.0.1:8000';
    } else if (Platform.isAndroid && !kReleaseMode) {
      // Android emulator trong chế độ debug
      baseUrl = 'http://10.0.2.2:8000';
    } else if (Platform.isIOS && !kReleaseMode) {
      // iOS simulator trong chế độ debug
      baseUrl = 'http://192.168.94.41:8000';
    } else {
      // Thiết bị thật hoặc chế độ release - sử dụng URL production
      baseUrl = 'http://192.168.94.41:8000'; // Thay thế bằng URL thực tế của bạn
    }

    return '$baseUrl/storage/$commentResources';
  }

  Comment({
    required this.id,
    required this.itemId,
    required this.itemCode,
    required this.userId,
    required this.content,
    this.parentId,
    this.commentResources,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.likes,
    required this.replies,
    this.is_liked = false,
    this.likes_count = 0,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? 0,
      itemId: json['item_id'] ?? 0,
      itemCode: json['item_code'] ?? '',
      userId: json['user_id'] ?? 0,
      content: json['content'] ?? '',
      parentId: json['parent_id'],
      commentResources: json['comment_resources'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
      likes: (json['likes'] as List<dynamic>? ?? [])
          .map((likeJson) => Like.fromJson(likeJson))
          .toList(),
      replies: (json['replies'] as List<dynamic>? ?? [])
          .map((replyJson) => Comment.fromJson(replyJson))
          .toList(),
      is_liked: json['is_liked'] ?? false,
      likes_count: json['likes_count'] ?? 0,
    );
  }
}
