import 'package:flutter/material.dart';

class FilterRow extends StatelessWidget {
  final Function(String category, String period, String organizer) onFilterChanged;

  const FilterRow({Key? key, required this.onFilterChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          DropdownButton<String>(
            value: '모든 카테고리',
            items: ['모든 카테고리', '예술 및 디자인', '기술 및 공학', '기타'].map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              onFilterChanged(value!, '모든 기간', '모든 주최자');
            },
          ),
          DropdownButton<String>(
            value: '모든 기간',
            items: ['모든 기간', '신청기간', '공모전 시작일'].map((String period) {
              return DropdownMenuItem<String>(
                value: period,
                child: Text(period),
              );
            }).toList(),
            onChanged: (value) {
              onFilterChanged('모든 카테고리', value!, '모든 주최자');
            },
          ),
          DropdownButton<String>(
            value: '모든 주최자',
            items: ['모든 주최자', '주최자 A', '주최자 B'].map((String organizer) {
              return DropdownMenuItem<String>(
                value: organizer,
                child: Text(organizer),
              );
            }).toList(),
            onChanged: (value) {
              onFilterChanged('모든 카테고리', '모든 기간', value!);
            },
          ),
        ],
      ),
    );
  }
}
