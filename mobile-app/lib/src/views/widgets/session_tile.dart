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
      contentPadding: EdgeInsets.zero,
      title: Text(topic, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(time),
      trailing: Chip(label: Text(tag)),
    );
  }
}
