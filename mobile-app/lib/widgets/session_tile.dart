import 'package:flutter/material.dart';

class SessionTile extends StatelessWidget {
  const SessionTile({
    super.key,
    required this.topic,
    required this.time,
    required this.tag,
  });

  final String topic;
  final String time;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
        ),
        child: Icon(Icons.play_lesson_outlined, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(topic, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(time),
      trailing: Chip(
        label: Text(tag),
        side: BorderSide.none,
        backgroundColor: const Color(0xFFE9F8EF),
      ),
    );
  }
}
