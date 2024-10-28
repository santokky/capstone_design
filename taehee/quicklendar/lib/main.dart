import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'screens/ocr_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/event_screen.dart';
import 'screens/setting_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'l10n/app_localizations.dart';
import 'screens/login_screen.dart';
import 'screens/contest_screen.dart';  // 새로 추가된 파일 import
import 'package:quicklendar/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);
  DatabaseHelper().initializeNotifications();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  static void setThemeMode(BuildContext context, ThemeMode newThemeMode) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setThemeMode(newThemeMode);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  bool _notificationsEnabled = true;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isLoggedIn = false;
  ThemeMode _themeMode = ThemeMode.light; // 기본은 라이트 모드

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _initializeNotifications();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('selectedLanguage') ?? 'ko';
    bool? notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    bool? isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String? themeMode = prefs.getString('themeMode') ?? 'light';  // 테마 모드 불러오기
    setState(() {
      _locale = Locale(languageCode, '');
      _notificationsEnabled = notificationsEnabled;
      _isLoggedIn = isLoggedIn;
      _themeMode = themeMode == 'dark' ? ThemeMode.dark : ThemeMode.light;  // 테마 모드 설정
    });
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  void setThemeMode(ThemeMode mode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode = mode;
    });
    prefs.setString('themeMode', mode == ThemeMode.dark ? 'dark' : 'light');  // 설정 저장
  }

  void _setLoggedIn(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = isLoggedIn;
    });
    prefs.setBool('isLoggedIn', isLoggedIn);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ko', 'KR'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      // 라이트 모드 테마
      theme: ThemeData(
        brightness: Brightness.light,  // 라이트 모드일 때 밝은 테마 적용
        appBarTheme: const AppBarTheme(
          color: Colors.white,
        ),
        colorScheme: const ColorScheme.light(
          primary: Colors.blueAccent,
          secondary: Colors.white,
          primaryContainer: Colors.blueAccent,
          onBackground: Colors.blueAccent,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
          ),
        ),
        scaffoldBackgroundColor: Colors.white,
        canvasColor: Colors.white,
        primaryColor: Colors.blueAccent,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,  // 라이트 모드 바텀 네비게이션 배경색
          selectedItemColor: Colors.blueAccent,  // 선택된 아이템 색상
          unselectedItemColor: Colors.grey,  // 선택되지 않은 아이템 색상
        ),
      ),

      // 다크 모드 테마
      darkTheme: ThemeData(
        brightness: Brightness.dark,  // 다크 모드일 때 어두운 테마 적용
        appBarTheme: AppBarTheme(
          color: Colors.grey[900],  // 다크 모드 AppBar 배경색
        ),
        colorScheme: ColorScheme.dark(
          primary: Colors.grey,
          secondary: Colors.grey,
          primaryContainer: Colors.grey[850],  // 배경을 더 어둡게
          onBackground: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
          ),
        ),
        scaffoldBackgroundColor: Colors.grey[900],  // 다크 모드 배경색
        canvasColor: Colors.grey[900],
        primaryColor: Colors.grey,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.grey[850],  // 다크 모드 바텀 네비게이션 배경색
          selectedItemColor: Colors.white,  // 선택된 아이템 색상
          unselectedItemColor: Colors.grey,  // 선택되지 않은 아이템 색상
        ),
        dialogTheme: DialogTheme(
          backgroundColor: Colors.grey[850], // 팝업창 배경색
        ),
      ),
      themeMode: _themeMode, // 사용자가 설정한 테마 모드 적용
      initialRoute: _isLoggedIn ? '/home' : '/login',
      routes: {
        '/login': (context) => LoginScreen(onLoginSuccess: _setLoggedIn),
        '/home': (context) => const HomeScreen(),
        '/contest': (context) => ContestScreen(), // 새로 추가된 경로
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _items = [
    SalomonBottomBarItem(
      icon: const Icon(Icons.camera_alt),
      title: const Text('퀵린더'),
      selectedColor: Colors.blueAccent,
    ),
    SalomonBottomBarItem(
      icon: const Icon(Icons.calendar_month),
      title: const Text('달력'),
      selectedColor: Colors.blueAccent,
    ),
    SalomonBottomBarItem(
      icon: const Icon(Icons.event_available),
      title: const Text('이벤트'),
      selectedColor: Colors.blueAccent,
    ),
    SalomonBottomBarItem(
      icon: const Icon(Icons.emoji_events),  // 공모전 탭이 설정 탭보다 앞에 오도록 위치 변경
      title: const Text('공모전'),
      selectedColor: Colors.blueAccent,
    ),
    SalomonBottomBarItem(
      icon: const Icon(Icons.settings_applications),  // 설정 탭 위치 변경
      title: const Text('설정'),
      selectedColor: Colors.blueAccent,
    ),
  ];

  final _screens = const [
    OCRScreen(),
    CalendarScreen(),
    EventScreen(),
    ContestScreen(),  // 공모전 화면 위치 변경
    SettingScreen(),  // 설정 화면 위치 변경
  ];

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.grey[850] : Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('퀵린더'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // 아이콘을 눌렀을 때 수행할 작업
            },
            color: Colors.white,
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () async {
              final notifications = await DatabaseHelper().getNotifications();
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
                    title: const Text('알림 내역'),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: notifications.isEmpty
                          ? const Center(child: Text('알림 내역이 없습니다.'))
                          : ListView.builder(
                        shrinkWrap: true,
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          return ListTile(
                            title: Text(notification['title']),
                            subtitle: Text(notification['body']),
                            trailing: Text(notification['timestamp']),
                          );
                        },
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // 팝업 닫기
                        },
                        child: const Text('닫기'),
                      ),
                    ],
                  );
                },
              );
            },
            color: Colors.white,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              currentAccountPicture: const CircleAvatar(
                backgroundImage: AssetImage('assets/img/default_profile.png'),
              ),
              accountEmail: Text(
                'hanshin@hs.ac.kr',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              accountName: Text(
                '홍길동',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[850] : Colors.blueAccent,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('퀵린더'),
              onTap: () {
                setState(() {
                  _currentIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('달력'),
              onTap: () {
                setState(() {
                  _currentIndex = 1;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.event_available),
              title: const Text('이벤트'),
              onTap: () {
                setState(() {
                  _currentIndex = 2;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.emoji_events), // 공모전 항목 위치 변경
              title: const Text('공모전'),
              onTap: () {
                setState(() {
                  _currentIndex = 3;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_applications), // 설정 항목 위치 변경
              title: const Text('설정'),
              onTap: () {
                setState(() {
                  _currentIndex = 4;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _screens[_currentIndex],
      bottomNavigationBar: Card(
        elevation: 6,
        margin: const EdgeInsets.all(8.0),
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        child: SalomonBottomBar(
          duration: const Duration(seconds: 1),
          items: _items.map((item) {
            return SalomonBottomBarItem(
              icon: item.icon,
              title: item.title,
              selectedColor: isDarkMode ? Colors.white : Colors.blueAccent,
            );
          }).toList(),
          currentIndex: _currentIndex,
          onTap: (index) => setState(() {
            _currentIndex = index;
          }),
          itemPadding: const EdgeInsets.all(8),
        ),
      ),
    );
  }
}

