import 'package:event_app/models/event.dart';

class Detailevent extends Event {
  final int? ticket_Price;
  final int? available_ticket;
  final double averageRating;
  final int totalVotes;

  Detailevent({
    required int id,
    required String title,
    required String description,
    required String location,
    required DateTime startTime,
    required DateTime endTime,
    String? photo,
    List<Map<String, dynamic>>? resourcesData,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.ticket_Price,
    this.available_ticket,
    required this.averageRating,
    required this.totalVotes,
  }) : super(
          id: id,
          title: title,
          description: description,
          location: location,
          startTime: startTime,
          endTime: endTime,
          photo: photo,
          resourcesData: resourcesData,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory Detailevent.fromjson(Map<String, dynamic> json) {
    String photo = json['photo'] ?? '';
    if (photo.startsWith('http://127.0.0.1:8000/')) {
      photo =
          photo.replaceFirst('http://127.0.0.1:8000/', 'http://10.0.2.2:8000/');
    }
    return Detailevent(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      startTime: DateTime.parse(
          json['start_time'] ?? DateTime.now().toIso8601String()),
      endTime:
          DateTime.parse(json['end_time'] ?? DateTime.now().toIso8601String()),
      photo: json['photo'],
      resourcesData: json['resources_data'] != null
          ? List<Map<String, dynamic>>.from(json['resources_data'] as List)
          : null,
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
      ticket_Price: json['ticket_price'],
      available_ticket: json['available_ticket'],
      averageRating: (json['average_rating'] ?? 0.0).toDouble(),
      totalVotes: (json['total_votes'] ?? 0),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Detailevent) return false;
    return id == other.id &&
        title == other.title &&
        ticket_Price == other.ticket_Price &&
        available_ticket == other.available_ticket;
  }

  @override
  int get hashCode => Object.hash(id, title, ticket_Price, available_ticket);

  Map<String, dynamic> toJson() {
    final base = super.toJson();
    return {
      ...base,
      'ticket_price': ticket_Price,
      'available_ticket': available_ticket,
    };
  }
}
