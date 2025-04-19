import 'package:event_app/models/event.dart';
import 'package:event_app/models/user.dart';

class EventManager {
  final int id;
  final int userId;
  final String slug;

  EventManager({
    required this.id,
    required this.userId,
    required this.slug,
  });

  // Tạo Teacher từ JSON
  factory EventManager.fromJson(Map<String, dynamic> json) {
    return EventManager(
      id: json['id'],
      userId: json['user_id'],
      slug: json['slug'],
    );
  }

  // Chuyển đổi EventManager thành JSON (nếu cần gửi đi)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'slug': slug,
    };
  }
}
