import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String baseUrl = 'http://10.0.2.2:8080';
const Map<String, String> headers = {
  "accept": "application/json",
  "Content-Type": "application/json",
};

Future<Map<String, dynamic>> httpGet({required String path}) async {
  try {
    final response = await http.get(Uri.parse('$baseUrl$path'), headers: headers);
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
    final response = await http.post(Uri.parse('$baseUrl$path'), headers: headers, body: jsonEncode(data));
    return {'statusCode': response.statusCode, 'body': response.body};
  } catch (e) {
    debugPrint("httpPost error: $e");
    return {'statusCode': 503, 'error': 'Service Unavailable'};
  }
}

Future<Map<String, dynamic>> httpPut({required String path, Map? data}) async {
  try {
    final response = await http.put(Uri.parse('$baseUrl$path'), headers: headers, body: jsonEncode(data));
    return {'statusCode': response.statusCode, 'body': response.body};
  } catch (e) {
    debugPrint("httpPut error: $e");
    return {'statusCode': 503, 'error': 'Service Unavailable'};
  }
}

Future<Map<String, dynamic>> httpDelete({required String path, Map? data}) async {
  try {
    final response = await http.delete(Uri.parse('$baseUrl$path'), headers: headers, body: jsonEncode(data));
    return {'statusCode': response.statusCode, 'body': response.body};
  } catch (e) {
    debugPrint("httpDelete error: $e");
    return {'statusCode': 503, 'error': 'Service Unavailable'};
  }
}
