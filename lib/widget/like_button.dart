import 'package:flutter/material.dart';

class ReactionButton extends StatefulWidget {
  final bool isReacted;
  final int count;
  final Function(bool) onReact;

  const ReactionButton({
    super.key,
    required this.isReacted,
    required this.count,
    required this.onReact,
  });

  @override
  State<ReactionButton> createState() => _ReactionButtonState();
}

class _ReactionButtonState extends State<ReactionButton> {
  late bool reacted;
  late int count;

  @override
  void initState() {
    super.initState();
    reacted = widget.isReacted;
    count = widget.count;
  }

  void toggleReaction() {
    setState(() {
      reacted = !reacted;
      count += reacted ? 1 : -1;
    });
    widget.onReact(reacted);
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: toggleReaction,
      icon: Icon(
        reacted ? Icons.favorite : Icons.favorite_border,
        color: reacted ? Colors.deepPurple : Colors.grey,
      ),
      label: Text('$count'),
    );
  }
}
