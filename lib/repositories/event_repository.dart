import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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
  Future<String?> getCheckinToken(String eventId);
  Set<String> get favoriteEventIds;
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
  final Set<String> _favoriteEventIds = <String>{};
  bool _favoritesLoaded = false;

  static const String _favoritesKey = 'favorite_event_ids';

  @override
  Set<String> get favoriteEventIds => _favoriteEventIds;

  /// Load favorites from SharedPreferences (called lazily on first access)
  Future<void> _ensureFavoritesLoaded() async {
    if (_favoritesLoaded) return;
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_favoritesKey);
    if (saved != null) {
      _favoriteEventIds.addAll(saved);
    }
    _favoritesLoaded = true;
  }

  /// Save favorites to SharedPreferences
  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, _favoriteEventIds.toList());
  }

  /// Apply favorite status to a list of events based on _favoriteEventIds
  List<Event> _applyFavoriteStatus(List<Event> events) {
    return events.map((event) {
      final isFav = _favoriteEventIds.contains(event.id);
      return event.copyWith(isFavorite: isFav);
    }).toList();
  }

  @override
  Future<List<Event>> getEvents() async {
    try {
      await _ensureFavoritesLoaded();

      // Fetch events and registrations in parallel
      final results = await Future.wait([
        _apiClient.getList('/api/events'),
        _apiClient
            .getList('/api/events/me/registrations')
            .catchError((_) => <dynamic>[]),
      ]);

      final response = results[0];
      final registrationsResponse = results[1];

      final registeredEventIds = registrationsResponse
          .map((reg) => reg['id'].toString())
          .toSet();

      // Map events and set isRegistered based on user's registrations
      final events = response.map((item) {
        final data = item as Map<String, dynamic>;
        final event = Event.fromJson(data);
        final isUserRegistered = registeredEventIds.contains(event.id);
        return event.copyWith(isRegistered: isUserRegistered);
      }).toList();

      // Apply favorite status from local storage
      return _applyFavoriteStatus(events);
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
    await _ensureFavoritesLoaded();
    final data = await _apiClient.getJson('/api/events/$id');
    final event = Event.fromJson(data);

    // Check if user is registered for this event
    try {
      final registrationsResponse = await _apiClient.getList(
        '/api/events/me/registrations',
      );
      final registeredEventIds = registrationsResponse
          .map((reg) => reg['id'].toString())
          .toSet();
      return event.copyWith(
        isRegistered: registeredEventIds.contains(event.id),
        isFavorite: _favoriteEventIds.contains(event.id),
      );
    } catch (_) {
      return event.copyWith(isFavorite: _favoriteEventIds.contains(event.id));
    }
  }

  @override
  Future<void> toggleFavorite(String eventId) async {
    await _ensureFavoritesLoaded();
    if (_favoriteEventIds.contains(eventId)) {
      _favoriteEventIds.remove(eventId);
    } else {
      _favoriteEventIds.add(eventId);
    }
    await _saveFavorites();
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
