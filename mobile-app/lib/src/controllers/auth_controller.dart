import '../models/repository.dart';

class AuthController {
  AuthController._();

  static final AuthController instance = AuthController._();

  final AppRepository _repository = AppRepository();

  Future<UserProfile> loadCurrentUser() async {
    return _repository.fetchMe();
  }

  Future<UserProfile?> getCachedUser() async {
    return _repository.getCachedProfile();
  }

  Future<bool> hasToken() async {
    final token = await _repository.getStoredToken();
    return token != null && token.isNotEmpty;
  }

  Future<UserProfile> login({
    required String username,
    required String password,
  }) async {
    await _repository.login(LoginRequest(username: username, password: password));
    return _repository.fetchMe();
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    await _repository.register(
      SignupRequest(username: username, email: email, password: password),
    );
  }

  Future<void> logout() async {
    await _repository.clearSession();
  }

  Future<void> selectSubject(String subject) {
    return _repository.selectSubject(subject);
  }
}
