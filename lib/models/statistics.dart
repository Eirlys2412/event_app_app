import 'package:event_app/models/blog_approved.dart';
import 'package:event_app/models/comment.dart';
import 'package:event_app/models/event.dart';
import 'package:event_app/utils/url_utils.dart';
import 'dart:convert';

class OverallStats {
  final int totalEvent;
  final int totalBlogs;
  final int totalComments;
  final int totalLikes;
  final int totalVotes;
  final double averageEventRating;

  OverallStats({
    required this.totalEvent,
    required this.totalBlogs,
    required this.totalComments,
    required this.totalLikes,
    required this.totalVotes,
    required this.averageEventRating,
  });

  factory OverallStats.fromJson(Map<String, dynamic> json) {
    return OverallStats(
      totalEvent: json['total_event'] ?? 0,
      totalBlogs: json['total_blogs'] ?? 0,
      totalComments: json['total_comments'] ?? 0,
      totalLikes: json['total_likes'] ?? 0,
      totalVotes: json['total_votes'] ?? 0,
      averageEventRating: (json['average_event_rating'] ?? 0.0).toDouble(),
    );
  }
}

class Author {
  final int? id;
  final String name;
  final String? avatar;

  Author({
    required this.id,
    required this.name,
    required this.avatar,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'],
      name: json['name']?.toString() ?? 'Unknown', // Fallback if name is null
      avatar: json['avatar']?.toString(), // Keep avatar as nullable String
    );
  }
}

class TopEvent {
  final int id;
  final String title;
  final double averageRating;

  TopEvent({
    required this.id,
    required this.title,
    required this.averageRating,
  });

  factory TopEvent.fromJson(Map<String, dynamic> json) {
    return TopEvent(
      id: json['id'] ?? 0,
      title: json['title']?.toString() ?? '',
      averageRating: (json['average_rating'] ?? 0.0).toDouble(),
    );
  }
}

class TopBlog {
  final int id;
  final String title;
  final int totalLikes;
  final String? authorName; // Changed from Author? author

  TopBlog({
    required this.id,
    required this.title,
    required this.totalLikes,
    required this.authorName, // Changed from author
  });

  factory TopBlog.fromJson(Map<String, dynamic> json) {
    return TopBlog(
      id: json['id'] ?? 0,
      title: json['title']?.toString() ?? '',
      totalLikes: json['total_likes'] ?? 0,
      authorName: json['author_name']?.toString(), // Read author_name directly
    );
  }
}

class TopComment {
  final int id;
  final String content;
  final int totalLikes;
  final String? authorName; // Changed from Author? author

  TopComment({
    required this.id,
    required this.content,
    required this.totalLikes,
    required this.authorName, // Changed from author
  });

  factory TopComment.fromJson(Map<String, dynamic> json) {
    return TopComment(
      id: json['id'] ?? 0,
      content: json['content']?.toString() ?? '',
      totalLikes: json['total_likes'] ?? 0,
      authorName: json['author_name']?.toString(), // Read author_name directly
    );
  }
}

class TopEventImage {
  final int id;
  final String title; // Assuming title exists for images too based on your data
  final String? url; // URL can be null
  final int totalLikes;
  final String? authorName; // Changed from Author? author

  TopEventImage({
    required this.id,
    required this.title,
    required this.url,
    required this.totalLikes,
    required this.authorName, // Changed from author
  });

  factory TopEventImage.fromJson(Map<String, dynamic> json) {
    return TopEventImage(
      id: json['id'] ?? 0,
      title: json['title']?.toString() ?? 'Image', // Fallback title
      url: json['url']?.toString(), // Keep url as nullable String
      totalLikes: json['total_likes'] ?? 0,
      authorName: json['author_name']?.toString(), // Read author_name directly
    );
  }
}

class StatisticsData {
  final List<TopEvent> topEvent;
  final List<TopBlog> topBlogs;
  final List<TopComment> topComments;
  final List<TopEventImage> topEventImages;
  final OverallStats overallStats;

  StatisticsData({
    required this.topEvent,
    required this.topBlogs,
    required this.topComments,
    required this.topEventImages,
    required this.overallStats,
  });

  factory StatisticsData.fromJson(Map<String, dynamic> json) {
    return StatisticsData(
      topEvent: (json['top_event'] as List?)
              ?.map((e) => e != null
                  ? TopEvent.fromJson(e as Map<String, dynamic>)
                  : null)
              .whereType<TopEvent>()
              .toList() ??
          [],
      topBlogs: (json['top_blogs'] as List?)
              ?.map((e) => e != null
                  ? TopBlog.fromJson(e as Map<String, dynamic>)
                  : null)
              .whereType<TopBlog>()
              .toList() ??
          [],
      topComments: (json['top_comments'] as List?)
              ?.map((e) => e != null
                  ? TopComment.fromJson(e as Map<String, dynamic>)
                  : null)
              .whereType<TopComment>()
              .toList() ??
          [],
      topEventImages: (json['top_event_images'] as List?)
              ?.map((e) => e != null
                  ? TopEventImage.fromJson(e as Map<String, dynamic>)
                  : null)
              .whereType<TopEventImage>()
              .toList() ??
          [],
      overallStats: OverallStats.fromJson(json['overall_stats'] ?? {}),
    );
  }
}

class StatisticsResponse {
  final bool success;
  final StatisticsData? data; // Data can be null if success is false

  StatisticsResponse({
    required this.success,
    required this.data,
  });

  factory StatisticsResponse.fromJson(Map<String, dynamic> json) {
    return StatisticsResponse(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? StatisticsData.fromJson(json['data'] ?? {})
          : null,
    );
  }
}
