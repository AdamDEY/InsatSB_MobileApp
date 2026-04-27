import 'package:flutter/foundation.dart';
import '../../models/event.dart';
import '../../repositories/event_repository.dart';

class CalendarViewModel extends ChangeNotifier {
  final EventRepository _eventRepository;

  CalendarViewModel(this._eventRepository);

  List<Event> _events = [];
  bool _isLoading = false;
  String? _error;
  DateTime _selectedDate = DateTime.now();

  // Getters
  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get selectedDate => _selectedDate;

  // Initialize the calendar screen
  Future<void> initialize() async {
    await loadEvents();
  }

  // Load all events
  Future<void> loadEvents() async {
    _setLoading(true);
    _error = null;

    try {
      _events = await _eventRepository.getEvents();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Get events for a specific date
  List<Event> getEventsForDate(DateTime date) {
    return _events.where((event) {
      return event.date.year == date.year &&
          event.date.month == date.month &&
          event.date.day == date.day;
    }).toList();
  }

  // Get events for the selected date
  List<Event> getEventsForSelectedDate() {
    return getEventsForDate(_selectedDate);
  }

  // Set selected date
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // Get all dates that have events
  List<DateTime> getDatesWithEvents() {
    return _events.map((event) => event.date).toList();
  }

  // Toggle favorite status of an event
  Future<void> toggleFavorite(String eventId) async {
    try {
      final isFavorite = await _eventRepository.toggleFavorite(eventId);

      // Update local state
      final index = _events.indexWhere((event) => event.id == eventId);
      if (index != -1) {
        _events[index] = _events[index].copyWith(isFavorite: isFavorite);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
