import 'package:evelink/models/event_model.dart';
import 'package:evelink/utils/app_constants.dart';
import 'package:evelink/utils/helpers.dart';
import 'package:evelink/widgets/private_network_image.dart';
import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final bool isLarge;
  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.event,
    this.isLarge = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Stack(
          children: [
            // Background Image or Color
            Positioned.fill(
              child: event.imageUrl != null
                  ? PrivateNetworkImage(
                imageUrl: event.imageUrl!,
                fit: BoxFit.cover,
              )
                  : Container(color: Helpers.getRandomColor(event.eventId)),
            ),
            // Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ),
            // Event Details
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isLarge ? 20 : 16,
                      fontWeight: FontWeight.bold,
                      shadows: const [Shadow(blurRadius: 4)],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Helpers.formatDate(event.startTime),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: isLarge ? 14 : 12,
                      shadows: const [Shadow(blurRadius: 2)],
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
}

