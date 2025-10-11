import 'package:flutter/foundation.dart';
import '../../models/event.dart';
import '../../repositories/event_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final EventRepository _eventRepository;
  
  HomeViewModel(this._eventRepository);

  List<Event> _events = [];
  final List<String> _categories = ['All', 'RAS', 'CS', 'IAS', 'PESxPELS', 'EMBS'];
  String _selectedCategory = 'All';
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Event> get events => _events;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize the home screen
  Future<void> initialize() async {
    await loadEvents();
  }

  // Load events based on selected category
  Future<void> loadEvents() async {
    _setLoading(true);
    _error = null;
    
    try {
      if (_selectedCategory == 'All') {
        _events = await _eventRepository.getEvents();
      } else {
        _events = await _eventRepository.getEventsByCategory(_selectedCategory);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Select a category and reload events
  Future<void> selectCategory(String category) async {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      notifyListeners();
      await loadEvents();
    }
  }

  // Toggle favorite status of an event
  Future<void> toggleFavorite(String eventId) async {
    try {
      await _eventRepository.toggleFavorite(eventId);
      
      // Update local state
      final index = _events.indexWhere((event) => event.id == eventId);
      if (index != -1) {
        _events[index] = _events[index].copyWith(
          isFavorite: !_events[index].isFavorite,
        );
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Get featured events
  List<Event> get featuredEvents {
    return _events.where((event) => event.isFeatured).toList();
  }

  // Get standard events
  List<Event> get standardEvents {
    return _events.where((event) => !event.isFeatured).toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
