import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/vote_repository.dart';
import 'dart:convert';
import 'dart:ui'; // Import for VoidCallback
import './detail_event_provider.dart'; // Import detailEventProvider

class VoteStats {
  final double averageRating;
  final int totalVotes;
  final int userRating;
  final bool isVoted;

  VoteStats({
    required this.averageRating,
    required this.totalVotes,
    required this.userRating,
    required this.isVoted,
  });
}

final voteRepositoryProvider = Provider((ref) => VoteRepository());

final voteStateProvider =
    StateNotifierProviderFamily<VoteNotifier, VoteStats, Map<String, dynamic>>(
        (ref, params) {
  final double initialRating = (params['initialRating'] ?? 0.0).toDouble();
  final int initialVotes = (params['initialVotes'] ?? 0);
  final int eventId = params['id'];

  // Tạo hàm callback để refresh detailEventProvider
  void refreshDetailEvent() {
    ref.invalidate(detailEventProvider(eventId));
  }

  return VoteNotifier(ref.read(voteRepositoryProvider), params['type'], eventId,
      initialRating, initialVotes, refreshDetailEvent); // Truyền hàm callback
});

class VoteNotifier extends StateNotifier<VoteStats> {
  final VoteRepository repository;
  final String type;
  final int id;
  final VoidCallback refreshDetailEvent; // Nhận hàm callback

  VoteNotifier(
      this.repository,
      this.type,
      this.id,
      double initialRating,
      int initialVotes,
      this.refreshDetailEvent) // Nhận hàm callback qua constructor
      : super(VoteStats(
          averageRating: initialRating,
          totalVotes: initialVotes,
          userRating: 0,
          isVoted: false,
        ));

  Future<void> vote(int score) async {
    try {
      // Thêm try-catch để xử lý lỗi trong quá trình gọi API
      // Gọi API vote và nhận lại dữ liệu mới nhất
      final response = await repository.vote(type, id, score);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Yêu cầu thành công, cập nhật trạng thái tạm thời trong notifier
        final data = json.decode(response.body);
        print(
            'Vote API Success Response Data: $data'); // Log dữ liệu thành công
        state = VoteStats(
          averageRating: (data['data']['average_rating'] ?? 0.0).toDouble(),
          totalVotes: (data['data']['total_votes'] ?? 0),
          userRating: (data['data'][RatingBar] ?? score).toInt(),
          isVoted: true,
        );
        print(
            'VoteState updated to: Average Rating = ${state.averageRating}, Total Votes = ${state.totalVotes}'); // Log state mới

        // Gọi hàm callback để refresh detailEventProvider
        refreshDetailEvent();
      } else {
        // Xử lý lỗi nếu yêu cầu không thành công
        print('Vote API Error Status: ${response.statusCode}'); // Log mã lỗi
        print('Vote API Error Body: ${response.body}'); // Log phần thân lỗi

        String errorMessage = 'Đã xảy ra lỗi khi đánh giá.';
        try {
          final errorData = json.decode(response.body);
          if (errorData != null && errorData['message'] != null) {
            errorMessage = errorData['message'];
          } else {
            errorMessage = 'Lỗi không xác định từ server.';
          }
        } catch (e) {
          // Không thể parse body lỗi thành JSON
          errorMessage = 'Lỗi không xác định từ server.';
        }

        // Ném Exception để widget xử lý hiển thị SnackBar
        throw Exception(errorMessage);
      }
    } catch (e) {
      // Xử lý lỗi chung khi gọi API hoặc parse response
      print('Error during vote process: ${e.toString()}');
      throw Exception('Đã xảy ra lỗi: ${e.toString()}');
    }
  }
}
