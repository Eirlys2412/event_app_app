String fixImageUrl(String? url) {
  if (url == null || url.isEmpty) {
    return 'https://via.placeholder.com/150';
  }
  if (url.contains('127.0.0.1')) {
    return url.replaceFirst('127.0.0.1', '10.0.2.2');
  }
  if (url.contains('localhost')) {
    return url.replaceFirst('localhost', '10.0.2.2');
  }
  return url;
}

String getFullPhotoUrl(String? url) {
  // 1. Xử lý trường hợp URL rỗng hoặc null
  if (url == null || url.isEmpty || url == 'null') {
    return 'http://10.0.2.2:8000/storage/uploads/resources/default.png'; // URL mặc định
  }

  String processedUrl = url.trim(); // Loại bỏ khoảng trắng

  // 2. Xử lý trường hợp URL đã đầy đủ (bắt đầu bằng http)
  if (processedUrl.startsWith('http')) {
    // Chuẩn hóa: thay thế các dấu gạch chéo kép (không nằm sau http:) bằng một dấu gạch chéo đơn
    processedUrl = processedUrl.replaceAll(RegExp(r'(?<!:)/{2,}'), '/');

    // Fix repeated storage segment if present (e.g., http://.../storage/storage/...)
    processedUrl = processedUrl.replaceFirst('/storage/storage/', '/storage/');

    // Handle emulator address
    processedUrl = processedUrl.replaceFirst('127.0.0.1', '10.0.2.2');

    return processedUrl; // Trả về URL đã xử lý
  } else {
    // 3. Xử lý đường dẫn tương đối (nếu không bắt đầu bằng http)
    // Loại bỏ dấu gạch chéo ở đầu nếu có
    if (processedUrl.startsWith('/')) {
      processedUrl = processedUrl.substring(1);
    }

    // Chuẩn hóa: thay thế các dấu gạch chéo kép bằng một dấu gạch chéo đơn trong đường dẫn tương đối
    processedUrl = processedUrl.replaceAll(RegExp(r'/{2,}'), '/');

    // 4. Thêm tiền tố URL cơ sở dựa trên loại đường dẫn tương đối
    // Giả định các đường dẫn bắt đầu bằng 'storage/' là tương đối với thư mục storage gốc
    if (processedUrl.startsWith('storage/')) {
      // Sử dụng 10.0.2.2 cho emulator
      return 'http://10.0.2.2:8000/' + processedUrl; // Thêm tiền tố chính xác
    } else {
      // 5. Fallback cho các đường dẫn tương đối khác (ví dụ: resource paths khác)
      // Giả định chúng là resource paths và thêm tiền tố tương ứng.
      return 'http://10.0.2.2:8000/storage/uploads/resources/' + processedUrl;
    }
  }
  // Mặc dù logic trên đã bao phủ, thêm return cuối cùng để làm hài lòng linter nếu cần (thường không cần khi có else cuối cùng)
  // return 'http://10.0.2.2:8000/storage/uploads/resources/default.png'; // Có thể uncomment nếu lỗi vẫn còn
}

String getAvatarUrl(String? avatar) {
  if (avatar != null && avatar.isNotEmpty && avatar != 'null') {
    // Use getFullPhotoUrl to handle both full URLs and relative storage paths
    return getFullPhotoUrl(avatar);
  }
  // Return a default avatar URL if the provided avatar is null, empty, or 'null'
  return 'http://10.0.2.2:8000/storage/uploads/resources/default.png'; // Default avatar path
}
