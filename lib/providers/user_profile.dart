import 'package:event_app/models/user_profile.dart';
import 'package:event_app/repositories/user_profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider cho repository (không cần token)
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

// Provider lấy hồ sơ người dùng
final userProfileProvider =
    FutureProvider.family<UserModel, int>((ref, userId) async {
  final repository = ref.read(userRepositoryProvider);
  return repository.fetchUserProfile(userId);
});
