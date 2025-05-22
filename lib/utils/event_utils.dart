String fixImageUrl(String? url) {
  if (url == null || url.isEmpty) return '';
  if (url.contains('127.0.0.1')) {
    return url.replaceFirst('127.0.0.1', '10.0.2.2');
  }
  if (url.contains('localhost')) {
    return url.replaceFirst('localhost', '10.0.2.2');
  }
  return url;
}

Map<String, dynamic> normalizeEvent(Map<String, dynamic> event) {
  final normalized = Map<String, dynamic>.from(event);

  // Đồng bộ key
  normalized['diadiem'] = event['diadiem'] ?? event['location'];
  normalized['location'] = event['location'] ?? event['diadiem'];

  // Chuẩn hóa resource ảnh
  if (event['resources_data'] != null && event['resources_data'] is List) {
    normalized['resources_data'] = (event['resources_data'] as List).map((item) {
      final newItem = Map<String, dynamic>.from(item);
      newItem['url'] = fixImageUrl(newItem['url']);
      return newItem;
    }).toList();
  }

  // Trường photo phụ nếu có
  if (event['photo'] != null) {
    normalized['photo'] = fixImageUrl(event['photo']);
  }

  return normalized;
}
