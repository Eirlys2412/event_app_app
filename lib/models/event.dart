class Event {
  final int id;
  final String title;
  final String? summary;
  final String? description;
  final String? resources;
  final DateTime? timestart;
  final DateTime? timeend;
  final String? diadiem;
  final int? eventTypeId;
  final String? tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Event({
    required this.id,
    required this.title,
    this.summary,
    this.description,
    this.resources,
    this.timestart,
    this.timeend,
    this.diadiem,
    this.eventTypeId,
    this.tags,
    this.createdAt,
    this.updatedAt,
  });

  // json to model
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? 0,
      title: json['title'] ?? '', // Thêm giá trị mặc định cho title
      summary: json['summary'],
      description: json['description'],
      resources: json['resources'],
      timestart: json['timestart'] != null
          ? DateTime.tryParse(json['timestart'])
          : null,
      timeend:
          json['timeend'] != null ? DateTime.tryParse(json['timeend']) : null,
      diadiem: json['diadiem'],
      eventTypeId: json['event_type_id'],
      tags: json['tags'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  // model to json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'description': description,
      'resources': resources,
      'timestart': timestart?.toIso8601String(),
      'timeend': timeend?.toIso8601String(),
      'diadiem': diadiem,
      'event_type_id': eventTypeId,
      'tags': tags,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
