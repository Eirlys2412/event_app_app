import 'package:event_app/models/event.dart';

class Detailevent extends Event {
  final int? ticket_Price;
  final int? available_ticket;

  Detailevent({
    required super.id,
    required super.title,
    super.summary,
    super.description,
    super.resources,
    super.timestart,
    super.timeend,
    super.diadiem,
    super.eventTypeId,
    super.tags,
    super.createdAt,
    super.updatedAt,
    this.ticket_Price,
    this.available_ticket,
  });

  factory Detailevent.fromjson(Map<String, dynamic> json) {
    return Detailevent(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      summary: json['summary'],
      description: json['description'],
      resources: json['resources'],
      timestart:
          json['timestart'] != null ? DateTime.parse(json['timestart']) : null,
      timeend: json['timeend'] != null ? DateTime.parse(json['timeend']) : null,
      diadiem: json['diadiem'],
      eventTypeId: json['event_type_id'],
      tags: json['tags'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      ticket_Price: json['ticket_price'],
      available_ticket: json['available_ticket'],
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
