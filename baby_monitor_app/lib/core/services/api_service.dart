import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_response.dart';
import '../../features/shared/models/app_user.dart';
import '../../features/shared/models/room_model.dart';
import '../../features/shared/models/alarm_model.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api'; // Chrome
  // static const String baseUrl = 'http://192.168.1.100:8000/api'; // Android

  static String? _token;

  // Headers untuk request
  static Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  // Initialize token dari SharedPreferences
  static Future<void> initializeToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  // Save token ke SharedPreferences
  static Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Clear token
  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Generic request method
  static Future<ApiResponse<T>> _makeRequest<T>(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: _headers);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: _headers,
            body: body != null ? json.encode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: _headers,
            body: body != null ? json.encode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: _headers);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      final responseData = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (fromJson != null && responseData['data'] != null) {
          return ApiResponse<T>.success(fromJson(responseData['data']));
        } else {
          return ApiResponse<T>.success(responseData['data']);
        }
      } else {
        return ApiResponse<T>.error(
          responseData['message'] ?? 'An error occurred',
          response.statusCode,
        );
      }
    } on SocketException {
      return ApiResponse<T>.error('No internet connection');
    } catch (e) {
      return ApiResponse<T>.error('Unexpected error: $e');
    }
  }

  // ==================== AUTH ENDPOINTS ====================

  static Future<ApiResponse<AuthData>> register({
    required String name,
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await _makeRequest<AuthData>(
      'POST',
      '/register',
      body: {
        'name': name,
        'username': username,
        'email': email,
        'password': password,
        'role': role,
      },
      fromJson: (data) => AuthData.fromJson(data),
    );

    if (response.isSuccess && response.data != null) {
      await saveToken(response.data!.token);
    }

    return response;
  }

  static Future<ApiResponse<AuthData>> login({
    required String login,
    required String password,
  }) async {
    final response = await _makeRequest<AuthData>(
      'POST',
      '/login',
      body: {
        'login': login,
        'password': password,
      },
      fromJson: (data) => AuthData.fromJson(data),
    );

    if (response.isSuccess && response.data != null) {
      await saveToken(response.data!.token);
    }

    return response;
  }

  static Future<ApiResponse<String>> logout() async {
    final response = await _makeRequest<String>('POST', '/logout');

    if (response.isSuccess) {
      await clearToken();
    }

    return response;
  }

  static Future<ApiResponse<AppUser>> getProfile() async {
    return await _makeRequest<AppUser>(
      'GET',
      '/profile',
      fromJson: (data) => AppUser.fromJson(data),
    );
  }

  // ==================== ROOM ENDPOINTS ====================

  static Future<ApiResponse<List<Room>>> getRooms() async {
    return await _makeRequest<List<Room>>(
      'GET',
      '/rooms',
      fromJson: (data) =>
          (data as List).map((item) => Room.fromJson(item)).toList(),
    );
  }

  static Future<ApiResponse<Room>> createRoom({
    required String name,
    String? description,
    int? parentId,
    List<int>? caretakerIds,
  }) async {
    return await _makeRequest<Room>(
      'POST',
      '/rooms',
      body: {
        'name': name,
        'description': description,
        'parent_id': parentId,
        'caretaker_ids': caretakerIds,
      },
      fromJson: (data) => Room.fromJson(data),
    );
  }

// ==================== ALARM ENDPOINTS ====================

  static Future<ApiResponse<List<Alarm>>> getAlarms({String? status}) async {
    String endpoint = '/alarms';
    if (status != null) {
      endpoint += '?status=$status';
    }

    return await _makeRequest<List<Alarm>>(
      'GET',
      endpoint,
      fromJson: (data) =>
          (data as List).map((item) => Alarm.fromJson(item)).toList(),
    );
  }

  static Future<ApiResponse<Alarm>> triggerAlarm(int roomId) async {
    return await _makeRequest<Alarm>(
      'POST',
      '/alarms/trigger',
      body: {'room_id': roomId},
      fromJson: (data) => Alarm.fromJson(data),
    );
  }

  static Future<ApiResponse<Alarm>> acknowledgeAlarm(int alarmId) async {
    return await _makeRequest<Alarm>(
      'POST',
      '/alarms/$alarmId/acknowledge',
      fromJson: (data) => Alarm.fromJson(data),
    );
  }

  static Future<ApiResponse<List<Alarm>>> getActiveAlarmsForCaretaker() async {
    return await _makeRequest<List<Alarm>>(
      'GET',
      '/alarms/active-for-caretaker',
      fromJson: (data) =>
          (data as List).map((item) => Alarm.fromJson(item)).toList(),
    );
  }
}
