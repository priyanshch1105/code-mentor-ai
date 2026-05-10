class AuthResult {
  final String token;
  final String tokenType;

  AuthResult({required this.token, required this.tokenType});

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      token: json['access_token'] ?? '',
      tokenType: json['token_type'] ?? 'bearer',
    );
  }
}
