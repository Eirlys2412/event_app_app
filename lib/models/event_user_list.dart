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
    return EventUser(
      id: json['id'],
      userId: json['user_id'],
      eventId: json['event_id'],
      roleId: json['role_id'],
      voteCount: json['vote_count'],
      voteScore: json['vote_score'],
      user: User.fromJson(json['user']),
      event: Event.fromJson(json['event']),
      role: Role.fromJson(json['role']),
    );
  }
}

class User {
  final int id;
  final String fullName;
  final String email;
  final String photo;
  final String phone;
  final String role;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.photo,
    required this.phone,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['full_name'],
      email: json['email'],
      photo: json['photo'],
      phone: json['phone'],
      role: json['role'],
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
      id: json['id'],
      title: json['title'],
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
      id: json['id'],
      title: json['title'],
    );
  }
}
