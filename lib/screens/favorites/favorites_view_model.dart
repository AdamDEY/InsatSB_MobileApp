import 'package:flutter/foundation.dart';
import '../../models/event.dart';
import '../../repositories/event_repository.dart';

class FavoritesViewModel extends ChangeNotifier {
  final EventRepository _eventRepository;

  FavoritesViewModel(this._eventRepository);

  List<Event> _favoriteEvents = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Event> get favoriteEvents => _favoriteEvents;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasFavorites => _favoriteEvents.isNotEmpty;

  // Initialize the favorites screen
  Future<void> initialize() async {
    await loadFavoriteEvents();
  }

  // Load favorite events
  Future<void> loadFavoriteEvents() async {
    _setLoading(true);
    _error = null;

    try {
      _favoriteEvents = await _eventRepository.getFavoriteEvents();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Remove event from favorites
  Future<void> removeFromFavorites(String eventId) async {
    try {
      await _eventRepository.toggleFavorite(eventId);

      // Update local state
      _favoriteEvents.removeWhere((event) => event.id == eventId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Check if event is favorite
  bool isFavorite(String eventId) {
    return _favoriteEvents.any((event) => event.id == eventId);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
