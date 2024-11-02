// class Contest {
//   int? id; // 데이터베이스에서 자동 생성되는 ID
//   String imageUrl;
//   String title;
//   String organizer;
//   String description;
//   String location;
//   DateTime applicationStart;
//   DateTime applicationEnd;
//   DateTime startDate;
//   DateTime endDate;
//   String applicationLink;
//   String contact;
//   int views; // 조회수 필드
//   String category; // 카테고리 필드 추가
//   String activityType; // 활동분야 필드 추가
//
//   Contest({
//     this.id,
//     required this.imageUrl,
//     required this.title,
//     required this.organizer,
//     required this.description,
//     required this.location,
//     required this.applicationStart,
//     required this.applicationEnd,
//     required this.startDate,
//     required this.endDate,
//     required this.applicationLink,
//     required this.contact,
//     this.views = 0, // 기본값 0으로 설정
//     required this.category,
//     required this.activityType,
//   });
//
//   // D-day 계산 함수
//   String get dDay {
//     final currentDate = DateTime.now();
//     final difference = startDate.difference(currentDate).inDays;
//     return difference >= 0 ? 'D-$difference' : '종료됨';
//   }
//
//   // 공모전 정보를 복사하여 새 객체를 생성 (ID가 추가된 상태로 반환)
//   Contest copyWith({
//     int? id,
//     String? imageUrl,
//     String? title,
//     String? organizer,
//     String? description,
//     String? location,
//     DateTime? applicationStart,
//     DateTime? applicationEnd,
//     DateTime? startDate,
//     DateTime? endDate,
//     String? applicationLink,
//     String? contact,
//     int? views,
//     String? category,
//     String? activityType,
//   }) {
//     return Contest(
//       id: id ?? this.id,
//       imageUrl: imageUrl ?? this.imageUrl,
//       title: title ?? this.title,
//       organizer: organizer ?? this.organizer,
//       description: description ?? this.description,
//       location: location ?? this.location,
//       applicationStart: applicationStart ?? this.applicationStart,
//       applicationEnd: applicationEnd ?? this.applicationEnd,
//       startDate: startDate ?? this.startDate,
//       endDate: endDate ?? this.endDate,
//       applicationLink: applicationLink ?? this.applicationLink,
//       contact: contact ?? this.contact,
//       views: views ?? this.views, // 조회수 업데이트
//       category: category ?? this.category,
//       activityType: activityType ?? this.activityType,
//     );
//   }
//
//   // 데이터베이스로 저장하기 위해 Contest 객체를 Map으로 변환
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'imageUrl': imageUrl,
//       'title': title,
//       'organizer': organizer,
//       'description': description,
//       'location': location,
//       'applicationStart': applicationStart.toIso8601String(),
//       'applicationEnd': applicationEnd.toIso8601String(),
//       'startDate': startDate.toIso8601String(),
//       'endDate': endDate.toIso8601String(),
//       'applicationLink': applicationLink,
//       'contact': contact,
//       'views': views, // 조회수 저장
//       'category': category,
//       'activityType': activityType,
//     };
//   }
//
//   // 데이터베이스에서 가져온 Map을 Contest 객체로 변환
//   static Contest fromMap(Map<String, dynamic> map) {
//     return Contest(
//       id: map['id'],
//       imageUrl: map['imageUrl'],
//       title: map['title'],
//       organizer: map['organizer'],
//       description: map['description'],
//       location: map['location'],
//       applicationStart: DateTime.parse(map['applicationStart']),
//       applicationEnd: DateTime.parse(map['applicationEnd']),
//       startDate: DateTime.parse(map['startDate']),
//       endDate: DateTime.parse(map['endDate']),
//       applicationLink: map['applicationLink'],
//       contact: map['contact'],
//       views: map['views'], // 조회수 로드
//       category: map['category'],
//       activityType: map['activityType'],
//     );
//   }
// }

class Contest {
  int? id; // 데이터베이스에서 자동 생성되는 ID
  String imageUrl;
  String title;
  String organizer;
  String description;
  String location;
  DateTime applicationStart;
  DateTime applicationEnd;
  DateTime startDate;
  DateTime endDate;
  String applicationLink;
  String contact;
  int views; // 조회수 필드
  String category; // 카테고리 필드 추가
  String activityType; // 활동분야 필드 추가

  Contest({
    this.id,
    required this.imageUrl,
    required this.title,
    required this.organizer,
    required this.description,
    required this.location,
    required this.applicationStart,
    required this.applicationEnd,
    required this.startDate,
    required this.endDate,
    required this.applicationLink,
    required this.contact,
    this.views = 0, // 기본값 0으로 설정
    required this.category,
    required this.activityType,
  });

  // D-day 계산 함수
  String get dDay {
    final currentDate = DateTime.now();
    final difference = startDate.difference(currentDate).inDays;
    return difference >= 0 ? 'D-$difference' : '종료됨';
  }

  // 공모전 정보를 복사하여 새 객체를 생성 (ID가 추가된 상태로 반환)
  Contest copyWith({
    int? id,
    String? imageUrl,
    String? title,
    String? organizer,
    String? description,
    String? location,
    DateTime? applicationStart,
    DateTime? applicationEnd,
    DateTime? startDate,
    DateTime? endDate,
    String? applicationLink,
    String? contact,
    int? views,
    String? category,
    String? activityType,
  }) {
    return Contest(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      title: title ?? this.title,
      organizer: organizer ?? this.organizer,
      description: description ?? this.description,
      location: location ?? this.location,
      applicationStart: applicationStart ?? this.applicationStart,
      applicationEnd: applicationEnd ?? this.applicationEnd,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      applicationLink: applicationLink ?? this.applicationLink,
      contact: contact ?? this.contact,
      views: views ?? this.views, // 조회수 업데이트
      category: category ?? this.category,
      activityType: activityType ?? this.activityType,
    );
  }

  // JSON 데이터를 Contest 객체로 변환하는 팩토리 메서드
  factory Contest.fromJson(Map<String, dynamic> json) {
    return Contest(
      id: json['id'],
      imageUrl: json['imageUrl'],
      title: json['title'],
      organizer: json['organizer'],
      description: json['description'],
      location: json['location'],
      applicationStart: DateTime.parse(json['applicationStart']),
      applicationEnd: DateTime.parse(json['applicationEnd']),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      applicationLink: json['applicationLink'],
      contact: json['contact'],
      views: json['views'] ?? 0, // 조회수 기본값 설정
      category: json['category'],
      activityType: json['activityType'],
    );
  }

  // Contest 객체를 JSON으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'title': title,
      'organizer': organizer,
      'description': description,
      'location': location,
      'applicationStart': applicationStart.toIso8601String(),
      'applicationEnd': applicationEnd.toIso8601String(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'applicationLink': applicationLink,
      'contact': contact,
      'views': views, // 조회수 저장
      'category': category,
      'activityType': activityType,
    };
  }

  // 데이터베이스로 저장하기 위해 Contest 객체를 Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'title': title,
      'organizer': organizer,
      'description': description,
      'location': location,
      'applicationStart': applicationStart.toIso8601String(),
      'applicationEnd': applicationEnd.toIso8601String(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'applicationLink': applicationLink,
      'contact': contact,
      'views': views, // 조회수 저장
      'category': category,
      'activityType': activityType,
    };
  }

  // 데이터베이스에서 가져온 Map을 Contest 객체로 변환
  static Contest fromMap(Map<String, dynamic> map) {
    return Contest(
      id: map['id'],
      imageUrl: map['imageUrl'],
      title: map['title'],
      organizer: map['organizer'],
      description: map['description'],
      location: map['location'],
      applicationStart: DateTime.parse(map['applicationStart']),
      applicationEnd: DateTime.parse(map['applicationEnd']),
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      applicationLink: map['applicationLink'],
      contact: map['contact'],
      views: map['views'], // 조회수 로드
      category: map['category'],
      activityType: map['activityType'],
    );
  }
}
