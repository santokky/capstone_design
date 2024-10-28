import 'package:flutter/material.dart';

class CustomerSupportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[850]
            : Colors.blueAccent,
        foregroundColor: Colors.white,
        title: Text('고객 지원'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '고객 지원에 필요한 정보를 여기에 입력하세요.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Divider(),
            SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(
                labelText: '문의 사항을 작성하세요',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.message),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('확인'),
                          content: Text('이메일을 전송하시겠습니까?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('취소'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                // 이메일 전송 기능
                              },
                              child: Text('확인'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: Icon(Icons.email),
                    label: Text('이메일 보내기'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('확인'),
                          content: Text('전화를 거시겠습니까?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('취소'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                // 전화 기능 추가
                              },
                              child: Text('확인'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: Icon(Icons.phone),
                    label: Text('전화 걸기'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              '추가 정보',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text('한신대학교'),
              subtitle: Text('경기도 오산시 한신대길 137'),
            ),
            ListTile(
              leading: Icon(Icons.access_time),
              title: Text('운영 시간'),
              subtitle: Text('월 - 금: 9AM - 6PM'),
            ),
          ],
        ),
      ),
    );
  }
}
