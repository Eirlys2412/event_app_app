class Like {
  final int id;
  final int userId;
  final String likeableType;
  final int likeableId;
  final String createdAt;
  final String updatedAt;

  Like({
    required this.id,
    required this.userId,
    required this.likeableType,
    required this.likeableId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Like.fromJson(Map<String, dynamic> json) {
    return Like(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      likeableType: json['likeable_type'] ?? '',
      likeableId: json['likeable_id'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}
