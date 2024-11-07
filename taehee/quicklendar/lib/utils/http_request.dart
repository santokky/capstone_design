import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = 'http://10.0.2.2:8080';

Future<Map<String, dynamic>> httpGet({required String path}) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token'); // 저장된 토큰 불러오기
    final response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: {
        "accept": "application/json",
        "Content-Type": "application/json",
        if (token != null) "Cookie": "jwt=$token", // 쿠키 헤더에 토큰 추가
      },
    );
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> resBody = jsonDecode(utf8.decode(response.bodyBytes));
        resBody['statusCode'] = response.statusCode;
        return resBody;
      } catch (e) {
        debugPrint("JSON Decode error: $e");
        return {'statusCode': 490, 'error': 'JSON Decode Error'};
      }
    } else {
      return {'statusCode': response.statusCode, 'error': 'Failed to fetch data'};
    }
  } catch (e) {
    debugPrint("httpGet error: $e");
    return {'statusCode': 503, 'error': 'Service Unavailable'};
  }
}

Future<Map<String, dynamic>> httpPost({required String path, Map? data}) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: {
        "accept": "application/json",
        "Content-Type": "application/json",
        if (token != null) "Cookie": "jwt=$token", // 쿠키 헤더에 토큰 추가
      },
      body: jsonEncode(data),
    );
    return {'statusCode': response.statusCode, 'body': response.body};
  } catch (e) {
    debugPrint("httpPost error: $e");
    return {'statusCode': 503, 'error': 'Service Unavailable'};
  }
}

Future<Map<String, dynamic>> httpPut({required String path, Map? data}) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: {
        "accept": "application/json",
        "Content-Type": "application/json",
        if (token != null) "Cookie": "jwt=$token", // 쿠키 헤더에 토큰 추가
      },
      body: jsonEncode(data),
    );
    return {'statusCode': response.statusCode, 'body': response.body};
  } catch (e) {
    debugPrint("httpPut error: $e");
    return {'statusCode': 503, 'error': 'Service Unavailable'};
  }
}

Future<Map<String, dynamic>> httpDelete({required String path, Map? data}) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.delete(
      Uri.parse('$baseUrl$path'),
      headers: {
        "accept": "application/json",
        "Content-Type": "application/json",
        if (token != null) "Cookie": "jwt=$token", // 쿠키 헤더에 토큰 추가
      },
      body: jsonEncode(data),
    );
    return {'statusCode': response.statusCode, 'body': response.body};
  } catch (e) {
    debugPrint("httpDelete error: $e");
    return {'statusCode': 503, 'error': 'Service Unavailable'};
  }
}
