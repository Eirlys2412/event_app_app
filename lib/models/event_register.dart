class EventRegistration {
  final int id;
  final int eventId;
  final int userId;
  final String status;
  final String reason;
  final DateTime createdAt;
  final DateTime updatedAt;

  EventRegistration({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.status,
    required this.reason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EventRegistration.fromJson(Map<String, dynamic> json) {
    return EventRegistration(
      id: json['id'],
      eventId: json['event_id'],
      userId: json['user_id'],
      status: json['status'],
      reason: json['reason'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
