import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../models/contest.dart';
import '../contest_database.dart'; // ContestDatabase 가져오기

class ContestDetailScreen extends StatelessWidget {
  final Contest contest;

  const ContestDetailScreen({Key? key, required this.contest}) : super(key: key);

  // 공모전 삭제 함수
  Future<void> _deleteContest(BuildContext context) async {
    final contestDB = ContestDatabase.instance;
    await contestDB.deleteContest(contest.id!); // 공모전 삭제
    Navigator.pop(context); // 삭제 후 메인 화면으로 돌아가기
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${contest.title} 공모전이 삭제되었습니다.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        title: Text(contest.title),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmationDialog(context), // 삭제 확인 다이얼로그 호출
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 포스터 이미지 섹션
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.file(
                    File(contest.imageUrl),
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 공모전 정보 섹션
              buildInfoCard(context, contest),

              const SizedBox(height: 16),

              // 공모전 설명 섹션
              buildDescriptionSection(),

              const SizedBox(height: 16),

              // 조회수 섹션
              Center(
                child: Text(
                  "조회수: ${contest.views}",
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 삭제 확인 다이얼로그
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("삭제 확인"),
          content: Text("${contest.title} 공모전을 삭제하시겠습니까?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("취소"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteContest(context); // 삭제 함수 호출
              },
              child: Text("삭제"),
            ),
          ],
        );
      },
    );
  }

  // 공모전 정보를 카드로 보여주는 위젯
  Widget buildInfoCard(BuildContext context, Contest contest) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildInfoRow(Icons.title, "공모전 이름", contest.title),
            const Divider(),
            buildInfoRow(Icons.account_circle, "주최자", contest.organizer),
            const Divider(),
            buildInfoRow(Icons.location_on, "공모전 장소", contest.location),
            const Divider(),
            buildInfoRow(
              Icons.date_range,
              "신청 기간",
              "${DateFormat('yyyy-MM-dd').format(contest.applicationStart)} ~ ${DateFormat('yyyy-MM-dd').format(contest.applicationEnd)}",
            ),
            const Divider(),
            buildInfoRow(
              Icons.event,
              "공모전 기간",
              "${DateFormat('yyyy-MM-dd').format(contest.startDate)} ~ ${DateFormat('yyyy-MM-dd').format(contest.endDate)}",
            ),
            const Divider(),
            buildInfoRow(Icons.link, "신청 경로", contest.applicationLink),
            const Divider(),
            buildInfoRow(Icons.phone, "지원 연락처", contest.contact),
          ],
        ),
      ),
    );
  }

  // 공모전 설명 섹션
  Widget buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "공모전 설명",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          contest.description,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
      ],
    );
  }

  // 정보 아이템을 한 줄로 정리하여 보여주는 위젯
  Widget buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent),
        const SizedBox(width: 16),
        Text(
          "$label: ",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
