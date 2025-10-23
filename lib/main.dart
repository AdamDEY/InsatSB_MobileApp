import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'repositories/event_repository.dart';
import 'repositories/user_repository.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/home_view_model.dart';
import 'screens/favorites/favorites_screen.dart';
import 'screens/favorites/favorites_view_model.dart';
import 'screens/calendar/calendar_screen.dart';
import 'screens/calendar/calendar_view_model.dart';
import 'screens/event_details/event_details_view_model.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/profile_view_model.dart';
import 'screens/login/login_screen.dart';
import 'screens/login/login_view_model.dart';
import 'services/firestore_auth_provider.dart';
import 'widgets/custom_nav_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const IEEEApp());
}

class IEEEApp extends StatelessWidget {
  const IEEEApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<UserRepository>(
          create: (_) => UserRepositoryImpl(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(context.read<UserRepository>()),
        ),
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
        ChangeNotifierProvider<ProfileViewModel>(
          create: (context) => ProfileViewModel(
            context.read<EventRepository>(),
            context.read<AuthProvider>(),
          ),
        ),
        ChangeNotifierProvider<LoginViewModel>(
          create: (context) => LoginViewModel(
            context.read<AuthProvider>(),
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
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.isLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            if (authProvider.isSignedIn) {
              return const MainApp();
            } else {
              return const LoginScreen();
            }
          },
        ),
        routes: {
          '/main': (context) => const MainApp(),
        },
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
      extendBodyBehindAppBar: false,
      body: SafeArea(
        child: _getCurrentScreen(),
      ),
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
        return const ProfileScreen();
    }
  }

}