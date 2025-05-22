import 'package:flutter_riverpod/flutter_riverpod.dart';

// Tạo StateProvider để lưu ID của danh mục được chọn
final selectedCategoryProvider = StateProvider<int>((ref) => 1);
