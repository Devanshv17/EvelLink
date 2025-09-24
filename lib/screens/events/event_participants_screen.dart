import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';

class EventParticipantsScreen extends StatefulWidget {
  final EventModel event;

  const EventParticipantsScreen({
    super.key,
    required this.event,
  });

  @override
  State<EventParticipantsScreen> createState() => _EventParticipantsScreenState();
}

class _EventParticipantsScreenState extends State<EventParticipantsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadParticipants();
    });
  }

  void _loadParticipants() {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.currentUser != null) {
      eventProvider.loadEventParticipants(userProvider.currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.event.name,
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              widget.event.location,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _leaveEvent,
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Leave Event',
          ),
        ],
      ),
      body: Consumer2<EventProvider, UserProvider>(
        builder: (context, eventProvider, userProvider, child) {
          if (eventProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final participants = eventProvider.getFilteredParticipants();

          if (participants.isEmpty) {
            return _buildEmptyState();
          }

          // --- NEW GRID VIEW LAYOUT ---
          return GridView.builder(
            padding: const EdgeInsets.all(12.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 columns
              crossAxisSpacing: 12.0, // Spacing between columns
              mainAxisSpacing: 12.0, // Spacing between rows
              childAspectRatio: 0.85, // Adjust for card shape (width / height)
            ),
            itemCount: participants.length,
            itemBuilder: (context, index) {
              final user = participants[index];
              return ParticipantCard( // Use our new card
                user: user,
                onTap: () => _showUserDetail(user),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: AppConstants.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: AppConstants.textSecondary,
            ),

            const SizedBox(height: 24),

            Text(
              'No one else here yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'You\'re early! More people will join soon.',
              style: TextStyle(
                color: AppConstants.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            ElevatedButton.icon(
              onPressed: _loadParticipants,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  void _showUserDetail(UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UserDetailBottomSheet(
        user: user,
        onLike: (isHidden) => _swipeUser(user, true, isHidden: isHidden),
        onPass: () => _swipeUser(user, false),
      ),
    );
  }

  Future<void> _swipeUser(UserModel user, bool isLike, {bool isHidden = false}) async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.currentUser == null) return;

    final isMatch = await eventProvider.swipeUser(
      widget.event.eventId,
      userProvider.currentUser!.uid,
      user.uid,
      isLike,
      isHidden: isHidden,
    );

    // You might want to show a "It's a Match!" dialog here if isMatch is true.

    if (mounted) {
      final action = isLike
          ? (isHidden ? 'sent a hidden like' : 'liked')
          : 'passed on';

      Helpers.showSnackBar(
        context,
        'You $action ${user.name}',
      );
    }
  }

  void _leaveEvent() async {
    final shouldLeave = await Helpers.showConfirmDialog(
      context,
      title: 'Leave Event',
      content: 'Are you sure you want to leave this event?',
      confirmText: 'Leave',
      cancelText: 'Stay',
    );

    if (shouldLeave == true && mounted) {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      eventProvider.leaveEvent();

      Helpers.showSnackBar(context, 'Left the event');
    }
  }
}