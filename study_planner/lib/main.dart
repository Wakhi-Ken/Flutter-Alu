import 'package:flutter/material.dart';
import 'screens/today.dart';
import 'screens/calendar.dart';
import 'screens/settings.dart';
import 'services/reminders.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Study Planner',
      // Dark theme with custom colors
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFF2962FF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1E1E1E),
          selectedItemColor: Color(0xFF2962FF),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF2962FF),
          foregroundColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Home page with bottom navigation
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  // State management for bottom navigation
  @override
  State<HomePage> createState() => _HomePageState();
}

// State class for HomePage
class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final String _storageMethod = "SharedPreferences";
  late final List<Widget> _pages;
  // Initialize pages and start reminder service
  @override
  void initState() {
    super.initState();
    _pages = [
      const TodayScreen(),
      const CalendarScreen(),
      SettingsScreen(storageMethod: _storageMethod),
    ];
    // Start the reminder service after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ReminderService.start(context);
    });
  }

  // Build method with IndexedStack for page management
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.today), label: 'Today'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
