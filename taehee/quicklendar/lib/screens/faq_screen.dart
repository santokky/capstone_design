import 'package:flutter/material.dart';

class FAQScreen extends StatefulWidget {
  @override
  _FAQScreenState createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final List<Map<String, String>> faqList = [
    {
      "category": "기본 사용법",
      "question": "어플 사용법이 궁금해요.",
      "answer": "어플 사용법은 ... 입니다."
    },
    {
      "category": "공모전",
      "question": "다른 공모전들을 찾아보고 싶어요.",
      "answer": "메인 화면에서 좌측 상단의 메뉴 버튼을 누른 후, 공모전 메뉴를 선택 시 다양한 공모전들을 찾아 보실 수 있습니다."
    },
    {
      "category": "계정 관리",
      "question": "계정 정보는 어디서 확인할 수 있나요?",
      "answer": "계정 정보는 설정 화면에서 확인할 수 있습니다."
    },
    {
      "category": "기타",
      "question": "추가 질문 1",
      "answer": "답변 1"
    },
    {
      "category": "기타",
      "question": "추가 질문 2",
      "answer": "답변 2"
    },
    // 더 많은 FAQ 항목
  ];

  String searchText = '';
  List<Map<String, String>> filteredFaqList = [];

  @override
  void initState() {
    super.initState();
    filteredFaqList = faqList; // 초기 FAQ 목록 설정
  }

  void _filterFaqList(String text) {
    setState(() {
      searchText = text;
      filteredFaqList = faqList
          .where((faq) =>
      faq['question']!.toLowerCase().contains(text.toLowerCase()) ||
          faq['category']!.toLowerCase().contains(text.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[850]
            : Colors.blueAccent,
        foregroundColor: Colors.white,
        title: Text('자주 묻는 질문'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: '질문 또는 카테고리 검색',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (text) {
                _filterFaqList(text);
              },
            ),
          ),
          Expanded(
            child: ListView(
              children: filteredFaqList.map((faq) {
                return ExpansionTile(
                  title: Text(faq['question']!),
                  subtitle: Text(
                    '카테고리: ${faq['category']}',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(faq['answer']!),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                // 문의 접수 화면으로 이동하는 기능 추가
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('새 질문 추가'),
                      content: TextField(
                        decoration: InputDecoration(hintText: "질문을 입력하세요"),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('취소'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // 실제 질문 추가 로직 구현
                            Navigator.of(context).pop();
                          },
                          child: Text('추가'),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: Icon(Icons.add),
              label: Text('질문 접수하기'),
            ),
          ),
        ],
      ),
    );
  }
}
