class Ticket {
  final int id;
  final int eventId;
  final String type;
  final double price;
  final int quantity;
  final String? description;

  Ticket({
    required this.id,
    required this.eventId,
    required this.type,
    required this.price,
    required this.quantity,
    this.description,
  });
}
  // Dữ liệu mẫu tĩnh
  