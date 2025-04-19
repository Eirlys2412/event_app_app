class EventMember {
  final int id;
  final int userId;
  final int eventId;

  EventMember({
    required this.id,
    required this.userId,
    required this.eventId,
  });

  // Tạo EventMember từ JSON
  factory EventMember.fromJson(Map<String, dynamic> json) {
    return EventMember(
      id: json['id'],
      userId: json['user_id'],
      eventId: json['event_id'],
    );
  }

  // Convert EventMember thành JSON (nếu cần gửi đi)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'event_id': eventId,
    };
  }
}
