import '../models/event.dart';

abstract class EventRepository {
  Future<List<Event>> getEvents();
  Future<List<Event>> getEventsByCategory(String category);
  Future<Event> getEventById(String id);
  Future<void> toggleFavorite(String eventId);
}

class EventRepositoryImpl implements EventRepository {
  // This would typically connect to a real API
  // For now, we'll use mock data with persistent favorites
  final Set<String> _favoriteEventIds = <String>{};
  
  @override
  Future<List<Event>> getEvents() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    return _getMockEvents();
  }

  @override
  Future<List<Event>> getEventsByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final allEvents = _getMockEvents();
    if (category == 'All') {
      return allEvents;
    }
    return allEvents.where((event) => event.category == category).toList();
  }

  @override
  Future<Event> getEventById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final events = _getMockEvents();
    return events.firstWhere((event) => event.id == id);
  }

  @override
  Future<void> toggleFavorite(String eventId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (_favoriteEventIds.contains(eventId)) {
      _favoriteEventIds.remove(eventId);
    } else {
      _favoriteEventIds.add(eventId);
    }
  }

  List<Event> _getMockEvents() {
    final baseEvents = [
      Event(
        id: '1',
        title: 'Introduction To Machine Learning',
        description: 'Learn the fundamentals of machine learning',
        date: DateTime(2025, 10, 15),
        startTime: DateTime(2025, 10, 15, 14, 0),
        endTime: DateTime(2025, 10, 15, 16, 0),
        category: 'CS',
        attendees: 45,
        level: 'Beginner friendly',
        imageUrl: 'https://via.placeholder.com/400x200/4A90E2/FFFFFF?text=Machine+Learning',
        isFeatured: true,
        isFavorite: false,
        isRegistered: true,
      ),
      Event(
        id: '2',
        title: 'IOT In Robotics',
        description: 'Explore IoT applications in robotics',
        date: DateTime(2025, 10, 15),
        startTime: DateTime(2025, 10, 15, 14, 0),
        endTime: DateTime(2025, 10, 15, 16, 0),
        category: 'IOT',
        attendees: 45,
        level: 'Intermediate',
        imageUrl: 'https://via.placeholder.com/400x200/7ED321/FFFFFF?text=IOT+Robotics',
        isFeatured: false,
        isFavorite: false,
        isRegistered: true,
      ),
      Event(
        id: '3',
        title: 'Introduction To Machine Learning',
        description: 'Learn the fundamentals of machine learning',
        date: DateTime(2025, 10, 15),
        startTime: DateTime(2025, 10, 15, 14, 0),
        endTime: DateTime(2025, 10, 15, 16, 0),
        category: 'IOT',
        attendees: 45,
        level: 'Beginner friendly',
        imageUrl: 'https://via.placeholder.com/400x200/50E3C2/FFFFFF?text=ML+Workshop',
        isFeatured: false,
        isFavorite: false,
        isRegistered: false,
      ),
    ];

    // Update favorites based on persistent state
    return baseEvents.map((event) {
      return event.copyWith(
        isFavorite: _favoriteEventIds.contains(event.id),
      );
    }).toList();
  }
}
