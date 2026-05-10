class SubjectRequest {
  final String subject;

  SubjectRequest({required this.subject});

  Map<String, dynamic> toJson() => {'subject': subject};
}
