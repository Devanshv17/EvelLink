import 'package:flutter/material.dart';
import '../constants/design_constants.dart';

class CircularCategoryFilter extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const CircularCategoryFilter({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            // Circular icon container
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isSelected ? DesignConstants.primaryGradient : null,
                color: isSelected ? null : Colors.grey[100],
                border: isSelected ? null : Border.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
                boxShadow: isSelected ? [DesignConstants.cardShadow] : null,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : DesignConstants.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            // Category name
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? DesignConstants.primaryColor : DesignConstants.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}