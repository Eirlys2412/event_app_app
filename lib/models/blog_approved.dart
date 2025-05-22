import 'dart:convert';

class BlogApproved {
  final int id;
  final String title;
  final String slug;
  final String summary;
  final String content;
  final int catId;
  final String photo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;
  final String authorName;
  final String authorPhoto;
  final String authorId;
  final int countBookmarked;
  final int countLike;
  final int countComment;
  final List<String> tags;

  BlogApproved({
    required this.id,
    required this.title,
    required this.slug,
    required this.summary,
    required this.content,
    required this.catId,
    required this.photo,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    required this.authorName,
    required this.authorPhoto,
    required this.authorId,
    required this.countBookmarked,
    required this.countLike,
    required this.countComment,
    required this.tags,
  });

  factory BlogApproved.fromJson(Map<String, dynamic> json) {
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

    //xử lý ảnh
    String photo = json['photo'] ?? '';
    if (photo.startsWith('http://127.0.0.1:8000/')) {
      photo =
          photo.replaceFirst('http://127.0.0.1:8000/', 'http://10.0.2.2:8000/');
    }
    return BlogApproved(
      id: json['id'],
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
      countBookmarked: json['count_bookmarked'] ?? 0,
      countLike: json['hit'] ?? 0,
      countComment: json['count_comment'] ?? 0,
      tags: tagsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'summary': summary,
      'content': content,
      'cat_id': catId,
      'photo': photo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user_id': userId,
      'author_name': authorName,
      'author_photo': authorPhoto,
      'author_id': authorId,
      'count_bookmarked': countBookmarked,
      'count_like': countLike,
      'count_comment': countComment,
      'tags': tags,
    };
  }
}

class BlogApprovedResponse {
  final bool success;
  final BlogApprovedPagination blogs;

  BlogApprovedResponse({
    required this.success,
    required this.blogs,
  });

  factory BlogApprovedResponse.fromJson(Map<String, dynamic> json) {
    return BlogApprovedResponse(
      success: json['success'] ?? false,
      blogs: BlogApprovedPagination.fromJson(json['blogs']),
    );
  }
}

class BlogApprovedPagination {
  final int currentPage;
  final List<BlogApproved> data;
  final String firstPageUrl;
  final int from;
  final int lastPage;
  final String lastPageUrl;
  final List<PageLink> links;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int to;
  final int total;

  BlogApprovedPagination({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory BlogApprovedPagination.fromJson(Map<String, dynamic> json) {
    return BlogApprovedPagination(
      currentPage: json['current_page'] ?? 1,
      data: (json['data'] as List)
          .map((item) => BlogApproved.fromJson(item))
          .toList(),
      firstPageUrl: json['first_page_url'] ?? '',
      from: json['from'] ?? 0,
      lastPage: json['last_page'] ?? 1,
      lastPageUrl: json['last_page_url'] ?? '',
      links: (json['links'] as List)
          .map((item) => PageLink.fromJson(item))
          .toList(),
      nextPageUrl: json['next_page_url'],
      path: json['path'] ?? '',
      perPage: json['per_page'] ?? 10,
      prevPageUrl: json['prev_page_url'],
      to: json['to'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}

class PageLink {
  final String? url;
  final String label;
  final bool active;

  PageLink({
    this.url,
    required this.label,
    required this.active,
  });

  factory PageLink.fromJson(Map<String, dynamic> json) {
    return PageLink(
      url: json['url'],
      label: json['label'] ?? '',
      active: json['active'] ?? false,
    );
  }
}
