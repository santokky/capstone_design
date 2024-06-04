import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'l10n/app_localization.dart';
import 'screens/ocr_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/event_screen.dart';
import 'screens/setting_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('selectedLanguage') ?? 'ko';
    setState(() {
      _locale = Locale(languageCode, '');
    });
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
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
              // 아이콘을 눌렀을 때 수행할 작업
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
