import 'package:flutter/material.dart';
import '../../repositories/event_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final EventRepository _eventRepository;
  
  ProfileViewModel(this._eventRepository);
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  int _registeredEventsCount = 0;
  int get registeredEventsCount => _registeredEventsCount;
  
  final String _userName = 'Flen Ben Foulen';
  String get userName => _userName;
  
  final String _userEmail = 'flen.benfoulen@ieee.org';
  String get userEmail => _userEmail;
  
  final String _userIEEEId = '97235526';
  String get userIEEEId => _userIEEEId;
  
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
      // In a real app, you would:
      // 1. Clear user session
      // 2. Clear stored tokens
      // 3. Navigate to login screen
      // For now, we'll just simulate logout
      await Future.delayed(const Duration(seconds: 1));
      
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
