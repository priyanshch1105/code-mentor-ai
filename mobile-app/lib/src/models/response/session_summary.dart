class SessionSummary {
  final int id;
  final String name;
  final String subject;
  final DateTime? createdAt;

  SessionSummary({
    required this.id,
    required this.name,
    required this.subject,
    this.createdAt,
  });

  factory SessionSummary.fromJson(Map<String, dynamic> json) {
    return SessionSummary(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Untitled Session',
      subject: json['subject'] ?? 'general',
      createdAt: json['created_at'] == null ? null : DateTime.tryParse(json['created_at'].toString()),
    );
  }
}
