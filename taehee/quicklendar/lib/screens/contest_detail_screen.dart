import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../models/contest.dart';

class ContestDetailScreen extends StatelessWidget {
  final Contest contest;

  const ContestDetailScreen({Key? key, required this.contest}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        title: Text(contest.title),
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
