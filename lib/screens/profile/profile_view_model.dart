import 'package:flutter/material.dart';
import '../../services/firestore_auth_provider.dart';
import '../../repositories/event_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final EventRepository _eventRepository;
  final AuthProvider _authProvider;
  
  ProfileViewModel(this._eventRepository, this._authProvider);
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  int _registeredEventsCount = 0;
  int get registeredEventsCount => _registeredEventsCount;
  
  String get userName => _authProvider.userFullName ?? 'Unknown User';
  String get userEmail => _authProvider.userEmail ?? 'No email';
  String get userIEEEId => _authProvider.userId ?? 'No ID';
  String get userRole => _authProvider.userRole?.displayName ?? 'Member';
  bool get isAdmin => _authProvider.userRole?.isAdmin ?? false;
  
  final String _spotifyPlaylistUrl = 'https://open.spotify.com/playlist/37i9dQZF1DXcBWIGoYBM5M';
  String get spotifyPlaylistUrl => _spotifyPlaylistUrl;
  
  
  Future<void> loadUserData() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Load registered events count
      final events = await _eventRepository.getEvents();
      _registeredEventsCount = events.where((event) => event.isRegistered).length;
      
      // In a real app, you would load user data from a user repository
      // For now, we'll use mock data
      
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _authProvider.signOut();
      
    } catch (e) {
      debugPrint('Error during logout: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void openSpotifyPlaylist() {
    // This would open the Spotify playlist URL
    // In a real app, you would use url_launcher package
  }
  
  void navigateToRegisteredEvents() {
    // This would navigate to a screen showing registered events
    // For now, this is just a placeholder
  }
}
