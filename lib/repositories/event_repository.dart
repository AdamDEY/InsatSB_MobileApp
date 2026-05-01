import 'dart:convert';
import '../models/event.dart';
import '../services/api_client.dart';

abstract class EventRepository {
  Future<List<Event>> getEvents();
  Future<List<Event>> getEventsByCategory(String category);
  Future<List<Event>> getEventsByChapter(String chapter);
  Future<Event> getEventById(String id);
  Future<List<Event>> getFavoriteEvents();
  Future<bool> toggleFavorite(String eventId);
  Future<RegistrationResult> registerForEvent(String eventId);
  Future<bool> unregisterFromEvent(String eventId);
  Future<String?> getCheckinToken(String eventId);
}

class RegistrationResult {
  final bool success;
  final String? message;
  final String? checkinToken;

  RegistrationResult({required this.success, this.message, this.checkinToken});
}

class EventRepositoryImpl implements EventRepository {
  EventRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;
  List<Event> _applyFavoriteStatus(
    List<Event> events,
    Set<String> favoriteEventIds,
  ) {
    return events.map((event) {
      final isFav = favoriteEventIds.contains(event.id);
      return event.copyWith(isFavorite: isFav);
    }).toList();
  }

  Future<Set<String>> _fetchFavoriteEventIds() async {
    final favoritesResponse = await _apiClient.getList(
      '/api/events/me/favorites',
    );
    return favoritesResponse
        .map((item) => (item as Map<String, dynamic>)['id'].toString())
        .toSet();
  }

  @override
  Future<List<Event>> getEvents() async {
    try {
      // Fetch events, registrations, and user favorites in parallel.
      final results = await Future.wait([
        _apiClient.getList('/api/events'),
        _apiClient
            .getList('/api/events/me/registrations')
            .catchError((_) => <dynamic>[]),
        _apiClient
            .getList('/api/events/me/favorites')
            .catchError((_) => <dynamic>[]),
      ]);

      final response = results[0];
      final registrationsResponse = results[1];
      final favoritesResponse = results[2];

      final registeredEventIds = registrationsResponse
          .map((reg) => reg['id'].toString())
          .toSet();

      final favoriteEventIds = favoritesResponse
          .map((item) => (item as Map<String, dynamic>)['id'].toString())
          .toSet();

      // Map events and set isRegistered based on user's registrations
      final events = response.map((item) {
        final data = item as Map<String, dynamic>;
        final event = Event.fromJson(data);
        final isUserRegistered = registeredEventIds.contains(event.id);
        return event.copyWith(isRegistered: isUserRegistered);
      }).toList();

      return _applyFavoriteStatus(events, favoriteEventIds);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Event>> getEventsByCategory(String category) async {
    final events = await getEvents();
    if (category == 'All') return events;
    return events.where((event) => event.category == category).toList();
  }

  @override
  Future<List<Event>> getEventsByChapter(String chapter) async {
    final events = await getEvents();
    if (chapter == 'All') return events;
    return events
        .where((event) => event.chapter.displayName == chapter)
        .toList();
  }

  @override
  Future<Event> getEventById(String id) async {
    final data = await _apiClient.getJson('/api/events/$id');
    final event = Event.fromJson(data);

    // Check registration and favorite flags for this user.
    try {
      final results = await Future.wait([
        _apiClient
            .getList('/api/events/me/registrations')
            .catchError((_) => <dynamic>[]),
        _apiClient
            .getList('/api/events/me/favorites')
            .catchError((_) => <dynamic>[]),
      ]);

      final registrationsResponse = results[0];
      final favoritesResponse = results[1];

      final registeredEventIds = registrationsResponse
          .map((reg) => reg['id'].toString())
          .toSet();

      final favoriteEventIds = favoritesResponse
          .map((item) => (item as Map<String, dynamic>)['id'].toString())
          .toSet();

      return event.copyWith(
        isRegistered: registeredEventIds.contains(event.id),
        isFavorite: favoriteEventIds.contains(event.id),
      );
    } catch (_) {
      return event;
    }
  }

  @override
  Future<List<Event>> getFavoriteEvents() async {
    final response = await _apiClient.getList('/api/events/me/favorites');
    final favoriteEvents = response
        .map((item) => Event.fromJson(item as Map<String, dynamic>))
        .map((event) => event.copyWith(isFavorite: true))
        .toList();
    return favoriteEvents;
  }

  @override
  Future<bool> toggleFavorite(String eventId) async {
    final favoriteEventIds = await _fetchFavoriteEventIds();
    final isFavorite = favoriteEventIds.contains(eventId);

    if (isFavorite) {
      await _apiClient.delete('/api/events/$eventId/favorite');
      return false;
    }

    try {
      await _apiClient.postJson(
        '/api/events/$eventId/favorite',
        <String, dynamic>{},
      );
      return true;
    } on ApiException catch (e) {
      if (e.statusCode == 409) {
        return true;
      }
      rethrow;
    }
  }

  @override
  Future<RegistrationResult> registerForEvent(String eventId) async {
    try {
      final response = await _apiClient.postJson(
        '/api/events/$eventId/register',
        <String, dynamic>{},
      );
      final token = response['checkinToken'] as String?;
      return RegistrationResult(success: true, checkinToken: token);
    } catch (e) {
      final exceptionStr = e.toString();

      // If user is already registered, consider it a success
      if (exceptionStr.contains('already registered')) {
        return RegistrationResult(success: true, message: 'Already registered');
      }

      String errorMessage = 'Failed to register. Please try again.';

      // Parse the JSON from the error response if it exists
      if (exceptionStr.contains('ApiException')) {
        try {
          final jsonStart = exceptionStr.indexOf('{');
          if (jsonStart != -1) {
            final jsonStr = exceptionStr.substring(jsonStart);
            final decoded = jsonDecode(jsonStr);
            if (decoded is Map && decoded.containsKey('message')) {
              errorMessage = decoded['message'];
            }
          }
        } catch (_) {
          if (exceptionStr.contains('maximum capacity')) {
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
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String?> getCheckinToken(String eventId) async {
    try {
      final response = await _apiClient.getJson(
        '/api/events/$eventId/checkin-token',
      );
      return response['checkinToken'] as String?;
    } catch (_) {
      return null;
    }
  }
}
