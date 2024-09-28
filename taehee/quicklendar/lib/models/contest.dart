// models/contest.dart
class Contest {
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
  int views;

  Contest({
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
    this.views = 0,
  });

  // D-day 계산 함수
  String get dDay {
    final currentDate = DateTime.now();
    final difference = startDate.difference(currentDate).inDays;
    return difference >= 0 ? 'D-$difference' : '종료됨';
  }
}
