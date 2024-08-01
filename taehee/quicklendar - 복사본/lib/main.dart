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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);
  runApp(const MyApp());
}

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
    setState(() {
      _locale = Locale(languageCode, '');
      _notificationsEnabled = notificationsEnabled;
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
<<<<<<< HEAD
        appBarTheme: const AppBarTheme(
          color: Colors.white,
=======
        appBarTheme: AppBarTheme(
          color: Colors.white
>>>>>>> parent of 8fb5c42 (로켈DB를 사용해 캘린더에서 일정 입력가능,)
        ),
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Colors.white,
      ),
      home: const HomeScreen(),
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
    OCRScreen(), // 카메라 기능이 포함된 OCRScreen 사용
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
              // 알림 예시
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
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('퀵린더'),
              onTap: () {
                setState(() {
                  _currentIndex = 0;
                });
                Navigator.pop(context); // 드로어를 닫습니다.
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('달력'),
              onTap: () {
                setState(() {
                  _currentIndex = 1;
                });
                Navigator.pop(context); // 드로어를 닫습니다.
              },
            ),
            ListTile(
              leading: const Icon(Icons.event_available),
              title: const Text('이벤트'),
              onTap: () {
                setState(() {
                  _currentIndex = 2;
                });
                Navigator.pop(context); // 드로어를 닫습니다.
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_applications),
              title: const Text('설정'),
              onTap: () {
                setState(() {
                  _currentIndex = 3;
                });
                Navigator.pop(context); // 드로어를 닫습니다.
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
