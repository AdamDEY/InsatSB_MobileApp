import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../repositories/admin_repository.dart';
import 'admin_events_view_model.dart';
import 'admin_users_view_model.dart';
import 'admin_events_screen.dart';
import 'admin_users_screen.dart';
import 'admin_registrations_screen.dart';
import 'admin_checkin_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminRepository = context.read<AdminRepository>();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AdminEventsViewModel(adminRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => AdminUsersViewModel(adminRepository),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel'),
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.event), text: 'Events'),
              Tab(icon: Icon(Icons.people), text: 'Users'),
              Tab(icon: Icon(Icons.app_registration), text: 'Registrations'),
              Tab(icon: Icon(Icons.qr_code_scanner), text: 'Check-in'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            AdminEventsScreen(),
            AdminUsersScreen(),
            AdminRegistrationsScreen(),
            AdminCheckinScreen(),
          ],
        ),
      ),
    );
  }
}
