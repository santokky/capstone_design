import 'package:flutter/material.dart';

class UserGuideScreen extends StatefulWidget {
  @override
  _UserGuideScreenState createState() => _UserGuideScreenState();
}

class _UserGuideScreenState extends State<UserGuideScreen> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[850]
            : Colors.blueAccent,
        foregroundColor: Colors.white,
        title: Text('사용 설명서'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stepper(
              currentStep: _currentStep,
              onStepTapped: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              onStepContinue: _currentStep < 5
                  ? () {
                setState(() {
                  _currentStep += 1;
                });
              }
                  : null,
              onStepCancel: _currentStep > 0
                  ? () {
                setState(() {
                  _currentStep -= 1;
                });
              }
                  : null,
              controlsBuilder: (BuildContext context, ControlsDetails details) {
                return Row(
                  children: <Widget>[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onPressed: details.onStepContinue,
                      child: const Text('다음'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('이전'),
                    ),
                  ],
                );
              },
              steps: [
                Step(
                  title: Text("첫 번째 단계: 회원가입"),
                  content: Text(
                      "앱을 사용하려면 회원가입이 필요합니다. \n설정 화면에서 가입을 시작하세요."),
                  isActive: _currentStep >= 0,
                ),
                Step(
                  title: Text("두 번째 단계: 퀵린더"),
                  content: Text(
                      "이미지를 사용해 손쉽게 일정을 달력에 추가하고 관리할 수 있습니다."),
                  isActive: _currentStep >= 1,
                ),
                Step(
                  title: Text("세 번째 단계: 알림 설정"),
                  content: Text("대회 알림을 설정하여 중요한 날짜를 놓치지 마세요."),
                  isActive: _currentStep >= 2,
                ),
                Step(
                  title: Text("네 번째 단계: 캘린더 관리"),
                  content: Text("캘린더에 등록된 일정의 진행 상황을 알 수 있어요."),
                  isActive: _currentStep >= 3,
                ),
                Step(
                  title: Text("다섯 번째 단계: 공모전/대외활동 찾기"),
                  content:
                  Text("공모전 모음 화면에서 다양한 공모전/대외활동을 찾아보세요!"),
                  isActive: _currentStep >= 4,
                ),
                Step(
                  title: Text("여섯 번째 단계: 공모전/대외활동 등록"),
                  content: Text("공모전/대외활동을 등록하여 많은 사용자에게 공유하세요."),
                  isActive: _currentStep >= 5,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentStep = 0;
                      });
                    },
                    child: const Text('처음으로'),
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: _currentStep == 5
                        ? null
                        : () {
                      setState(() {
                        _currentStep = 5;
                      });
                    },
                    child: const Text('마지막 단계로'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
