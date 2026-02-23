import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../repositories/admin_repository.dart';

class AdminRegistrationsScreen extends StatefulWidget {
  const AdminRegistrationsScreen({super.key});

  @override
  State<AdminRegistrationsScreen> createState() =>
      _AdminRegistrationsScreenState();
}

class _AdminRegistrationsScreenState extends State<AdminRegistrationsScreen> {
  List<Event> _events = [];
  bool _loadingEvents = true;
  String? _errorMessage;
  String? _selectedEventId;
  List<Map<String, dynamic>> _registrations = [];
  bool _loadingRegistrations = false;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final adminRepository = context.read<AdminRepository>();
      final events = await adminRepository.getAllEvents();
      setState(() {
        _events = events;
        _loadingEvents = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load events: ${e.toString()}';
        _loadingEvents = false;
      });
    }
  }

  Future<void> _selectEvent(Event event) async {
    setState(() {
      _selectedEventId = event.id;
      _loadingRegistrations = true;
      _errorMessage = null;
    });

    try {
      final adminRepository = context.read<AdminRepository>();
      final registrations = await adminRepository.getEventRegistrations(
        event.id,
      );
      setState(() {
        _registrations = registrations;
        _loadingRegistrations = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load registrations: ${e.toString()}';
        _loadingRegistrations = false;
      });
    }
  }

  Future<void> _removeRegistration(String userId, String userName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Registration'),
        content: Text('Remove $userName from this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final adminRepository = context.read<AdminRepository>();
      if (_selectedEventId != null) {
        print(
          '🗑️ Attempting to remove user $userId from event $_selectedEventId',
        );
        await adminRepository.removeUserRegistration(_selectedEventId!, userId);
        print('✅ User removed successfully');

        // Reload registrations
        if (_selectedEventId != null) {
          final registrations = await adminRepository.getEventRegistrations(
            _selectedEventId!,
          );
          setState(() {
            _registrations = registrations;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$userName removed from event')),
          );
        }
      }
    } catch (e) {
      print('❌ Error removing registration: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove registration: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _selectedEventId == null
        ? _buildEventsList()
        : _buildRegistrations();
  }

  Widget _buildEventsList() {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Events (${_events.length})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_errorMessage!),
              ),
            ),
          Expanded(
            child: _loadingEvents
                ? const Center(child: CircularProgressIndicator())
                : _events.isEmpty
                ? const Center(child: Text('No events found'))
                : ListView.builder(
                    itemCount: _events.length,
                    itemBuilder: (context, index) {
                      final event = _events[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: ListTile(
                          title: Text(event.title),
                          subtitle: Text(
                            '${event.registrations}/${event.attendeesNeeded} registered',
                          ),
                          trailing: const Icon(Icons.arrow_forward),
                          onTap: () => _selectEvent(event),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrations() {
    Event? event;
    if (_selectedEventId != null) {
      try {
        event = _events.firstWhere((e) => e.id == _selectedEventId);
      } catch (e) {
        event = null;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrations'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _selectedEventId = null;
              _registrations = [];
            });
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event?.title ?? 'Event',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '${_registrations.length}/${event?.attendeesNeeded ?? 0} registered',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_errorMessage!),
              ),
            ),
          Expanded(
            child: _loadingRegistrations
                ? const Center(child: CircularProgressIndicator())
                : _registrations.isEmpty
                ? const Center(child: Text('No registrations yet'))
                : ListView.builder(
                    itemCount: _registrations.length,
                    itemBuilder: (context, index) {
                      final reg = _registrations[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: ListTile(
                          title: Text(reg['fullName'] ?? 'Unknown'),
                          subtitle: Text(reg['email'] ?? 'No email'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeRegistration(
                              reg['id']?.toString() ?? '',
                              reg['fullName'] ?? 'User',
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
