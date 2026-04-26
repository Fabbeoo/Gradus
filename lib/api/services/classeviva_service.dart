import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../api_config.dart';
import '../models/login_model.dart';
import '../models/voto_remoto_model.dart';
import '../models/lezione_remota_model.dart';
import '../models/agenda_remota_model.dart';

/// Service that handles all communication with the ClasseViva API.
/// Credentials are stored in Hive (Dart-native, no Swift plugins).
/// The token is refreshed automatically when expired.
class ClasseVivaService {
  static final ClasseVivaService _instance = ClasseVivaService._();
  factory ClasseVivaService() => _instance;

  ClasseVivaService._() {
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  final _dio = Dio();

  static const _boxName = 'impostazioni';
  static const _keyToken = 'cv_token';
  static const _keyExpire = 'cv_expire';
  static const _keyStudentId = 'cv_student_id';
  static const _keyUsername = 'cv_username';
  static const _keyPassword = 'cv_password';
  static const _keyFirstName = 'cv_first_name';
  static const _keyLastName = 'cv_last_name';

  Box get _box => Hive.box(_boxName);

  /// Returns true if the user has saved credentials.
  Future<bool> isLoggedIn() async {
    final token = _box.get(_keyToken, defaultValue: '');
    return token != null && token.isNotEmpty;
  }

  /// Returns the stored student full name, or null if not logged in.
  Future<String?> getNomeStudente() async {
    final first = _box.get(_keyFirstName);
    final last = _box.get(_keyLastName);
    if (first == null || last == null) return null;
    return '$first $last';
  }

  /// Logs in with the given credentials and stores the token in Hive.
  Future<LoginResponse> login(String username, String password) async {
    try {
      // Step 1: get PHP session cookie
      final phpDio = Dio();
      phpDio.options.followRedirects = true;

      final phpResponse = await phpDio.post(
        'https://web.spaggiari.eu/auth-p7/app/default/AuthApi4.php?a=aLoginPwd',
        data: {'uid': username, 'pwd': password},
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      String? sessionCookie;
      final cookies = phpResponse.headers.map['set-cookie'];
      if (cookies != null && cookies.isNotEmpty) {
        sessionCookie = cookies.first;
      }

      // Step 2: REST login
      final headers = <String, dynamic>{
        'Content-Type': 'application/json',
        'User-Agent': ApiConfig.userAgent,
        'Z-Dev-Apikey': ApiConfig.apiKey,
        'Z-Auth-Token': '',
      };
      if (sessionCookie != null) {
        headers['Cookie'] = sessionCookie;
      }

      final response = await _dio.post(
        '${ApiConfig.baseUrl}${ApiConfig.loginPath}',
        data: {
          'ident': username,
          'pass': password,
          'uid': username,
          'cid': '',
          'pin': '',
          'target': '',
        },
        options: Options(
          headers: headers,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      debugPrint('REST login status: ${response.statusCode}');
      debugPrint('FULL LOGIN RESPONSE: ${response.data}');

      if (response.statusCode != 200) {
        throw Exception('Login fallito: ${response.data}');
      }

      final loginResponse = LoginResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      // Store credentials in Hive
      await _box.put(_keyToken, loginResponse.token);
      await _box.put(_keyExpire, loginResponse.expire.toIso8601String());
      await _box.put(_keyStudentId, loginResponse.studentId);
      await _box.put(_keyUsername, username);
      await _box.put(_keyPassword, password);
      await _box.put(_keyFirstName, loginResponse.firstName);
      await _box.put(_keyLastName, loginResponse.lastName);

      return loginResponse;
    } on DioException catch (e) {
      debugPrint('DioException: ${e.type} ${e.message}');
      throw Exception('Errore di connessione: ${e.message}');
    } catch (e) {
      debugPrint('Generic error: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Logs out and clears all stored credentials from Hive.
  Future<void> logout() async {
    await _box.delete(_keyToken);
    await _box.delete(_keyExpire);
    await _box.delete(_keyStudentId);
    await _box.delete(_keyUsername);
    await _box.delete(_keyPassword);
    await _box.delete(_keyFirstName);
    await _box.delete(_keyLastName);
  }

  /// Returns a valid token, refreshing it if expired.
  Future<String> _getValidToken() async {
    final token = _box.get(_keyToken);
    if (token == null || token.isEmpty) throw Exception('Non autenticato');

    final expireStr = _box.get(_keyExpire);
    if (expireStr != null) {
      final expire = DateTime.parse(expireStr);
      if (expire.isBefore(DateTime.now())) {
        final username = _box.get(_keyUsername);
        final password = _box.get(_keyPassword);
        if (username == null || password == null) {
          throw Exception('Credenziali non trovate');
        }
        final refreshed = await login(username, password);
        return refreshed.token;
      }
    }

    return token;
  }

  /// Builds authenticated request options.
  Future<Options> _authOptions() async {
    final token = await _getValidToken();
    return Options(
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': ApiConfig.userAgent,
        'Z-Dev-Apikey': ApiConfig.apiKey,
        'Z-Auth-Token': token,
      },
    );
  }

  /// Fetches all grades for the current student.
  Future<List<VotoRemoto>> fetchVoti() async {
    final studentId = _box.get(_keyStudentId);
    if (studentId == null) throw Exception('Student ID non trovato');

    final options = await _authOptions();

    // Try grades2 first, fall back to grades
    final urls = [
      '${ApiConfig.baseUrl}/students/$studentId/grades2',
      '${ApiConfig.baseUrl}/students/$studentId/grades',
    ];

    for (final url in urls) {
      try {
        debugPrint('Fetching grades: $url');
        final response = await _dio.get(url, options: options);
        final data = response.data as Map<String, dynamic>;
        final grades = data['grades'] as List<dynamic>? ?? [];

        final result = grades
            .map((g) => VotoRemoto.fromJson(g as Map<String, dynamic>))
            .where((v) => v.decimalValue > 0)
            .toList();

        debugPrint('Total grades received: ${grades.length}');
        debugPrint('Grades after filter: ${result.length}');

        return result;
      } on DioException catch (e) {
        debugPrint(
          'Failed $url: ${e.response?.statusCode} ${e.response?.data}',
        );
      }
    }

    return [];
  }

  ///
  ///
  /// Fetches the timetable for the current week.
  Future<List<LesioneRemota>> fetchOrario() async {
    final studentId = _box.get(_keyStudentId);
    if (studentId == null) throw Exception('Student ID non trovato');

    final options = await _authOptions();

    // Fetch lessons for the entire current school year
    // to build a representative weekly timetable
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));

    final fromStr =
        '${monday.year}${monday.month.toString().padLeft(2, '0')}${monday.day.toString().padLeft(2, '0')}';
    final toStr =
        '${sunday.year}${sunday.month.toString().padLeft(2, '0')}${sunday.day.toString().padLeft(2, '0')}';

    final url =
        '${ApiConfig.baseUrl}/students/$studentId/lessons/$fromStr/$toStr';
    debugPrint('Fetching lessons: $url');

    final response = await _dio.get(url, options: options);
    debugPrint('Lessons response keys: ${(response.data as Map).keys}');

    final data = response.data as Map<String, dynamic>;
    final lessons = data['lessons'] as List<dynamic>? ?? [];

    return lessons
        .map((s) => LesioneRemota.fromJson(s as Map<String, dynamic>))
        .toList();
  }

  /// Fetches agenda events for a date range.
  Future<List<AgendaRemota>> fetchAgenda({
    required DateTime from,
    required DateTime to,
  }) async {
    final studentId = _box.get(_keyStudentId);
    if (studentId == null) throw Exception('Student ID non trovato');

    final options = await _authOptions();
    final fromStr =
        '${from.year}${from.month.toString().padLeft(2, '0')}${from.day.toString().padLeft(2, '0')}';
    final toStr =
        '${to.year}${to.month.toString().padLeft(2, '0')}${to.day.toString().padLeft(2, '0')}';

    final url =
        '${ApiConfig.baseUrl}/students/$studentId/agenda/all/$fromStr/$toStr';
    debugPrint('Fetching agenda: $url');

    final response = await _dio.get(url, options: options);
    final data = response.data as Map<String, dynamic>;
    final events = data['agenda'] as List<dynamic>? ?? [];

    return events
        .map((e) => AgendaRemota.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
