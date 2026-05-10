class UserProfile {
  final int id;
  final String username;
  final String email;
  final String currentSubject;
  final Map<String, dynamic> progress;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.currentSubject,
    required this.progress,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      currentSubject: json['current_subject'] ?? 'general',
      progress: Map<String, dynamic>.from(json['progress'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'current_subject': currentSubject,
        'progress': progress,
      };
}
