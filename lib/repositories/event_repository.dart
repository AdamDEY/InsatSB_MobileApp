import 'dart:convert';
import '../models/event.dart';
import '../services/api_client.dart';

abstract class EventRepository {
  Future<List<Event>> getEvents();
  Future<List<Event>> getEventsByCategory(String category);
  Future<List<Event>> getEventsByChapter(String chapter);
  Future<Event> getEventById(String id);
  Future<void> toggleFavorite(String eventId);
  Future<RegistrationResult> registerForEvent(String eventId);
  Future<bool> unregisterFromEvent(String eventId);
}

class RegistrationResult {
  final bool success;
  final String? message;

  RegistrationResult({required this.success, this.message});
}

class EventRepositoryImpl implements EventRepository {
  EventRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;
  final Set<String> _favoriteEventIds = <String>{};

  @override
  Future<List<Event>> getEvents() async {
    try {
      // Fetch all events
      final response = await _apiClient.getList('/api/events');

      // Fetch user's registrations
      List<String> registeredEventIds = [];
      try {
        final registrationsResponse = await _apiClient.getList(
          '/api/events/me/registrations',
        );
        registeredEventIds = registrationsResponse
            .map((reg) => reg['id'].toString())
            .toList();
      } catch (e) {
        print('Could not fetch user registrations: $e');
      }

      // Map events and set isRegistered based on user's registrations
      return response.map((item) {
        final data = item as Map<String, dynamic>;
        final event = Event.fromJson(data);

        // Override isRegistered based on actual user registration
        final isUserRegistered = registeredEventIds.contains(event.id);
        return event.copyWith(isRegistered: isUserRegistered);
      }).toList();
    } catch (e) {
      print('Error fetching events: $e');
      rethrow;
    }
  }

  @override
  Future<List<Event>> getEventsByCategory(String category) async {
    try {
      final events = await getEvents();
      if (category == 'All') {
        return events;
      }
      return events.where((event) => event.category == category).toList();
    } catch (e) {
      print('Error fetching events by category: $e');
      return [];
    }
  }

  @override
  Future<List<Event>> getEventsByChapter(String chapter) async {
    try {
      final events = await getEvents();
      if (chapter == 'All') {
        return events;
      }
      return events
          .where((event) => event.chapter.displayName == chapter)
          .toList();
    } catch (e) {
      print('Error fetching events by chapter: $e');
      return [];
    }
  }

  @override
  Future<Event> getEventById(String id) async {
    try {
      final data = await _apiClient.getJson('/api/events/$id');
      final event = Event.fromJson(data);

      // Check if user is registered for this event
      try {
        final registrationsResponse = await _apiClient.getList(
          '/api/events/me/registrations',
        );
        final registeredEventIds = registrationsResponse
            .map((reg) => reg['id'].toString())
            .toList();
        final isUserRegistered = registeredEventIds.contains(event.id);
        return event.copyWith(isRegistered: isUserRegistered);
      } catch (e) {
        print('Could not fetch user registrations: $e');
        return event;
      }
    } catch (e) {
      print('Error fetching event by ID: $e');
      throw Exception('Event not found');
    }
  }

  @override
  Future<void> toggleFavorite(String eventId) async {
    if (_favoriteEventIds.contains(eventId)) {
      _favoriteEventIds.remove(eventId);
    } else {
      _favoriteEventIds.add(eventId);
    }
  }

  @override
  Future<RegistrationResult> registerForEvent(String eventId) async {
    try {
      await _apiClient.postJson(
        '/api/events/$eventId/register',
        <String, dynamic>{},
      );
      return RegistrationResult(success: true);
    } catch (e) {
      print('Error registering for event: $e');

      String errorMessage = 'Failed to register. Please try again.';
      final exceptionStr = e.toString();

      // If user is already registered, consider it a success
      if (exceptionStr.contains('already registered')) {
        return RegistrationResult(success: true, message: 'Already registered');
      }

      // Parse the JSON from the error response if it exists
      if (exceptionStr.contains('ApiException')) {
        try {
          // Extract the JSON part from "ApiException(statusCode): {json}"
          final jsonStart = exceptionStr.indexOf('{');
          if (jsonStart != -1) {
            final jsonStr = exceptionStr.substring(jsonStart);
            final decoded = jsonDecode(jsonStr);

            if (decoded is Map && decoded.containsKey('message')) {
              errorMessage = decoded['message'];
            }
          }
        } catch (parseError) {
          print('Could not parse error JSON: $parseError');
          // Fall back to checking the string
          if (exceptionStr.contains('Event has reached maximum capacity')) {
            errorMessage = 'Event is full - no spots available';
          }
        }
      }

      return RegistrationResult(success: false, message: errorMessage);
    }
  }

  @override
  Future<bool> unregisterFromEvent(String eventId) async {
    try {
      await _apiClient.delete('/api/events/$eventId/register');
      return true;
    } catch (e) {
      print('Error unregistering for event: $e');
      return false;
    }
  }
}
