import 'package:flutter/material.dart';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import '../models/contest.dart';
import '../utils/http_contest.dart';
import '../widgets/contest_form.dart';
import '../contest_database.dart';
import '../database_helper.dart'; // DatabaseHelper 가져오기
import 'contest_detail_screen.dart';

class ContestScreen extends StatefulWidget {
  const ContestScreen({Key? key}) : super(key: key);

  @override
  State<ContestScreen> createState() => _ContestScreenState();
}

class _ContestScreenState extends State<ContestScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int currentIndex = 0;
  int currentTabIndex = 0; // 현재 TabBar 인덱스를 저장하는 변수

  List<Contest> contestList = [];
  List<Contest> homeFilteredContests = []; // 홈 탭의 필터링 리스트
  List<Contest> contestFilteredContests = []; // 공모전 탭의 필터링 리스트
  List<Contest> activityFilteredContests = []; // 대외활동 탭의 필터링 리스트

  final TextEditingController searchController = TextEditingController();

  String selectedCategory = '모든 카테고리';
  String selectedPeriod = '모든 기간';
  String selectedOrganizer = '모든 주최자';

  final List<String> categories = ['모든 카테고리', '예술 및 디자인', '기술 및 공학', '기타'];
  final List<String> periods = [
    '모든 기간',
    '신청 D-7 이내',
    '신청 D-30 이내',
    '시작 D-7 이내',
    '종료 D-30 이내'
  ];
  List<String> contestOrganizers = ['모든 주최자']; // 공모전 주최자 목록
  List<String> activityOrganizers = ['모든 주최자']; // 대외활동 주최자 목록
  List<String> organizers = ['모든 주최자']; // 현재 표시할 주최자 목록

  final List<String> imageUrls = [
    'assets/img/slider_sample1.png',
    'assets/img/slider_sample2.png',
    'assets/img/slider_sample3.png',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // 앱 시작 시 서버 동기화 및 데이터 로드
    syncAndLoadData();

    // TabBar 상태를 추적하는 리스너 추가
    _tabController.addListener(() {
      setState(() {
        currentTabIndex = _tabController.index;
        // 탭이 바뀔 때마다 주최자 목록을 해당 카테고리로 필터링
        if (currentTabIndex == 1) {
          organizers = contestOrganizers;
        } else if (currentTabIndex == 2) {
          organizers = activityOrganizers;
        }
      });
    });

    loadContestsFromDatabase(); // 앱 시작 시 데이터베이스에서 공모전 정보를 불러옴
    loadOrganizersFromDatabase(); // 주최자 목록을 불러옴
  }

  Future<void> loadOrganizersFromDatabase() async {
    List<String> dbContestOrganizers = await ContestDatabase.instance
        .readOrganizersByCategory('공모전');
    List<String> dbActivityOrganizers = await ContestDatabase.instance
        .readOrganizersByCategory('대외활동');

    setState(() {
      contestOrganizers = ['모든 주최자', ...dbContestOrganizers]; // 공모전 주최자 목록
      activityOrganizers = ['모든 주최자', ...dbActivityOrganizers]; // 대외활동 주최자 목록

      // 탭이 공모전 탭일 경우 공모전 주최자 목록을, 대외활동 탭일 경우 대외활동 주최자 목록을 기본값으로 설정
      if (currentTabIndex == 1) {
        organizers = contestOrganizers;
      } else if (currentTabIndex == 2) {
        organizers = activityOrganizers;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadContestsFromDatabase() async {
    contestList = await ContestDatabase.instance.readAllContests();
    print('Loaded contests in screen: $contestList'); // 데이터 불러오기 확인
    // 디버그용으로 전체 리스트 출력
    contestList.forEach((contest) {
      print('Loaded contest: ${contest.title}, ${contest
          .applicationStart}, ${contest.applicationEnd}');
    });

    setState(() {
      //homeFilteredContests = List.from(contestList); // 초기값
      homeFilteredContests = contestList.map((c) {
        return c.copyWith(
          imageFile: c.imageFile ?? c.imageUrl, // imageFile 값이 없으면 imageUrl 사용
        );
      }).toList();
      contestFilteredContests =
          List.from(contestList.where((c) => c.activityType == "공모전"));
      activityFilteredContests =
          List.from(contestList.where((c) => c.activityType == "대외활동"));

      // 디버그용 출력
      print('Loaded contests: $contestList');
    });
  }

  // 새로운 공모전 등록 후 database_helper에서 데이터 가져오기
  Future<void> transferContestsFromDatabaseHelper() async {
    await DatabaseHelper().transferEventsToContestDatabase();
    await loadContestsFromDatabase();
  }

  void _filterHomeContests(String query) {
    setState(() {
      List<Contest> tempList = List.from(contestList);

      // 검색어 필터링 (홈 탭은 검색어만 적용)
      if (query.isNotEmpty) {
        tempList = tempList.where((contest) {
          return contest.title.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }

      homeFilteredContests = tempList;
    });
  }

  void _filterContestTab(String query) {
    setState(() {
      List<Contest> tempList = List.from(
          contestList.where((c) => c.activityType == "공모전"));

      // 검색어 필터링
      if (query.isNotEmpty) {
        tempList = tempList.where((contest) {
          return contest.title.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }

      // 카테고리 필터링
      if (selectedCategory != '모든 카테고리') {
        tempList = tempList.where((contest) {
          return contest.category == selectedCategory;
        }).toList();
      }

      // 주최자 필터링
      if (selectedOrganizer != '모든 주최자') {
        tempList = tempList.where((contest) {
          return contest.organizer == selectedOrganizer;
        }).toList();
      }

      // 기간 필터링
      if (selectedPeriod == '신청 D-7 이내') {
        tempList = tempList.where((contest) {
          return contest.applicationEnd.isBefore(
              DateTime.now().add(Duration(days: 7)));
        }).toList();
      } else if (selectedPeriod == '신청 D-30 이내') {
        tempList = tempList.where((contest) {
          return contest.applicationEnd.isBefore(
              DateTime.now().add(Duration(days: 30)));
        }).toList();
      } else if (selectedPeriod == '시작 D-7 이내') {
        tempList = tempList.where((contest) {
          return contest.startDate.isBefore(
              DateTime.now().add(Duration(days: 7)));
        }).toList();
      } else if (selectedPeriod == '종료 D-30 이내') {
        tempList = tempList.where((contest) {
          return contest.endDate.isBefore(
              DateTime.now().add(Duration(days: 30)));
        }).toList();
      }

      contestFilteredContests = tempList;
    });
  }

  void _filterActivityTab(String query) {
    setState(() {
      List<Contest> tempList = List.from(
          contestList.where((c) => c.activityType == "대외활동"));

      // 검색어 필터링
      if (query.isNotEmpty) {
        tempList = tempList.where((contest) {
          return contest.title.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }

      // 카테고리 필터링
      if (selectedCategory != '모든 카테고리') {
        tempList = tempList.where((contest) {
          return contest.category == selectedCategory;
        }).toList();
      }

      // 주최자 필터링
      if (selectedOrganizer != '모든 주최자') {
        tempList = tempList.where((contest) {
          return contest.organizer == selectedOrganizer;
        }).toList();
      }

      // 기간 필터링
      if (selectedPeriod == '신청 D-7 이내') {
        tempList = tempList.where((contest) {
          return contest.applicationEnd.isBefore(
              DateTime.now().add(Duration(days: 7)));
        }).toList();
      } else if (selectedPeriod == '신청 D-30 이내') {
        tempList = tempList.where((contest) {
          return contest.applicationEnd.isBefore(
              DateTime.now().add(Duration(days: 30)));
        }).toList();
      } else if (selectedPeriod == '시작 D-7 이내') {
        tempList = tempList.where((contest) {
          return contest.startDate.isBefore(
              DateTime.now().add(Duration(days: 7)));
        }).toList();
      } else if (selectedPeriod == '종료 D-30 이내') {
        tempList = tempList.where((contest) {
          return contest.endDate.isBefore(
              DateTime.now().add(Duration(days: 30)));
        }).toList();
      }

      activityFilteredContests = tempList;
    });
  }

  Future<void> syncAndLoadData() async {
    await syncContestsFromServer(); // 서버에서 데이터 동기화
    await loadContestsFromDatabase(); // 로컬 데이터베이스에서 공모전 정보 로드
    setState(() {}); // UI 업데이트
  }


  Future<void> syncContestsFromServer() async {
    try {
      // 서버에서 공모전 목록 가져오기
      List<Map<String, dynamic>> serverContests = await fetchContests();

      for (var contestData in serverContests) {
        Contest contest = Contest.fromJson(contestData);

        // 공모전의 id가 있는지 확인
        if (contest.id != null) {
          // 로컬 데이터베이스에 이미 있는 공모전인지 확인
          Contest? existingContest = await ContestDatabase.instance.readContestById(contest.id!);

          if (existingContest == null) {
            // 없는 경우 새로 추가
            await ContestDatabase.instance.create(contest);
          } else {
            // 이미 있는 경우 업데이트
            await ContestDatabase.instance.update(contest);
          }
        } else {
          // id가 없는 경우 생성
          await ContestDatabase.instance.create(contest);
        }
      }

      print("서버에서 데이터 동기화 완료");
    } catch (e) {
      print("syncContestsFromServer 에러: $e");
    }
  }


  Future<void> syncContestsToServer() async {
    try {
      // 로컬 데이터베이스에서 모든 공모전 가져오기
      List<Contest> localContests = await ContestDatabase.instance.readAllContests();

      for (var contest in localContests) {
        // `imageFile` 값이 있는지 확인
        if (contest.imageFile != null && contest.imageFile!.isNotEmpty) {
          final imageFile = File(contest.imageFile!);

          if (imageFile.existsSync()) {
            // 로컬에만 있는 공모전이면 서버에 생성
            final response = await createContestWithImage(contest.toJson(), imageFile);

            if (response['statusCode'] == 201) {
              print("서버로 공모전 업로드 성공: ${contest.title}");
            } else {
              print("공모전 업로드 실패: ${contest.title}, Error: ${response['error']}");
            }
          } else {
            print("이미지 파일이 존재하지 않음: ${contest.imageFile}");
          }
        } else {
          print("공모전 이미지 파일 경로가 누락됨: ${contest.title}");
        }
      }

      print("로컬 데이터 서버로 업로드 완료");
    } catch (e) {
      print("syncContestsToServer 에러: $e");
    }
  }


  Future<void> showAddContestForm() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: ContestForm(
            onSubmit: (
                String imageUrl,
                String title,
                String organizer,
                String description,
                String location,
                DateTime appStart,
                DateTime appEnd,
                DateTime start,
                DateTime end,
                String appLink,
                String contact,
                String category,
                String activityType,
                ) {
              final newContest = Contest(
                imageUrl: imageUrl,
                imageFile: imageUrl, // 로컬 이미지 경로로 설정
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
                category: category,
                activityType: activityType,
              );

              ContestDatabase.instance.create(newContest).then((_) async {
                await syncContestsToServer();
                await loadContestsFromDatabase();
                setState(() {});
                Navigator.of(context).pop();
              });
            },
          ),
        );
      },
    );
  }


  Widget buildContestCard(Contest contest) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final imagePath = contest.imageFile?.isNotEmpty == true
        ? contest.imageFile
        : contest.imageUrl;

    print('Image Path: $imagePath');

    final fileExists = imagePath != null && imagePath.isNotEmpty
        ? File(imagePath).existsSync()
        : false;

    print('File exists: $fileExists');

    return GestureDetector(
      onTap: () async {
        contest.views++;
        await ContestDatabase.instance.updateViews(contest);
        await loadContestsFromDatabase();

        // `imageFile` 값을 포함한 `Contest` 객체 복사
        final updatedContest = contest.copyWith(imageFile: contest.imageFile);

        // 디버깅용 로그 출력
        print('Navigating to detail with imageFile: ${updatedContest.imageFile}');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ContestDetailScreen(contest: updatedContest),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 4,
        color: isDarkMode ? Colors.grey[850] : Colors.white,
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
                  child: SizedBox(
                    height: 170,
                    width: double.infinity,
                    child: fileExists
                        ? Image.file(
                      File(imagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset('assets/img/sample_poster.png');
                      },
                    )
                        : Image.network(
                      contest.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset('assets/img/sample_poster.png');
                      },
                    ),
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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    contest.organizer,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.visibility, size: 16, color: isDarkMode ? Colors.grey[400] : Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${contest.views} 조회수',
                        style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.grey[400] : Colors.grey),
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




  Widget buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: IntrinsicWidth(
              child: DropdownButtonFormField<String>(
                value: selectedCategory,
                isDense: true,
                isExpanded: true,
                // 메뉴 자체는 확장되도록 설정
                items: categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(
                      category,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis, // 텍스트가 길면 잘리도록 설정
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                    if (currentTabIndex == 1) {
                      _filterContestTab(searchController.text);
                    } else if (currentTabIndex == 2) {
                      _filterActivityTab(searchController.text);
                    }
                  });
                },
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 8.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: IntrinsicWidth(
              child: DropdownButtonFormField<String>(
                value: selectedPeriod,
                isDense: true,
                isExpanded: true,
                // 메뉴 자체는 확장되도록 설정
                items: periods.map((String period) {
                  return DropdownMenuItem<String>(
                    value: period,
                    child: Text(
                      period,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis, // 텍스트가 길면 잘리도록 설정
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedPeriod = value!;
                    if (currentTabIndex == 1) {
                      _filterContestTab(searchController.text);
                    } else if (currentTabIndex == 2) {
                      _filterActivityTab(searchController.text);
                    }
                  });
                },
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 8.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: IntrinsicWidth(
              child: DropdownButtonFormField<String>(
                value: selectedOrganizer,
                isDense: true,
                isExpanded: true,
                // 메뉴 자체는 확장되도록 설정
                items: organizers.map((String organizer) {
                  return DropdownMenuItem<String>(
                    value: organizer,
                    child: Text(
                      organizer,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis, // 텍스트가 길면 잘리도록 설정
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedOrganizer = value!;
                    if (currentTabIndex == 1) {
                      _filterContestTab(searchController.text);
                    } else if (currentTabIndex == 2) {
                      _filterActivityTab(searchController.text);
                    }
                  });
                },
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 8.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // 다크 모드 여부를 확인
    bool isDarkMode = Theme
        .of(context)
        .brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          // 상단의 파란색 배경을 포함한 Container
          Container(
            color: isDarkMode ? Colors.grey[850] : Colors.blueAccent, // 다크 모드에서는 grey[850], 라이트 모드에서는 흰색
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  onChanged: (text) {
                    if (currentTabIndex == 0) {
                      _filterHomeContests(text);
                    } else if (currentTabIndex == 1) {
                      _filterContestTab(text);
                    } else if (currentTabIndex == 2) {
                      _filterActivityTab(text);
                    }
                  },
                  decoration: InputDecoration(
                    hintText: "공모전 검색",
                    hintStyle: TextStyle(
                      color: Colors.grey[600], // 검색창 힌트 텍스트 색상 설정
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.search,
                        color: Colors.black, // 검색 아이콘 색상
                      ),
                      onPressed: () {
                        if (currentTabIndex == 0) {
                          _filterHomeContests(searchController.text);
                        } else if (currentTabIndex == 1) {
                          _filterContestTab(searchController.text);
                        } else if (currentTabIndex == 2) {
                          _filterActivityTab(searchController.text);
                        }
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white, // 검색창 배경색을 흰색으로 설정
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  // 선택된 탭의 텍스트 색상
                  unselectedLabelColor: Colors.grey[300],
                  // 선택되지 않은 탭의 텍스트 색상
                  indicatorColor: Colors.white,
                  // 탭바 인디케이터 색상
                  tabs: const [
                    Tab(text: "홈"),
                    Tab(text: "공모전"),
                    Tab(text: "대외활동"),
                  ],
                ),
              ],
            ),
          ),
          if (currentTabIndex == 1 || currentTabIndex == 2) buildFilterRow(),
          // 공모전과 대외활동 탭에서만 필터링 메뉴 표시
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 홈 탭
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
                                    viewportFraction: 1.0,
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
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 5.0),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                10.0),
                                            child: Image.asset(
                                              url,
                                              fit: BoxFit.contain,
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
                                  children: imageUrls
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    return GestureDetector(
                                      onTap: () =>
                                          setState(() {
                                            currentIndex = entry.key;
                                          }),
                                      child: Container(
                                        width: 8.0,
                                        height: 8.0,
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 8.0, horizontal: 4.0),
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
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
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
                          final contest = homeFilteredContests[index];
                          return buildContestCard(contest);
                        },
                        childCount: homeFilteredContests.length,
                      ),
                    ),
                  ],
                ),
                // 공모전 탭
                CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "공모전",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
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
                          final contest = contestFilteredContests[index];
                          return buildContestCard(contest);
                        },
                        childCount: contestFilteredContests.length,
                      ),
                    ),
                  ],
                ),
                // 대외활동 탭
                CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "대외활동",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
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
                          final contest = activityFilteredContests[index];
                          return buildContestCard(contest);
                        },
                        childCount: activityFilteredContests.length,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddContestForm,
        backgroundColor: Theme
            .of(context)
            .brightness == Brightness.dark
            ? Colors.white
            : Colors.blueAccent,
        child: Icon(
          Icons.add,
          color: Theme
              .of(context)
              .brightness == Brightness.dark
              ? Colors.black
              : Colors.white,
        ),
      ),
    );
  }
}
