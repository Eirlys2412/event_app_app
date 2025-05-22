import 'package:flutter/material.dart';

class AppTemplate extends StatelessWidget {
  final Widget mainContent;
  final Widget? floatingActionButton;
  final bool showAppBar;
  final String title;

  const AppTemplate({
    Key? key,
    required this.mainContent,
    this.floatingActionButton,
    this.showAppBar = true,
    this.title = 'Event App',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: Text(title),
              backgroundColor: const Color(0xFF6A62B7),
            )
          : null,
      body: mainContent,
      floatingActionButton: floatingActionButton,
    );
  }
}
