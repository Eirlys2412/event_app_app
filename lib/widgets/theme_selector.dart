import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';

class ThemeSelector extends ConsumerWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return PopupMenuButton<String>(
      icon: const Icon(Icons.palette),
      itemBuilder: (context) => themeState.themePresets.keys.map((themeName) {
        return PopupMenuItem<String>(
          value: themeName,
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      themeState.themePresets[themeName]![0],
                      themeState.themePresets[themeName]![1],
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text(themeName),
            ],
          ),
        );
      }).toList(),
      onSelected: (themeName) {
        ref.read(themeProvider.notifier).changeTheme(themeName);
      },
    );
  }
}
