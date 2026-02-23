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
    final response = await _apiClient.postJson('/api/events/check-in', {
      'token': token,
    });
    return response;
  }
}
