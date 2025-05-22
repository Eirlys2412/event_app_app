class MyEventRegistration {
  final int id;
  final int eventId;
  final int userId;
  final String status;
  final String? reason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Event event;
  final Role role;

  MyEventRegistration({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.status,
    this.reason,
    required this.createdAt,
    required this.updatedAt,
    required this.event,
    required this.role,
  });

  factory MyEventRegistration.fromJson(Map<String, dynamic> json) {
    try {
      return MyEventRegistration(
        id: json['id'],
        eventId: json['event_id'],
        userId: json['user_id'],
        status: json['status'],
        reason: json['reason'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
        event: json['event'] != null
            ? Event.fromJson(json['event'])
            : Event.empty(),
        role: (json['role'] != null && json['role'] is Map<String, dynamic>)
            ? Role.fromJson(json['role'])
            : Role.empty(),
      );
    } catch (e) {
      print('Lỗi parse MyEventRegistration: $e, data: $json');
      rethrow;
    }
  }
}

class Event {
  final int id;
  final String title;
  final String? slug;
  final String? summary;
  final String? description;
  final String? resources;
  final String? timestart;
  final String? timeend;
  final String? diadiem;

  Event({
    required this.id,
    required this.title,
    this.slug,
    this.summary,
    this.description,
    this.resources,
    this.timestart,
    this.timeend,
    this.diadiem,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    String photo = json['photo'] ?? '';
    if (photo.startsWith('http://127.0.0.1:8000/')) {
      photo =
          photo.replaceFirst('http://127.0.0.1:8000/', 'http://10.0.2.2:8000/');
    }
    return Event(
      id: json['id'],
      title: json['title'],
      slug: json['slug'],
      summary: json['summary'],
      description: json['description'],
      resources: json['resources'],
      timestart: json['timestart'],
      timeend: json['timeend'],
      diadiem: json['diadiem'],
    );
  }

  Event.empty()
      : id = 0,
        title = '',
        slug = null,
        summary = null,
        description = null,
        resources = null,
        timestart = null,
        timeend = null,
        diadiem = null;
}

class Role {
  final int id;
  final String? alias;
  final String? title;

  Role({
    required this.id,
    this.alias,
    this.title,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      alias: json['alias'],
      title: json['title'],
    );
  }

  Role.empty()
      : id = 0,
        alias = null,
        title = null;
}
