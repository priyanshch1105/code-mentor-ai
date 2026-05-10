import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'request/login_request.dart';
import 'request/signup_request.dart';
import 'request/subject_request.dart';
import 'request/qa_request.dart';
import 'request/code_debug_request.dart';
import 'response/auth_result.dart';
import 'response/user_profile.dart';
import 'response/qa_result.dart';
import 'response/code_debug_result.dart';
import 'response/session_summary.dart';

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://code-mentor-ai-w3ah.onrender.com',
  );

  late final Dio client = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('auth_token');
            await prefs.remove('user_profile');
          }
          handler.next(error);
        },
      ),
    );
}

class AppRepository {
  AppRepository({Dio? client}) : _client = client ?? ApiClient.instance.client;

  final Dio _client;

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile', jsonEncode(profile.toJson()));
  }

  Future<UserProfile?> getCachedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('user_profile');
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_profile');
  }

  Future<AuthResult> register(SignupRequest request) async {
    final response = await _client.post('/api/auth/register', data: request.toJson());
    return AuthResult.fromJson({'access_token': '', 'token_type': 'bearer', ...response.data});
  }

  Future<AuthResult> login(LoginRequest request) async {
    final response = await _client.post(
      '/api/auth/login',
      data: request.toFormData(),
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    final auth = AuthResult.fromJson(response.data as Map<String, dynamic>);
    await _saveToken(auth.token);
    return auth;
  }

  Future<UserProfile> fetchMe() async {
    final response = await _client.get('/api/auth/me');
    final profile = UserProfile.fromJson(response.data as Map<String, dynamic>);
    await _saveProfile(profile);
    return profile;
  }

  Future<void> selectSubject(String subject) async {
    await _client.post('/api/auth/select-subject', data: SubjectRequest(subject: subject).toJson());
  }

  Future<QaResult> askQuestion(QaRequest request) async {
    final response = await _client.post('/api/qa', data: request.toJson());
    return QaResult.fromJson(response.data as Map<String, dynamic>);
  }

  Future<QaResult> createSessionAndAsk(QaRequest request) async {
    return askQuestion(request);
  }

  Future<CodeDebugResult> debugCode(CodeDebugRequest request) async {
    final response = await _client.post('/api/code/debug', data: request.toJson());
    return CodeDebugResult.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<SessionSummary>> fetchSessions() async {
    final response = await _client.get('/api/sessions/list');
    final data = response.data;
    final sessions = data is List ? data : <dynamic>[];
    return sessions
        .map((item) => SessionSummary.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<Map<String, dynamic>> fetchProgress() async {
    final response = await _client.get('/api/recommend/progress');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<String> fetchRecommendation({String? subject}) async {
    final response = await _client.get(
      '/api/recommend/',
      queryParameters: subject == null || subject == 'general' ? null : {'subject': subject},
    );
    return response.data['recommendations']?.toString() ?? '';
  }
}
