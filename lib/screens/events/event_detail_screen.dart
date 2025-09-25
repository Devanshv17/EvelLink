import 'package:evelink/models/event_model.dart';
import 'package:evelink/widgets/private_network_image.dart';
import 'package:flutter/material.dart';
import 'package:evelink/utils/app_constants.dart';
import 'package:evelink/utils/helpers.dart';

class EventDetailScreen extends StatelessWidget {
  final EventModel event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(event.name, style: const TextStyle(shadows: [Shadow(blurRadius: 8)])),
              background: event.imageUrl != null
                  ? PrivateNetworkImage(
                imageUrl: event.imageUrl!,
                fit: BoxFit.cover,
              )
                  : Container(color: Helpers.getRandomColor(event.eventId)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(context, Icons.calendar_today, Helpers.formatDate(event.startTime)),
                  const SizedBox(height: 12),
                  _buildInfoRow(context, Icons.access_time, '${Helpers.formatTime(event.startTime)} - ${Helpers.formatTime(event.endTime)}'),
                  const SizedBox(height: 12),
                  _buildInfoRow(context, Icons.location_on, event.location),
                  const SizedBox(height: 24),
                  Text(
                    'About this event',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 80), // Space for the button at the bottom
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            // TODO: Implement join event logic
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
          ),
          child: const Text('Join Event', style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: Theme.of(context).textTheme.titleMedium)),
      ],
    );
  }
}
