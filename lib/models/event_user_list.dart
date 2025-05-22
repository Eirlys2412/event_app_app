import '../utils/url_utils.dart';

class EventUser {
  final int id;
  final int userId;
  final int eventId;
  final int roleId;
  final int voteCount;
  final int voteScore;
  final User user;
  final Event event;
  final Role role;

  EventUser({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.roleId,
    required this.voteCount,
    required this.voteScore,
    required this.user,
    required this.event,
    required this.role,
  });

  factory EventUser.fromJson(Map<String, dynamic> json) {
    String photo = json['photo'] ?? '';
    photo = fixImageUrl(photo);
    return EventUser(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      eventId: json['event_id'] ?? 0,
      roleId: json['role_id'] ?? 0,
      voteCount: json['vote_count'] ?? 0,
      voteScore: json['vote_score'] ?? 0,
      user: User.fromJson(json['user'] ?? {}),
      event: Event.fromJson(json['event'] ?? {}),
      role: Role.fromJson(json['role'] ?? {}),
    );
  }
}

class User {
  final int id;
  final String fullName;
  final String email;
  final String? photo;
  final String? phone;
  final String? role;
  final String? address;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    this.photo,
    this.phone,
    this.role,
    this.address,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      photo: json['photo'],
      phone: json['phone'],
      role: json['role'],
      address: json['address'],
    );
  }
}

class Event {
  final int id;
  final String title;

  Event({
    required this.id,
    required this.title,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
    );
  }
}

class Role {
  final int id;
  final String title;

  Role({
    required this.id,
    required this.title,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
    );
  }
}
