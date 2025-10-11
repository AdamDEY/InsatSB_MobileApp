import 'package:flutter/material.dart';
import '../models/event.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onFavoritePressed;
  final VoidCallback? onCardPressed;

  const EventCard({
    super.key,
    required this.event,
    this.onFavoritePressed,
    this.onCardPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onCardPressed,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isDark 
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: event.isFeatured ? _buildFeaturedCard(context) : _buildStandardCard(context),
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Category tag
          Positioned(
            top: 16,
            left: 16,
            child: _buildCategoryTag(),
          ),
          // Favorite button
          Positioned(
            top: 16,
            right: 16,
            child: _buildFavoriteButton(context),
          ),
          // Event details
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: _buildEventDetails(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandardCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Left side - Category tag
            _buildCategoryTag(),
            const SizedBox(width: 12),
            // Center - Event details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatDate(event.date)} • ${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${event.attendees} Attendees • Level: ${event.level}',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Right side - Favorite button
            _buildFavoriteButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6), // Purple color
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        event.category,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onFavoritePressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          event.isFavorite ? Icons.favorite : Icons.favorite_border,
          color: event.isFavorite ? Colors.red : (isDark ? Colors.grey[400] : Colors.grey[600]),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildEventDetails(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          event.title,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          '${_formatDate(event.date)} • ${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}',
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${event.attendees} Attendees',
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Level : ${event.level}',
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}

