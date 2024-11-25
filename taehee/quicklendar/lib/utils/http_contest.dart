import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/contest.dart';
import 'package:http_parser/http_parser.dart'; // MediaType 사용을 위해 필요

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


// Future<Map<String, dynamic>> createContest(Map<String, dynamic> contestData, File imageFile) async {
//   try {
//     final uri = Uri.parse('$baseUrl/competitions/register');
//
//     final request = http.MultipartRequest('POST', uri);
//     request.headers.addAll({
//       "accept": "application/json",
//       "Authorization": "Bearer YOUR_ACCESS_TOKEN", // SharedPreferences에서 토큰 가져와 설정
//     });
//
//     // JSON 데이터 추가
//     request.fields['competition'] = jsonEncode(contestData);
//
//     // 이미지 파일 추가
//     request.files.add(await http.MultipartFile.fromPath(
//       'image',
//       imageFile.path,
//       contentType: MediaType('image', 'jpeg'), // 적절한 Content-Type 설정
//     ));
//
//     // 요청 전송
//     final response = await request.send();
//
//     // 응답 처리
//     if (response.statusCode == 201) {
//       final responseBody = await response.stream.bytesToString();
//       return {'statusCode': response.statusCode, 'body': responseBody};
//     } else {
//       final errorBody = await response.stream.bytesToString();
//       return {'statusCode': response.statusCode, 'error': errorBody};
//     }
//   } catch (e) {
//     print("createContest 에러: $e");
//     return {'statusCode': 503, 'error': 'Service Unavailable'};
//   }
// }

Future<Map<String, dynamic>> createContestWithImage(
    Map<String, dynamic> contestData, File imageFile) async {
  try {
    final uri = Uri.parse('$baseUrl/competitions/register');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    // Multipart 요청 생성
    final request = http.MultipartRequest('POST', uri);

    // competition 키에 JSON 데이터 첨부 (Text로 전송)
    request.files.add(http.MultipartFile.fromString(
      'competition',
      jsonEncode(contestData),
      contentType: MediaType('application', 'json'), // Content-Type 지정
    ));

    // image 키에 파일 첨부
    request.files.add(await http.MultipartFile.fromPath(
      'image',
      imageFile.path,
    ));

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // 요청 보내기
    final response = await request.send();

    // 응답 처리
    if (response.statusCode == 201) {
      final responseData = await response.stream.bytesToString();
      return {
        'statusCode': response.statusCode,
        'body': jsonDecode(responseData),
      };
    } else {
      final errorData = await response.stream.bytesToString();
      return {
        'statusCode': response.statusCode,
        'error': errorData,
      };
    }
  } catch (e) {
    print('createContestWithImage 에러: $e');
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
