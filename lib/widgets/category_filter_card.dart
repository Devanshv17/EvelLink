import 'package:flutter/material.dart';
import '../constants/design_constants.dart';

class CategoryFilterCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String imageUrl;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryFilterCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.imageUrl,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DesignConstants.cardBorderRadius),
          color: DesignConstants.cardColor,
          boxShadow: [DesignConstants.cardShadow],
          border: isSelected ? Border.all(
            color: DesignConstants.primaryColor,
            width: 2,
          ) : null,
        ),
        child: Column(
          children: [
            // Image container
            Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(DesignConstants.cardBorderRadius),
                  topRight: Radius.circular(DesignConstants.cardBorderRadius),
                ),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(DesignConstants.cardBorderRadius),
                    topRight: Radius.circular(DesignConstants.cardBorderRadius),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: DesignConstants.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: DesignConstants.textLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}