import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../repositories/event_repository.dart';
import '../../widgets/event_card.dart';
import '../event_details/event_details_screen.dart';

class RegisteredEventsScreen extends StatefulWidget {
  const RegisteredEventsScreen({super.key});

  @override
  State<RegisteredEventsScreen> createState() => _RegisteredEventsScreenState();
}

class _RegisteredEventsScreenState extends State<RegisteredEventsScreen> {
  List<Event> _registeredEvents = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRegisteredEvents();
  }

  Future<void> _loadRegisteredEvents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final eventRepository = context.read<EventRepository>();
      final allEvents = await eventRepository.getEvents();
      setState(() {
        _registeredEvents = allEvents
            .where((event) => event.isRegistered)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.chevron_left,
            color: isDark ? Colors.white : Colors.black,
            size: 28,
          ),
        ),
        title: Text(
          'Registered Events',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: $_error',
              style: const TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRegisteredEvents,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_registeredEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No registered events yet',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRegisteredEvents,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: _registeredEvents.length,
        itemBuilder: (context, index) {
          final event = _registeredEvents[index];
          return EventCard(
            event: event,
            onFavoritePressed: () {},
            onCardPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EventDetailsScreen(eventId: event.id),
                ),
              );
              // Refresh after returning from details
              _loadRegisteredEvents();
            },
          );
        },
      ),
    );
  }
}
