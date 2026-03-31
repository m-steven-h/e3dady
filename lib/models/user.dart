// lib/models/user.dart
class User {
  final int id;
  final String name;
  final String role;
  final String gender;
  final String grade;
  final String status;

  User({
    required this.id,
    required this.name,
    required this.role,
    required this.gender,
    required this.grade,
    required this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      role: json['role'],
      gender: json['gender'],
      grade: json['grade'].toString(),
      status: json['status'],
    );
  }
}

// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class ApiService {
  static const String baseUrl = 'http://your-server.com/api'; // استبدل بالرابط الحقيقي
  
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('فشل الاتصال بالخادم');
    }
  }
  
  Future<Map<String, dynamic>> get(String endpoint, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('فشل جلب البيانات');
    }
  }
}

// lib/services/auth_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../models/user.dart';

class AuthService {
  final SharedPreferences _prefs;
  final ApiService _apiService;
  
  AuthService(this._prefs, this._apiService);
  
  Future<bool> login(String username, String password) async {
    try {
      final response = await _apiService.post('login.php', {
        'username': username,
        'password': password,
      });
      
      if (response['success'] == true) {
        await _prefs.setBool('isLoggedIn', true);
        await _prefs.setString('token', response['token']);
        await _prefs.setString('userName', username);
        await _prefs.setString('userRole', response['role']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> register({
    required String username,
    required String password,
    required String grade,
    required String gender,
  }) async {
    try {
      final response = await _apiService.post('register.php', {
        'username': username,
        'password': password,
        'grade': grade,
        'gender': gender,
      });
      
      return response['success'] == true;
    } catch (e) {
      return false;
    }
  }
  
  Future<User> getCurrentUser() async {
    final token = _prefs.getString('token');
    if (token == null) throw Exception('غير مسجل دخول');
    
    final response = await _apiService.get('get_user.php', token);
    return User.fromJson(response['user']);
  }
  
  Future<void> logout() async {
    await _prefs.clear();
  }
}