import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ContestScreen extends StatefulWidget {
  const ContestScreen({Key? key}) : super(key: key);

  @override
  State<ContestScreen> createState() => _ContestScreenState();
}

class _ContestScreenState extends State<ContestScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int currentIndex = 0;

  // 이미지 슬라이더에 사용할 이미지 리스트 (Asset 경로)
  final List<String> imageUrls = [
    'assets/img/sample_poster.png',
    'assets/img/sample_poster1.jpg', // 두 번째 이미지 (예시)
    'assets/img/sample_poster2.png', // 세 번째 이미지 (예시)
  ];

  // 필터 옵션 변수
  String? selectedField;
  String? selectedBenefit;
  String? selectedDuration;

  final List<String> fields = ["디자인", "프로그래밍", "마케팅"];
  final List<String> benefits = ["상금", "인턴십", "포트폴리오"];
  final List<String> durations = ["1개월 이내", "3개월 이내", "6개월 이내"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Function to build contest grid items
  Widget buildContestCard(String imageUrl, String title, String company, String dDay, String views, String comments, String badgeText) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 4,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                child: Image.asset( // 로컬 이미지를 사용할 경우 Image.asset
                  imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badgeText,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  children: [
                    const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      comments,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  company,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'D-$dDay',
                      style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '조회수 $views',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Function to build the filter section with dropdowns
  Widget buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              hint: const Text("활동분야"),
              value: selectedField,
              items: fields.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedField = newValue;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              hint: const Text("활동혜택"),
              value: selectedBenefit,
              items: benefits.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedBenefit = newValue;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              hint: const Text("활동기간"),
              value: selectedDuration,
              items: durations.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedDuration = newValue;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // Main build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("공모전"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "공모전 검색",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        // Add search functionality here
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: "홈"),
                  Tab(text: "공모전"),
                  Tab(text: "대외활동"),
                ],
                labelColor: Colors.black,
                indicatorColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // '홈' Tab Content
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // Carousel Slider 추가
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 200.0, // 슬라이더 높이 설정
                        autoPlay: true, // 자동 슬라이드
                        enlargeCenterPage: true, // 가운데 이미지 확대
                        aspectRatio: 16 / 9, // 비율 설정
                        viewportFraction: 0.8, // 화면에서 보여지는 슬라이더 크기 비율
                        onPageChanged: (index, reason) {
                          setState(() {
                            currentIndex = index; // 슬라이드 인덱스 업데이트
                          });
                        },
                      ),
                      items: imageUrls.map((url) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.asset( // 슬라이더에도 로컬 이미지 사용
                                  url,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    // 인디케이터 점 표시
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: imageUrls.asMap().entries.map((entry) {
                        return GestureDetector(
                          onTap: () => setState(() {
                            currentIndex = entry.key;
                          }),
                          child: Container(
                            width: 8.0,
                            height: 8.0,
                            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: currentIndex == entry.key
                                  ? Colors.blueAccent // 현재 슬라이드의 인디케이터는 파란색
                                  : Colors.grey, // 나머지 슬라이드는 회색
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "현재 주목 받는 공모전",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 0.70, // Adjust the aspect ratio to fit the card design
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    return buildContestCard(
                      'assets/img/sample_poster.png', // 로컬 이미지 경로
                      '공모전 제목',
                      '게시자',
                      '7', // D-day
                      '12', // 조회수
                      '5', // 댓글 수
                      '추천', // 뱃지
                    );
                  },
                ),
              ),
            ],
          ),

          // '공모전' Tab Content
          Column(
            children: [
              buildFilterSection(), // 필터 섹션 추가
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "공모전",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 0.7, // 카드의 가로세로 비율 조정
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    return buildContestCard(
                      'assets/img/sample_poster1.jpg', // 이미지 경로
                      '공모전',
                      '회사',
                      '5', // D-day
                      '532', // 조회수
                      '45', // 댓글 수
                      '인기', // 뱃지
                    );
                  },
                ),
              ),
            ],
          ),

          // '대외활동' Tab Content
          Column(
            children: [
              buildFilterSection(), // 필터 섹션 추가
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "대외활동",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 0.70, // 카드의 가로세로 비율 조정
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    return buildContestCard(
                      'assets/img/sample_poster2.png', // 이미지 경로
                      '대외활동',
                      '기관',
                      '10', // D-day
                      '150', // 조회수
                      '12', // 댓글 수
                      '인기', // 뱃지
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
