import 'package:flutter/foundation.dart';
import '../../models/event.dart';
import '../../repositories/event_repository.dart';

class EventDetailsViewModel extends ChangeNotifier {
  final EventRepository _eventRepository;
  Event? _event;
  bool _isLoading = false;
  String? _error;
  bool _isRegistered = false;

  EventDetailsViewModel(this._eventRepository);

  // Getters
  Event? get event => _event;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isRegistered => _isRegistered;

  // Load event details
  Future<void> loadEvent(String eventId) async {
    _setLoading(true);
    _error = null;
    
    try {
      _event = await _eventRepository.getEventById(eventId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Toggle favorite status
  Future<void> toggleFavorite() async {
    if (_event == null) return;
    
    try {
      await _eventRepository.toggleFavorite(_event!.id);
      _event = _event!.copyWith(isFavorite: !_event!.isFavorite);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Register for event
  Future<void> registerForEvent() async {
    if (_event == null) return;
    
    try {
      // Simulate registration process
      await Future.delayed(const Duration(seconds: 1));
      _isRegistered = true;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Open LinkedIn profile
  void openLinkedIn() {
    // In a real app, this would open the LinkedIn profile
    // For now, we'll just show a placeholder
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
