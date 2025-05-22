class EventTicket {
  final int id;
  final int eventId;
  final String eventTitle;
  final String ticketType;
  final int quantity;
  final double price;
  final String status;
  final DateTime createdAt;

  EventTicket({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.ticketType,
    required this.quantity,
    required this.price,
    required this.status,
    required this.createdAt,
  });

  factory EventTicket.fromJson(Map<String, dynamic> json) {
    return EventTicket(
      id: json['id'],
      eventId: json['event_id'],
      eventTitle: json['event_title'],
      ticketType: json['ticket_type'],
      quantity: json['quantity'],
      price: json['price'].toDouble(),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
