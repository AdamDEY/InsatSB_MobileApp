import 'dart:convert';

import '../models/event.dart';
import '../models/user.dart';
import '../services/api_client.dart';

abstract class AdminRepository {
  // Event management
  Future<List<Event>> getAllEvents();
  Future<Event> createEvent(Map<String, dynamic> eventData);
  Future<Event> updateEvent(String eventId, Map<String, dynamic> eventData);
  Future<void> deleteEvent(String eventId);

  // User management
  Future<List<AppUser>> getAllUsers();
  Future<AppUser> createUser(Map<String, dynamic> userData);
  Future<void> updateUserRole(String userId, bool isAdmin);
  Future<void> deleteUser(String userId);

  // Registration management
  Future<List<Map<String, dynamic>>> getEventRegistrations(String eventId);
  Future<void> removeUserRegistration(String eventId, String userId);

  // Check-in
  Future<Map<String, dynamic>> verifyCheckin(String token);
}

class AdminRepositoryImpl implements AdminRepository {
  final ApiClient _apiClient;

  AdminRepositoryImpl(this._apiClient);

  // Event Management
  @override
  Future<List<Event>> getAllEvents() async {
    final response = await _apiClient.getList('/api/events');
    return response
        .map((event) => Event.fromJson(event as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Event> createEvent(Map<String, dynamic> eventData) async {
    final response = await _apiClient.postJson('/api/events', eventData);
    return Event.fromJson(response);
  }

  @override
  Future<Event> updateEvent(
    String eventId,
    Map<String, dynamic> eventData,
  ) async {
    final response = await _apiClient.putJson(
      '/api/events/$eventId',
      eventData,
    );
    return Event.fromJson(response);
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    await _apiClient.delete('/api/events/$eventId');
  }

  // User Management
  @override
  Future<List<AppUser>> getAllUsers() async {
    final response = await _apiClient.getList('/api/users');
    return response
        .map((user) => AppUser.fromJson(user as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AppUser> createUser(Map<String, dynamic> userData) async {
    final response = await _apiClient.postJson('/api/auth/register', userData);
    final userJson = response['user'] as Map<String, dynamic>;
    return AppUser.fromJson(userJson);
  }

  @override
  Future<void> updateUserRole(String userId, bool isAdmin) async {
    await _apiClient.putJson('/api/users/$userId/role', {'isAdmin': isAdmin});
  }

  @override
  Future<void> deleteUser(String userId) async {
    await _apiClient.delete('/api/users/$userId');
  }

  // Registration Management
  @override
  Future<List<Map<String, dynamic>>> getEventRegistrations(
    String eventId,
  ) async {
    final response = await _apiClient.getList(
      '/api/events/$eventId/registered-users',
    );
    return response.cast<Map<String, dynamic>>();
  }

  @override
  Future<void> removeUserRegistration(String eventId, String userId) async {
    await _apiClient.delete('/api/events/$eventId/registration/$userId');
  }

  // Check-in
  @override
  Future<Map<String, dynamic>> verifyCheckin(String token) async {
    try {
      final response = await _apiClient.postJson('/api/events/check-in', {
        'token': token,
      });
      return response;
    } on ApiException catch (e) {
      String message = e.message;

      try {
        final decoded = jsonDecode(e.message);
        if (decoded is Map<String, dynamic>) {
          final rawMessage = decoded['message'];
          if (rawMessage is String) {
            message = rawMessage;
          } else if (rawMessage is List && rawMessage.isNotEmpty) {
            message = rawMessage.first.toString();
          }
        }
      } catch (_) {
        // Keep original message when body is not JSON.
      }

      throw Exception(message);
    }
  }
}
