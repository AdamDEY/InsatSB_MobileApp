import 'package:flutter/material.dart';
import '../../models/event.dart';
import '../../repositories/admin_repository.dart';

class AdminEventsViewModel extends ChangeNotifier {
  final AdminRepository _adminRepository;

  List<Event> _events = [];
  bool _isLoading = false;
  String? _errorMessage;
  Event? _selectedEvent;

  AdminEventsViewModel(this._adminRepository) {
    loadEvents();
  }

  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Event? get selectedEvent => _selectedEvent;

  Future<void> loadEvents() async {
    _setLoading(true);
    _clearError();

    try {
      final events = await _adminRepository.getAllEvents();
      _events = events;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load events: ${e.toString()}');
      _setLoading(false);
    }
  }

  Future<void> createEvent(Map<String, dynamic> eventData) async {
    _setLoading(true);
    _clearError();

    try {
      final event = await _adminRepository.createEvent(eventData);
      _events.add(event);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to create event: ${e.toString()}');
      _setLoading(false);
    }
  }

  Future<void> updateEvent(
    String eventId,
    Map<String, dynamic> eventData,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedEvent = await _adminRepository.updateEvent(
        eventId,
        eventData,
      );
      final index = _events.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        _events[index] = updatedEvent;
      }
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update event: ${e.toString()}');
      _setLoading(false);
    }
  }

  Future<void> deleteEvent(String eventId) async {
    _setLoading(true);
    _clearError();

    try {
      await _adminRepository.deleteEvent(eventId);
      _events.removeWhere((e) => e.id == eventId);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete event: ${e.toString()}');
      _setLoading(false);
    }
  }

  void selectEvent(Event event) {
    _selectedEvent = event;
    notifyListeners();
  }

  void clearSelection() {
    _selectedEvent = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
