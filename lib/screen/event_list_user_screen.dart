import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/event_user_list_provider.dart';

class EventUserListScreen extends ConsumerWidget {
  final int eventId;
  final String eventTitle;

  const EventUserListScreen({super.key, required this.eventId, required this.eventTitle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userListAsync = ref.watch(eventUserListProvider(eventId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Thành viên: $eventTitle'),
      ),
      body: userListAsync.when(
        data: (users) => ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              title: Text(user.user.fullName ?? 'Không rõ'),
              subtitle: Text(user.role.title ?? ''),
              leading: const Icon(Icons.person),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Lỗi: $err')),
      ),
    );
  }
}
