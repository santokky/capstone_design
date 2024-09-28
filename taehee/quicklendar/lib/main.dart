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
//import 'package:mysql_client/mysql_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);
  //dbConnector();
  runApp(const MyApp());
}

// Future<void> dbConnector() async {
//   print("Connecting to mysql server...");
//
//   // MySQL 접속 설정
//   final conn = await MySQLConnection.createConnection(
//     host: 'http://127.0.0.1/localhost',
//     port: 3306,
//     userName: 'root',
//     password: 'onlyroot',
//     databaseName: 'quicklendar', // optional
//   );
//
//   // 연결 대기
//   await conn.connect();
//
//   print("Connected");
//
//   // 종료 대기
//   await conn.close();
// }

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  static void setNotificationsEnabled(BuildContext context, bool enabled) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setNotificationsEnabled(enabled);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  bool _notificationsEnabled = true;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isLoggedIn = false;

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
    setState(() {
      _locale = Locale(languageCode, '');
      _notificationsEnabled = notificationsEnabled;
      _isLoggedIn = isLoggedIn;
    });
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification() async {
    if (!_notificationsEnabled) return;

    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your channel id', 'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      '알림 제목',
      '알림 내용',
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  void setNotificationsEnabled(bool enabled) {
    setState(() {
      _notificationsEnabled = enabled;
    });
    if (!enabled) {
      flutterLocalNotificationsPlugin.cancelAll();
    }
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
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          color: Colors.white,
        ),
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: Colors.blueAccent, // 주요 색상
          secondary: Colors.white,
          primaryContainer: Colors.blueAccent,
          onBackground: Colors.blueAccent
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white
          )
        ),
        scaffoldBackgroundColor: Colors.white,
        canvasColor: Colors.white,
        primaryColor: Colors.blueAccent,
        // inputDecorationTheme: const InputDecorationTheme(
        //   filled: true,
        //   fillColor: Colors.white, // 모든 TextField의 배경색을 흰색으로 설정
        // ),
      ),
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
      icon: const Icon(Icons.settings_applications),
      title: const Text('설정'),
      selectedColor: Colors.blueAccent,
    ),
  ];

  final _screens = const [
    OCRScreen(),
    CalendarScreen(),
    EventScreen(),
    SettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
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
            onPressed: () {
              final myAppState = context.findAncestorStateOfType<_MyAppState>();
              myAppState?._showNotification();
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
                backgroundImage: AssetImage('assets/calendar.png'),
              ),
              accountEmail: const Text('hanshin@hs.ac.kr'),
              accountName: const Text('캡디 5팀'),
              onDetailsPressed: () {
                print('press details');
              },
              // decoration: const BoxDecoration(
              //   color: Colors.blueAccent,
              //   borderRadius: BorderRadius.only(
              //     bottomLeft: Radius.circular(40),
              //     bottomRight: Radius.circular(40),
              //   ),
              // ),
              decoration: const BoxDecoration(
                color: Colors.blueAccent,  // 배경색만 설정
                // 검은 선이나 그림자를 없애기 위해 boxShadow나 border를 추가하지 않음
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
              leading: const Icon(Icons.settings_applications),
              title: const Text('설정'),
              onTap: () {
                setState(() {
                  _currentIndex = 3;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.emoji_events),
              title: const Text('공모전'),
              onTap: () {
                Navigator.pushNamed(context, '/contest'); // 새로 추가된 경로로 이동
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: _screens[_currentIndex],
      bottomNavigationBar: Card(
        elevation: 6,
        margin: const EdgeInsets.all(8.0),
        color: Colors.white,
        child: SalomonBottomBar(
          duration: const Duration(seconds: 1),
          items: _items,
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
