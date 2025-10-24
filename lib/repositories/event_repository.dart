import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';

abstract class EventRepository {
  Future<List<Event>> getEvents();
  Future<List<Event>> getEventsByCategory(String category);
  Future<List<Event>> getEventsByChapter(String chapter);
  Future<Event> getEventById(String id);
  Future<void> toggleFavorite(String eventId);
  Future<bool> registerForEvent(String eventId);
  Future<bool> unregisterFromEvent(String eventId);
}

class EventRepositoryImpl implements EventRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Set<String> _favoriteEventIds = <String>{};
  
  @override
  Future<List<Event>> getEvents() async {
    try {
      print('Attempting to fetch events from Firestore...');
      final QuerySnapshot snapshot = await _firestore
          .collection('events')
          .orderBy('date', descending: false)
          .get();
      
      print('Successfully fetched ${snapshot.docs.length} events from Firestore');
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Event.fromJson({
          'id': doc.id,
          ...data,
        });
      }).toList();
    } catch (e) {
      print('Error fetching events: $e');
      print('Error type: ${e.runtimeType}');
      if (e.toString().contains('Unable to establish connection')) {
        print('Connection issue detected. This might be due to:');
        print('1. Network connectivity issues');
        print('2. Firestore security rules blocking access');
        print('3. Firebase project configuration issues');
        print('4. Platform-specific Firebase setup issues');
      }
      return [];
    }
  }

  @override
  Future<List<Event>> getEventsByCategory(String category) async {
    try {
      Query query = _firestore.collection('events');
      
      if (category != 'All') {
        query = query.where('category', isEqualTo: category);
      }
      
      final QuerySnapshot snapshot = await query
          .orderBy('date', descending: false)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Event.fromJson({
          'id': doc.id,
          ...data,
        });
      }).toList();
    } catch (e) {
      print('Error fetching events by category: $e');
      return [];
    }
  }

  @override
  Future<List<Event>> getEventsByChapter(String chapter) async {
    try {
      print('Attempting to fetch events by chapter: $chapter');
      Query query = _firestore.collection('events');
      
      if (chapter != 'All') {
        query = query.where('chapter', isEqualTo: chapter);
        print('Filtering by chapter: $chapter');
      } else {
        print('Fetching all events (no chapter filter)');
      }
      
      final QuerySnapshot snapshot = await query
          .orderBy('date', descending: false)
          .get();
      
      print('Successfully fetched ${snapshot.docs.length} events for chapter: $chapter');
      
      final events = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Event.fromJson({
          'id': doc.id,
          ...data,
        });
      }).toList();
      
      // Log the chapters of fetched events for debugging
      for (final event in events) {
        print('Event: ${event.title} - Chapter: ${event.chapter.displayName}');
      }
      
      return events;
    } catch (e) {
      print('Error fetching events by chapter: $e');
      print('Error type: ${e.runtimeType}');
      return [];
    }
  }

  @override
  Future<Event> getEventById(String id) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection('events')
          .doc(id)
          .get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return Event.fromJson({
          'id': doc.id,
          ...data,
        });
      } else {
        throw Exception('Event not found');
      }
    } catch (e) {
      print('Error fetching event by ID: $e');
      throw Exception('Event not found');
    }
  }

  @override
  Future<void> toggleFavorite(String eventId) async {
    // For now, we'll keep favorites in memory
    // In a real app, you might want to store this in Firestore user document
    if (_favoriteEventIds.contains(eventId)) {
      _favoriteEventIds.remove(eventId);
    } else {
      _favoriteEventIds.add(eventId);
    }
  }

  @override
  Future<bool> registerForEvent(String eventId) async {
    try {
      print('Attempting to register for event: $eventId');
      
      // Use Firestore transaction to safely increment registrations
      await _firestore.runTransaction((transaction) async {
        final eventRef = _firestore.collection('events').doc(eventId);
        final eventDoc = await transaction.get(eventRef);
        
        if (!eventDoc.exists) {
          throw Exception('Event not found');
        }
        
        final currentRegistrations = eventDoc.data()?['registrations'] ?? 0;
        final attendeesNeeded = eventDoc.data()?['attendeesNeeded'] ?? 0;
        
        // Check if event is full
        if (currentRegistrations >= attendeesNeeded) {
          throw Exception('Event is full');
        }
        
        // Increment registrations
        transaction.update(eventRef, {
          'registrations': currentRegistrations + 1,
        });
      });
      
      print('Successfully registered for event: $eventId');
      return true;
    } catch (e) {
      print('Error registering for event: $e');
      return false;
    }
  }

  @override
  Future<bool> unregisterFromEvent(String eventId) async {
    try {
      print('Attempting to unregister from event: $eventId');
      
      // Use Firestore transaction to safely decrement registrations
      await _firestore.runTransaction((transaction) async {
        final eventRef = _firestore.collection('events').doc(eventId);
        final eventDoc = await transaction.get(eventRef);
        
        if (!eventDoc.exists) {
          throw Exception('Event not found');
        }
        
        final currentRegistrations = eventDoc.data()?['registrations'] ?? 0;
        
        // Check if there are registrations to decrement
        if (currentRegistrations <= 0) {
          throw Exception('No registrations to remove');
        }
        
        // Decrement registrations
        transaction.update(eventRef, {
          'registrations': currentRegistrations - 1,
        });
      });
      
      print('Successfully unregistered from event: $eventId');
      return true;
    } catch (e) {
      print('Error unregistering from event: $e');
      return false;
    }
  }

}
