import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/blog.dart';

/// Model để lưu trạng thái của AppBar
class AppBarState {
  final String appTitle;
  final String subtitle;
  final bool isLoading;
  final List<String> tags; // Danh sách tags là List<String>

  AppBarState({
    required this.appTitle,
    required this.subtitle,
    this.isLoading = false,
    List<String>? tags, // Cho phép truyền danh sách tag dưới dạng List<String>
  }) : tags = tags ??
            []; // Gán giá trị mặc định là danh sách rỗng nếu không truyền

  // Copy với các giá trị được cập nhật
  AppBarState copyWith({
    String? appTitle,
    String? subtitle,
    bool? isLoading,
    List<String>? tags, // Cập nhật theo kiểu List<String>
  }) {
    return AppBarState(
      appTitle: appTitle ?? this.appTitle,
      subtitle: subtitle ?? this.subtitle,
      isLoading: isLoading ?? this.isLoading,
      tags: tags ?? this.tags,
    );
  }
}

/// Notifier để quản lý trạng thái AppBar
class AppBarStateNotifier extends StateNotifier<AppBarState> {
  AppBarStateNotifier()
      : super(AppBarState(appTitle: "app_title", subtitle: "subtitle"));

  /// Cập nhật tiêu đề
  void updateTitle(String title, String subtitle) {
    state = state.copyWith(appTitle: title, subtitle: subtitle);
  }

  /// Bật trạng thái loading
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  /// Cập nhật danh sách tags
  void setTags(List<String> tags) {
    state = state.copyWith(tags: tags);
    print('Tags updated in AppBarProvider: ${state.tags}');
  }

  /// Xóa tất cả tags
  void clearTags() {
    state = state.copyWith(tags: []);
    print('Tags cleared in state.');
  }
}

/// Provider cho AppBarStateNotifier
final appBarProvider = StateNotifierProvider<AppBarStateNotifier, AppBarState>(
  (ref) => AppBarStateNotifier(),
);
