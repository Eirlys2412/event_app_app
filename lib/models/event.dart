class Event {
  final int id;
  final String title;
  final String description;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final String? photo;
  final List<Map<String, dynamic>>? resourcesData;
  final String? summary;
  final DateTime createdAt;
  final DateTime updatedAt;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.startTime,
    required this.endTime,
    this.photo,
    this.resourcesData,
    this.summary,
    required this.createdAt,
    required this.updatedAt,
  });

  // json to model
  factory Event.fromJson(Map<String, dynamic> json) {
    String photoUrl = json['photo'] ?? '';
    // Đổi sang 10.0.2.2 cho emulator nếu là localhost hoặc 127.0.0.1
    if (photoUrl.contains('127.0.0.1')) {
      photoUrl = photoUrl.replaceFirst('127.0.0.1', '10.0.2.2');
    }
    if (photoUrl.contains('localhost')) {
      photoUrl = photoUrl.replaceFirst('localhost', '10.0.2.2');
    }
    return Event(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Không có tiêu đề',
      description: json['description'] as String? ?? 'Không có mô tả',
      location: json['location'] as String? ?? 'Chưa rõ địa điểm',
      startTime: DateTime.tryParse(json['start_time'] as String? ?? '') ??
          DateTime.now(),
      endTime: DateTime.tryParse(json['end_time'] as String? ?? '') ??
          DateTime.now().add(const Duration(hours: 1)),
      photo: photoUrl.isNotEmpty ? photoUrl : null,
      resourcesData:
          (json['resources_data'] as List?)?.cast<Map<String, dynamic>>(),
      summary: json['summary'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  // model to json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'photo': photo,
      'resources_data': resourcesData,
      'summary': summary,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class Detailevent {
  final int id;
  final String title;
  final String summary;
  final String description;
  final String timestart;
  final String timeend;
  final String diadiem;
  final String slug;
  final String image;
  final double? averageRating;
  final int? totalVotes;
  final List<dynamic>? resources;
  final List<dynamic>? resourcesData;
  final int? userRating;
  final Map<String, int>? ratingDistribution;

  Detailevent({
    required this.id,
    required this.title,
    required this.summary,
    required this.description,
    required this.timestart,
    required this.timeend,
    required this.diadiem,
    required this.slug,
    required this.image,
    this.averageRating,
    this.totalVotes,
    this.resources,
    this.resourcesData,
    this.userRating,
    this.ratingDistribution,
  });

  factory Detailevent.fromJson(Map<String, dynamic> json) {
    // Parse rating_info nếu có
    Map<String, dynamic>? ratingInfo = json['rating_info'];
    Map<String, int>? ratingDist;
    if (ratingInfo != null && ratingInfo['rating_distribution'] != null) {
      ratingDist = Map<String, int>.from(ratingInfo['rating_distribution']);
    }

    return Detailevent(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
      description: json['description'] ?? '',
      timestart: json['timestart'] ?? '',
      timeend: json['timeend'] ?? '',
      diadiem: json['diadiem'] ?? '',
      slug: json['slug'] ?? '',
      image: json['image'] ?? '',
      averageRating: ratingInfo?['average_rating']?.toDouble(),
      totalVotes: ratingInfo?['total_votes'],
      resources: json['resources'] is List
          ? (json['resources'] as List).cast<dynamic>()
          : null,
      resourcesData: json['resources_data'] is List
          ? (json['resources_data'] as List).cast<dynamic>()
          : null,
      userRating: json['user_rating'],
      ratingDistribution: ratingDist,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'description': description,
      'timestart': timestart,
      'timeend': timeend,
      'diadiem': diadiem,
      'slug': slug,
      'image': image,
      'average_rating': averageRating,
      'total_votes': totalVotes,
      'resources': resources,
      'resources_data': resourcesData,
      'user_rating': userRating,
      'rating_distribution': ratingDistribution,
    };
  }
}
