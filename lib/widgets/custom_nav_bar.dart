import 'package:flutter/material.dart';

enum NavBarItem { home, favorites, calendar, profile, admin }

class CustomNavBar extends StatelessWidget {
  final NavBarItem currentItem;
  final Function(NavBarItem) onItemSelected;
  final bool isAdmin;

  const CustomNavBar({
    super.key,
    required this.currentItem,
    required this.onItemSelected,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalPadding = isAdmin ? 12.0 : 24.0;

    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.12),
            blurRadius: 30,
            offset: const Offset(0, -8),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, -3),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          8,
          horizontalPadding,
          12,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: _buildNavItem(
                context,
                icon: Icons.home_outlined,
                label: 'Home',
                item: NavBarItem.home,
                isSelected: currentItem == NavBarItem.home,
              ),
            ),
            Expanded(
              child: _buildNavItem(
                context,
                icon: Icons.favorite_outline,
                label: 'Favorites',
                item: NavBarItem.favorites,
                isSelected: currentItem == NavBarItem.favorites,
              ),
            ),
            Expanded(
              child: _buildNavItem(
                context,
                icon: Icons.calendar_month_outlined,
                label: 'Calendar',
                item: NavBarItem.calendar,
                isSelected: currentItem == NavBarItem.calendar,
              ),
            ),
            if (isAdmin)
              Expanded(
                child: _buildNavItem(
                  context,
                  icon: Icons.admin_panel_settings_outlined,
                  label: 'Admin',
                  item: NavBarItem.admin,
                  isSelected: currentItem == NavBarItem.admin,
                ),
              ),
            Expanded(
              child: _buildNavItem(
                context,
                icon: Icons.person_outline,
                label: 'Profile',
                item: NavBarItem.profile,
                isSelected: currentItem == NavBarItem.profile,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required NavBarItem item,
    required bool isSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => onItemSelected(item),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF8B5CF6).withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF8B5CF6)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
                size: 22,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF8B5CF6)
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
