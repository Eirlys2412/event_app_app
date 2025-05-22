import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_profile.dart';
import '../screen/event_profile_screen.dart';

class UserNameWidget extends ConsumerWidget {
  final int userId;
  final TextStyle? style;

  const UserNameWidget({super.key, required this.userId, this.style});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider(userId));
    return userAsync.when(
      data: (user) {
        print('User data: $user');
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EventUserProfileScreen(userId: userId),
              ),
            );
          },
          child: Text(
            user.full_Name ?? 'Không rõ tên',
            style: style ??
                const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
          ),
        );
      },
      loading: () => const SizedBox(
        width: 60,
        height: 16,
        child: LinearProgressIndicator(),
      ),
      error: (err, _) => const Text('Không rõ tên'),
    );
  }
}
