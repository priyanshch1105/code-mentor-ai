class LoginRequest {
  final String username;
  final String password;

  LoginRequest({required this.username, required this.password});

  Map<String, dynamic> toFormData() => {
        'username': username,
        'password': password,
      };
}
