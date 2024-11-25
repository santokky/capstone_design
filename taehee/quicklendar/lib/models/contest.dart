const String baseUrl = 'http://10.0.2.2:8080/';

class Contest {
  int? id; // 데이터베이스에서 자동 생성되는 ID
  String imageUrl;
  String? imageFile; // 로컬 파일 경로
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
    this.imageFile,
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
    String? imageFile,
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
      imageFile: imageFile ?? this.imageFile ?? this.imageUrl, // 기본값 설정
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
      views: views ?? this.views,
      category: category ?? this.category,
      activityType: activityType ?? this.activityType,
    );
  }

  // JSON 데이터를 Contest 객체로 변환하는 팩토리 메서드
  factory Contest.fromJson(Map<String, dynamic> json) {
    // 이미지 URL 생성 시 중복된 슬래시와 잘못된 URL 형식 수정
    String imagePath = json['imageUrl'] ?? '';
    String imageUrl;

    if (imagePath.contains('http')) {
      // 올바른 URL 형식이면 그대로 사용
      imageUrl = imagePath;
    } else if (imagePath.startsWith('/')) {
      // 슬래시로 시작하면 서버 경로로 간주
      imageUrl = '$baseUrl${imagePath.substring(1)}';
    } else if (imagePath.contains(r'C:\')) {
      // 로컬 경로로 인식된 경우 기본 이미지로 대체하거나 오류 처리
      print('Invalid local path detected: $imagePath');
      imageUrl = 'assets/img/sample_poster.png';
    } else {
      // 기타 경우 기본 URL로 처리
      imageUrl = '$baseUrl$imagePath';
    }

    // if (imagePath.isNotEmpty) {
    //   // imagePath가 '/'로 시작하면 중복된 슬래시 제거
    //   if (imagePath.startsWith('/')) {
    //     imageUrl = baseUrl + imagePath.substring(1);
    //   } else {
    //     imageUrl = baseUrl + imagePath;
    //   }
    // } else {
    //   imageUrl = 'assets/img/sample_poster.png';
    // }

    print('Generated Image URL: $imageUrl');

    return Contest(
      id: json['id'],
      imageUrl: imageUrl, // 서버의 image 필드 사용
      title: json['name'] ?? '제목 없음', // 서버의 name 필드 사용
      organizer: json['host'] ?? '주최자 정보 없음', // 서버의 host 필드 사용
      description: json['description'] ?? '설명 없음',
      location: json['location'] ?? '위치 정보 없음',
      applicationStart: json['requestStartDate'] != null
          ? DateTime.parse(json['requestStartDate'])
          : DateTime.now(),
      applicationEnd: json['requestEndDate'] != null
          ? DateTime.parse(json['requestEndDate'])
          : DateTime.now(),
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : DateTime.now(),
      applicationLink: json['requestPath'] ?? '',
      contact: json['support'] ?? '',
      views: json['likeCount'] ?? 0,
      category: json['category'] ?? '기타',
      activityType: json['competitionType'] ?? '기타',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': title, // 서버에서 'name' 필드를 기대함
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'requestStartDate': applicationStart.toIso8601String(),
      'requestEndDate': applicationEnd.toIso8601String(),
      'requestPath': applicationLink,
      'location': location,
      'image': imageUrl,
      'support': contact,
      'host': organizer,
      'category': category,
      'competitionType': activityType,
    };
  }

  // 데이터베이스로 저장하기 위해 Contest 객체를 Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'imageFile': imageFile ?? '', // 여기서 imageFile 값이 null이 아니도록 처리
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
      'views': views,
      'category': category,
      'activityType': activityType,
    };
  }

  // 데이터베이스에서 가져온 Map을 Contest 객체로 변환
  static Contest fromMap(Map<String, dynamic> map) {
    return Contest(
      id: map['id'],
      imageUrl: map['imageUrl'],
      imageFile: map['imageFile'] != null && map['imageFile'].isNotEmpty ? map['imageFile'] : null,
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
      views: map['views'],
      category: map['category'],
      activityType: map['activityType'],
    );
  }
}
