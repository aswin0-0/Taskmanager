import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://192.168.1.26:8000"; // Update if LAN IP changes

  // ---------- Helper: Save tokens ----------
  static Future<void> _saveTokens(String access, String refresh) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("access", access);
    await prefs.setString("refresh", refresh);
  }

  // ---------- Helper: Get tokens ----------
  static Future<String?> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("access");
  }

  static Future<String?> getRefreshToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("refresh");
  }

  // ---------- Register ----------
  static Future<Map<String, dynamic>> register(String username, String email, String password) async {
    final url = Uri.parse("$baseUrl/api/register/");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await _saveTokens(data["access"], data["refresh"]);
        return {"success": true, "data": data};
      } else {
        return {"success": false, "error": response.body};
      }
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  // ---------- Login ----------
  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    final url = Uri.parse("$baseUrl/api/token/");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveTokens(data["access"], data["refresh"]);
        return {"success": true, "data": data};
      } else {
        return {"success": false, "error": response.body};
      }
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  // ---------- Refresh Token ----------
  static Future<bool> refreshAccessToken() async {
    final refresh = await getRefreshToken();
    if (refresh == null) return false;

    final url = Uri.parse("$baseUrl/api/token/refresh/");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"refresh": refresh}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveTokens(data["access"], refresh);
        return true;
      } else {
        return false;
      }
    } catch (_) {
      return false;
    }
  }

    // ---------- Get Current User ----------
  static Future<Map<String, dynamic>> getCurrentUser() async {
    final token = await getAccessToken();
    final url = Uri.parse("$baseUrl/api/user/"); // Make sure your backend has this endpoint

    try {
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        return {"success": true, "data": jsonDecode(response.body)};
      } else if (response.statusCode == 401 && await refreshAccessToken()) {
        return await getCurrentUser(); // retry after refreshing token
      } else {
        return {"success": false, "error": response.body};
      }
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }


  // ---------- Fetch All Tasks ----------
  static Future<Map<String, dynamic>> getTasks() async {
    final token = await getAccessToken();
    final url = Uri.parse("$baseUrl/api/tasks/");
    try {
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        return {"success": true, "data": jsonDecode(response.body)};
      } else if (response.statusCode == 401 && await refreshAccessToken()) {
        return await getTasks(); // retry with new token
      } else {
        return {"success": false, "error": response.body};
      }
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  // ---------- Create Task ----------
  static Future<Map<String, dynamic>> createTask(
      Map<String, dynamic> taskData) async {
    final token = await getAccessToken();
    final url = Uri.parse("$baseUrl/api/tasks/");
    try {
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
        body: jsonEncode(taskData),
      );

      if (response.statusCode == 201) {
        return {"success": true, "data": jsonDecode(response.body)};
      } else if (response.statusCode == 401 && await refreshAccessToken()) {
        return await createTask(taskData);
      } else {
        return {"success": false, "error": response.body};
      }
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  // ---------- Delete Task ----------
  static Future<Map<String, dynamic>> deleteTask(int id) async {
    final token = await getAccessToken();
    final url = Uri.parse("$baseUrl/api/tasks/$id/");
    try {
      final response = await http.delete(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 204) {
        return {"success": true};
      } else if (response.statusCode == 401 && await refreshAccessToken()) {
        return await deleteTask(id);
      } else {
        return {"success": false, "error": response.body};
      }
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  // ---------- Mark Completed ----------
  static Future<Map<String, dynamic>> markCompleted(int id) async {
    final token = await getAccessToken();
    final url = Uri.parse("$baseUrl/api/tasks/$id/mark_completed/");
    try {
      final response = await http.post(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        return {"success": true, "data": jsonDecode(response.body)};
      } else if (response.statusCode == 401 && await refreshAccessToken()) {
        return await markCompleted(id);
      } else {
        return {"success": false, "error": response.body};
      }
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }
}
