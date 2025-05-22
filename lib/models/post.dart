import 'user.dart';

class Post {
  final int id;
  final String content;
  final DateTime timestamp;
  final User user;
  final int likes;
  final int comments;
  final List<String> likedUsers;

  Post({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.user,
    required this.likes,
    required this.comments,
    required this.likedUsers,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      content: json['content'],
      timestamp: DateTime.parse(json['created_at']),
      user: User.fromJson(json['user']),
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      likedUsers: List<String>.from(json['liked_users'] ?? []),
    );
  }
}
