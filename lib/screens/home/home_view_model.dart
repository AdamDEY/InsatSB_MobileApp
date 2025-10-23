import 'package:flutter/foundation.dart';
import '../../models/event.dart';
import '../../repositories/event_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final EventRepository _eventRepository;
  
  HomeViewModel(this._eventRepository);

  List<Event> _events = [];
  final List<String> _categories = ['All', 'CS', 'RAS', 'PES/PELS', 'IAS', 'SIGHT', 'WIE'];
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
      print('HomeViewModel: Loading events for category: $_selectedCategory');
      
      // Get all events first
      final allEvents = await _eventRepository.getEvents();
      print('HomeViewModel: Retrieved ${allEvents.length} total events from repository');
      
      if (_selectedCategory == 'All') {
        _events = allEvents;
        print('HomeViewModel: Using all events (${_events.length})');
      } else {
        // Filter locally (this works perfectly!)
        _events = allEvents.where((event) => event.chapter.displayName == _selectedCategory).toList();
        print('HomeViewModel: Filtered to ${_events.length} events for chapter: $_selectedCategory');
      }
      
      print('HomeViewModel: Final event count: ${_events.length}');
      for (final event in _events) {
        print('HomeViewModel: Event - ${event.title} (${event.chapter.displayName})');
      }
    } catch (e) {
      print('HomeViewModel: Error loading events: $e');
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Select a category and reload events
  Future<void> selectCategory(String category) async {
    print('HomeViewModel: selectCategory called with: $category');
    print('HomeViewModel: Current selected category: $_selectedCategory');
    
    if (_selectedCategory != category) {
      print('HomeViewModel: Category changed from $_selectedCategory to $category');
      _selectedCategory = category;
      print('HomeViewModel: Notifying listeners...');
      notifyListeners();
      print('HomeViewModel: Loading events...');
      await loadEvents();
      print('HomeViewModel: Events loaded. Count: ${_events.length}');
    } else {
      print('HomeViewModel: Category unchanged, skipping reload');
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
