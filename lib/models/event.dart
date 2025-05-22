class Event {
  final int id;
  final String title;
  final String description;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final String? photo;
  final List<Map<String, dynamic>>? resourcesData;
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
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      photo: photoUrl.isNotEmpty ? photoUrl : null,
      resourcesData: json['resources_data'] != null
          ? List<Map<String, dynamic>>.from(json['resources_data'] as List)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
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
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
