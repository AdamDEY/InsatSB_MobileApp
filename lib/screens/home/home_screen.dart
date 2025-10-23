import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/event_card.dart';
import 'home_view_model.dart';
import '../event_details/event_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      body: Column(
        children: [
          _buildHeader(),
          _buildCategoryFilters(),
          Expanded(
            child: _buildEventsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Home',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'See Upcoming Events',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // Handle search
            },
            icon: Icon(
              Icons.search,
              size: 24,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return Container(
          height: 40,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: viewModel.categories.length,
            itemBuilder: (context, index) {
              final category = viewModel.categories[index];
              final isSelected = category == viewModel.selectedCategory;
              
              return Container(
                margin: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => viewModel.selectCategory(category),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? _getChapterColor(category) : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected 
                          ? _getChapterColor(category)
                          : (isDark ? Colors.grey[600]! : Colors.grey[300]!),
                      ),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected 
                          ? Colors.white 
                          : (isDark ? Colors.white : Colors.black),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEventsList() {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (viewModel.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error: ${viewModel.error}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => viewModel.loadEvents(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (viewModel.events.isEmpty) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No events found',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Selected: ${viewModel.selectedCategory}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[500] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => viewModel.loadEvents(),
                  child: const Text('Reload Events'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: viewModel.events.length,
          itemBuilder: (context, index) {
            final event = viewModel.events[index];
            return EventCard(
              event: event,
              onFavoritePressed: () => viewModel.toggleFavorite(event.id),
              onCardPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EventDetailsScreen(eventId: event.id),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Color _getChapterColor(String chapter) {
    switch (chapter) {
      case 'CS':
        return const Color(0xFF8B5CF6); // Purple
      case 'RAS':
        return const Color(0xFF3B82F6); // Blue
      case 'PES/PELS':
        return const Color(0xFF10B981); // Green
      case 'IAS':
        return const Color(0xFFF59E0B); // Orange
      case 'SIGHT':
        return const Color(0xFFEF4444); // Red
      case 'WIE':
        return const Color(0xFFEC4899); // Pink
      case 'All':
        return const Color(0xFF8B5CF6); // Default purple for "All"
      default:
        return const Color(0xFF8B5CF6); // Default purple
    }
  }
}
