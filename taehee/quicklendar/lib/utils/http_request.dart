import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> httpGet({required String path}) async {
  String baseUrl = 'https://reqres.in$path';
  try {
    http.Response response = await http.get(Uri.parse(baseUrl), headers: {
      "accept": "application/json",
      "Content-Type": "application/json",
    });
    try {
      Map<String, dynamic> resBody =
      jsonDecode(utf8.decode(response.bodyBytes));
      resBody['statusCode'] = response.statusCode;
      return resBody;
    } catch (e) {
      // response body가 json이 아닌 경우
      return {'statusCode': 490};
    }
  } catch (e) {
    // 서버가 응답하지 않는 경우
    debugPrint("httpGet error: $e");
    return {'statusCode': 503};
  }
}

Future<int> httpPost({required String path, Map? data}) async {
  String baseUrl = 'https://Url 입력하세요$path';
  var body = jsonEncode(data);
  try {
    http.Response response =
    await http.post(Uri.parse(baseUrl), body: body, headers: {
      "accept": "application/json",
      "Content-Type": "application/json",
    });
    return response.statusCode;
  } catch (e) {
    debugPrint("httpPost error: $e");
    return 503;
  }
}

Future<int> httpPut({required String path, Map? data}) async {
  String baseUrl = 'https://Url 입력하세요$path';
  var body = jsonEncode(data);
  try {
    http.Response response =
    await http.post(Uri.parse(baseUrl), body: body, headers: {
      "accept": "application/json",
      "Content-Type": "application/json",
    });
    return response.statusCode;
  } catch (e) {
    debugPrint("httpPut error: $e");
    return 503;
  }
}

Future<int> httpDelete({required String path, Map? data}) async {
  String baseUrl = 'https://Url 입력하세요$path';
  var body = jsonEncode(data);
  try {
    http.Response response =
    await http.delete(Uri.parse(baseUrl), body: body, headers: {
      "accept": "application/json",
      "Content-Type": "application/json",
    });
    return response.statusCode;
  } catch (e) {
    debugPrint("httpDelete error: $e");

    return 503;
  }
}