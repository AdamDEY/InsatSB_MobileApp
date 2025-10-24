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
  Future<bool> registerForEvent() async {
    if (_event == null) return false;
    
    _setLoading(true);
    _error = null;
    
    try {
      print('EventDetailsViewModel: Registering for event: ${_event!.id}');
      
      // Register for the event in Firestore
      final success = await _eventRepository.registerForEvent(_event!.id);
      
      if (success) {
        // Update local state
        _isRegistered = true;
        
        // Reload the event to get updated registration count
        await loadEvent(_event!.id);
        
        print('EventDetailsViewModel: Successfully registered for event');
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to register for event. Please try again.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('EventDetailsViewModel: Error registering for event: $e');
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Unregister from event
  Future<bool> unregisterFromEvent() async {
    if (_event == null) return false;
    
    _setLoading(true);
    _error = null;
    
    try {
      print('EventDetailsViewModel: Unregistering from event: ${_event!.id}');
      
      // Unregister from the event in Firestore
      final success = await _eventRepository.unregisterFromEvent(_event!.id);
      
      if (success) {
        // Update local state
        _isRegistered = false;
        
        // Reload the event to get updated registration count
        await loadEvent(_event!.id);
        
        print('EventDetailsViewModel: Successfully unregistered from event');
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to unregister from event. Please try again.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('EventDetailsViewModel: Error unregistering from event: $e');
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Open LinkedIn profile
  void openLinkedIn(String linkedInUrl) {
    // In a real app, this would open the LinkedIn profile URL
    // For now, we'll just show a placeholder
    print('Opening LinkedIn profile: $linkedInUrl');
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
