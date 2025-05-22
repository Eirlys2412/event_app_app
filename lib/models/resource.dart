class Resource {
  final int id;
  final String title;
  final String fileName;
  final String fileType;
  final String url;
  final String typeCode;

  Resource({
    required this.id,
    required this.title,
    required this.fileName,
    required this.fileType,
    required this.url,
    required this.typeCode,
  });

  // Tạo từ JSON
  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['id'] as int,
      title: json['title'] as String,
      fileName: json['file_name'] as String,
      fileType: json['file_type'] as String,
      url: json['url'] as String,
      typeCode: json['type_code'] as String,
    );
  }

  // Chuyển về JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'file_name': fileName,
      'file_type': fileType,
      'url': url,
      'type_code': typeCode,
    };
  }
}
