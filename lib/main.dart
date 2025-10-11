import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'repositories/event_repository.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/home_view_model.dart';
import 'screens/favorites/favorites_screen.dart';
import 'screens/favorites/favorites_view_model.dart';
import 'screens/calendar/calendar_screen.dart';
import 'screens/calendar/calendar_view_model.dart';
import 'screens/event_details/event_details_view_model.dart';
import 'widgets/custom_nav_bar.dart';

void main() {
  runApp(const IEEEApp());
}

class IEEEApp extends StatelessWidget {
  const IEEEApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<EventRepository>(
          create: (_) => EventRepositoryImpl(),
        ),
        ChangeNotifierProvider<HomeViewModel>(
          create: (context) => HomeViewModel(
            context.read<EventRepository>(),
          ),
        ),
        ChangeNotifierProvider<FavoritesViewModel>(
          create: (context) => FavoritesViewModel(
            context.read<EventRepository>(),
          ),
        ),
        ChangeNotifierProvider<CalendarViewModel>(
          create: (context) => CalendarViewModel(
            context.read<EventRepository>(),
          ),
        ),
        ChangeNotifierProvider<EventDetailsViewModel>(
          create: (context) => EventDetailsViewModel(
            context.read<EventRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'IEEE Mobile App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF8B5CF6),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Montserrat',
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontFamily: 'Montserrat'),
            displayMedium: TextStyle(fontFamily: 'Montserrat'),
            displaySmall: TextStyle(fontFamily: 'Montserrat'),
            headlineLarge: TextStyle(fontFamily: 'Montserrat'),
            headlineMedium: TextStyle(fontFamily: 'Montserrat'),
            headlineSmall: TextStyle(fontFamily: 'Montserrat'),
            titleLarge: TextStyle(fontFamily: 'Montserrat'),
            titleMedium: TextStyle(fontFamily: 'Montserrat'),
            titleSmall: TextStyle(fontFamily: 'Montserrat'),
            bodyLarge: TextStyle(fontFamily: 'Montserrat'),
            bodyMedium: TextStyle(fontFamily: 'Montserrat'),
            bodySmall: TextStyle(fontFamily: 'Montserrat'),
            labelLarge: TextStyle(fontFamily: 'Montserrat'),
            labelMedium: TextStyle(fontFamily: 'Montserrat'),
            labelSmall: TextStyle(fontFamily: 'Montserrat'),
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF8B5CF6),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          fontFamily: 'Montserrat',
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontFamily: 'Montserrat'),
            displayMedium: TextStyle(fontFamily: 'Montserrat'),
            displaySmall: TextStyle(fontFamily: 'Montserrat'),
            headlineLarge: TextStyle(fontFamily: 'Montserrat'),
            headlineMedium: TextStyle(fontFamily: 'Montserrat'),
            headlineSmall: TextStyle(fontFamily: 'Montserrat'),
            titleLarge: TextStyle(fontFamily: 'Montserrat'),
            titleMedium: TextStyle(fontFamily: 'Montserrat'),
            titleSmall: TextStyle(fontFamily: 'Montserrat'),
            bodyLarge: TextStyle(fontFamily: 'Montserrat'),
            bodyMedium: TextStyle(fontFamily: 'Montserrat'),
            bodySmall: TextStyle(fontFamily: 'Montserrat'),
            labelLarge: TextStyle(fontFamily: 'Montserrat'),
            labelMedium: TextStyle(fontFamily: 'Montserrat'),
            labelSmall: TextStyle(fontFamily: 'Montserrat'),
          ),
        ),
        themeMode: ThemeMode.system,
        home: const MainApp(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  NavBarItem _currentItem = NavBarItem.home;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getCurrentScreen(),
      bottomNavigationBar: CustomNavBar(
        currentItem: _currentItem,
        onItemSelected: (item) {
          setState(() {
            _currentItem = item;
          });
        },
      ),
    );
  }

  Widget _getCurrentScreen() {
    switch (_currentItem) {
      case NavBarItem.home:
        return const HomeScreen();
      case NavBarItem.favorites:
        return const FavoritesScreen();
      case NavBarItem.calendar:
        return const CalendarScreen();
      case NavBarItem.profile:
        return _buildPlaceholderScreen('Profile', 'User profile will be shown here');
    }
  }

  Widget _buildPlaceholderScreen(String title, String subtitle) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.construction,
                size: 80,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}