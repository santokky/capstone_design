// screens/contest_screen.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import '../models/contest.dart';
import '../widgets/contest_form.dart';
import 'contest_detail_screen.dart';

class ContestScreen extends StatefulWidget {
  const ContestScreen({Key? key}) : super(key: key);

  @override
  State<ContestScreen> createState() => _ContestScreenState();
}

class _ContestScreenState extends State<ContestScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int currentIndex = 0;
  final List<Contest> contestList = [];
  final List<Contest> filteredContests = []; // 필터링된 공모전 리스트
  final TextEditingController searchController = TextEditingController(); // 검색어 입력받기

  // 이미지 슬라이더에 사용할 이미지 리스트 (Asset 경로)
  final List<String> imageUrls = [
    'assets/img/slider_sample1.png',
    'assets/img/slider_sample2.png',
    'assets/img/slider_sample3.png',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose(); // 검색 컨트롤러 해제
    super.dispose();
  }

  // 검색 기능 구현
  void _filterContests(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredContests.clear();
        filteredContests.addAll(contestList); // 검색어가 없을 때는 전체 리스트
      } else {
        filteredContests.clear();
        filteredContests.addAll(
          contestList.where((contest) =>
              contest.title.toLowerCase().contains(query.toLowerCase())), // 제목을 검색어로 필터링
        );
      }
    });
  }

  // 공모전 추가 폼 띄우기
  void showAddContestForm() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: ContestForm(
            onSubmit: (imageUrl, title, organizer, description, location, appStart, appEnd, start, end, appLink, contact) {
              setState(() {
                final newContest = Contest(
                  imageUrl: imageUrl,
                  title: title,
                  organizer: organizer,
                  description: description,
                  location: location,
                  applicationStart: appStart,
                  applicationEnd: appEnd,
                  startDate: start,
                  endDate: end,
                  applicationLink: appLink,
                  contact: contact,
                );
                contestList.add(newContest);
                filteredContests.add(newContest); // 필터된 리스트에도 추가
                contestList.sort((a, b) => b.views.compareTo(a.views)); // 조회수 순 정렬
              });
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  Widget buildContestCard(Contest contest) {
    return GestureDetector(
      onTap: () {
        setState(() {
          contest.views++;
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ContestDetailScreen(contest: contest),
          ),
        );
      },
      child: Card(
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
                  child: Image.file(
                    File(contest.imageUrl),
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
                      contest.dDay,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
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
                    contest.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    contest.organizer,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.visibility, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${contest.views} 조회수',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
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
                  controller: searchController,
                  onChanged: _filterContests, // 검색어가 변경될 때마다 필터링 실행
                  decoration: InputDecoration(
                    hintText: "공모전 검색",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        _filterContests(searchController.text); // 검색 버튼 클릭 시 필터링
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
                labelColor: Colors.white,
                indicatorColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // '홈' 탭
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          CarouselSlider(
                            options: CarouselOptions(
                              height: 200.0,
                              autoPlay: true,
                              enlargeCenterPage: true,
                              aspectRatio: 16 / 9,
                              viewportFraction: 0.8,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  currentIndex = index;
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
                                      child: Image.asset(
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
                                        ? Colors.blueAccent
                                        : Colors.grey,
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
                  ],
                ),
              ),
              SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 0.7,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    return buildContestCard(filteredContests[index]);
                  },
                  childCount: filteredContests.length, // 필터된 공모전 리스트 사용
                ),
              ),
            ],
          ),

          // '공모전' 탭
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "공모전",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ),
              ),
              SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 0.7,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    return buildContestCard(filteredContests[index]);
                  },
                  childCount: filteredContests.length, // 필터된 공모전 리스트 사용
                ),
              ),
            ],
          ),

          // '대외활동' 탭
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "대외활동",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ),
              ),
              SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 0.7,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    return buildContestCard(filteredContests[index]);
                  },
                  childCount: filteredContests.length, // 필터된 공모전 리스트 사용
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddContestForm,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
