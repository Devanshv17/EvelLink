import 'package:flutter/material.dart';
import '../constants/design_constants.dart';
import 'package:evelink/models/models.dart';

class EnhancedEventCard extends StatelessWidget {
  final EventModel event;
  final bool isLarge;
  final VoidCallback onTap;

  const EnhancedEventCard({
    super.key,
    required this.event,
    required this.isLarge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DesignConstants.cardBorderRadius),
          color: DesignConstants.cardColor,
          boxShadow: [DesignConstants.cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image with fixed height
            Stack(
              children: [
                Container(
                  height: isLarge ? 160 : 100, // Reduced height to prevent overflow
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(DesignConstants.cardBorderRadius),
                      topRight: Radius.circular(DesignConstants.cardBorderRadius),
                    ),
                    image: DecorationImage(
                      image: (event.imageUrl != null && event.imageUrl!.isNotEmpty)
                          ? NetworkImage(event.imageUrl!)
                          : const AssetImage('assets/images/placeholder.png') as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Gradient overlay
                Container(
                  height: isLarge ? 160 : 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(DesignConstants.cardBorderRadius),
                      topRight: Radius.circular(DesignConstants.cardBorderRadius),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),

                // Mega Event Badge
                if (event.isMegaEvent)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: DesignConstants.primaryGradient,
                        borderRadius: BorderRadius.circular(DesignConstants.chipBorderRadius),
                      ),
                      child: const Text(
                        'MEGA EVENT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // Event date/time
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(event.startTime),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatTime(event.endTime),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Event Details with constrained heights
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event name with fixed height
                  SizedBox(
                    height: isLarge ? 26 : 40, // Fixed height for title
                    child: Text(
                      event.name,
                      style: TextStyle(
                        fontSize: isLarge ? 16 : 14,
                        fontWeight: FontWeight.w600,
                        color: DesignConstants.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Location with fixed height
                  SizedBox(
                    height: 20,
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: DesignConstants.textLight,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: TextStyle(
                              fontSize: 11,
                              color: DesignConstants.textLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Tags with fixed height and limited tags
                  SizedBox(
                    height: 24,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: event.tags.take(2).map((tag) => Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: DesignConstants.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(DesignConstants.chipBorderRadius),
                        ),
                        child: Text(
                          tag.length > 12 ? '${tag.substring(0, 12)}...' : tag,
                          style: const TextStyle(
                            fontSize: 10,
                            color: DesignConstants.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day} ${_getMonthName(dateTime.month)}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}