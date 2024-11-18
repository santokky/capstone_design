import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/contest.dart';

const String baseUrl = 'http://10.0.2.2:8080';

// 서버에서 공모전 목록 가져오기 (GET)
Future<List<Map<String, dynamic>>> fetchContests() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl/competitions'),
      headers: {
        "accept": "application/json",
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    print("Request Headers: ${response.request?.headers}");
    print("Response Status: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      List<dynamic> contests = jsonDecode(utf8.decode(response.bodyBytes));
      return List<Map<String, dynamic>>.from(contests);
    } else {
      debugPrint('Failed to fetch contests: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    debugPrint("fetchContests error: $e");
    return [];
  }
}

// 공모전 데이터 생성 (POST)
Future<Map<String, dynamic>> createContest(Map<String, dynamic> contestData) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('$baseUrl/competitions/register'),
      headers: {
        "accept": "application/json",
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: jsonEncode(contestData),
    );

    print("Request Headers: ${response.request?.headers}");
    print("Request Body: ${jsonEncode(contestData)}");
    print("Response Status: ${response.statusCode}");
    print("Response Body: ${response.body}");

    return response.statusCode == 201
        ? {'statusCode': response.statusCode, 'body': response.body}
        : {'statusCode': response.statusCode, 'error': response.body};
  } catch (e) {
    debugPrint("createContest error: $e");
    return {'statusCode': 503, 'error': 'Service Unavailable'};
  }
}

// // 공모전 데이터 수정 (PUT)
// Future<Map<String, dynamic>> updateContest(int id, Map<String, dynamic> contestData) async {
//   try {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? token = prefs.getString('token');
//
//     final response = await http.put(
//       Uri.parse('$baseUrl/competitions/$id'),
//       headers: {
//         "accept": "application/json",
//         "Content-Type": "application/json",
//         if (token != null) "Authorization": "Bearer $token",
//       },
//       body: jsonEncode(contestData),
//     );
//
//     print("Request Headers: ${response.request?.headers}");
//     print("Request Body: ${jsonEncode(contestData)}");
//     print("Response Status: ${response.statusCode}");
//     print("Response Body: ${response.body}");
//
//     return response.statusCode == 200
//         ? {'statusCode': response.statusCode, 'body': response.body}
//         : {'statusCode': response.statusCode, 'error': response.body};
//   } catch (e) {
//     debugPrint("updateContest error: $e");
//     return {'statusCode': 503, 'error': 'Service Unavailable'};
//   }
// }

// 공모전 데이터 삭제 (DELETE)
Future<Map<String, dynamic>> deleteContest(int id) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.delete(
      Uri.parse('$baseUrl/competitions/delete/$id'),
      headers: {
        "accept": "application/json",
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    print("Request Headers: ${response.request?.headers}");
    print("Response Status: ${response.statusCode}");
    print("Response Body: ${response.body}");

    return response.statusCode == 204
        ? {'statusCode': response.statusCode, 'message': 'Contest deleted successfully'}
        : {'statusCode': response.statusCode, 'error': response.body};
  } catch (e) {
    debugPrint("deleteContest error: $e");
    return {'statusCode': 503, 'error': 'Service Unavailable'};
  }
}
