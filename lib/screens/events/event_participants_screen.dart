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
    // Data listening is now handled by the EventProvider when an event is joined.
    // We can trigger a refresh here if needed, but it's not strictly necessary
    // if joinEvent is the only way to get to this screen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.currentUser != null) {
        Provider.of<EventProvider>(context, listen: false).listenToEventData(userProvider.currentUser!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.name),
        actions: [
          IconButton(
            onPressed: _leaveEvent,
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Leave Event',
          ),
        ],
      ),
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, child) {
          if (eventProvider.isLoading && eventProvider.eventParticipants.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final participants = eventProvider.getFilteredParticipants();

          if (participants.isEmpty) {
            return _buildEmptyState();
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
              childAspectRatio: 0.75,
            ),
            itemCount: participants.length,
            itemBuilder: (context, index) {
              final user = participants[index];
              return UserCard(
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
            Icon(Icons.people_outline, size: 80, color: AppConstants.textSecondary),
            const SizedBox(height: 24),
            Text('No one new to see', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppConstants.textPrimary)),
            const SizedBox(height: 8),
            Text("You've seen everyone for now. Check back later!", style: TextStyle(color: AppConstants.textSecondary), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                if (userProvider.currentUser != null) {
                  Provider.of<EventProvider>(context, listen: false).listenToEventData(userProvider.currentUser!.uid);
                }
              },
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
        showLikeButtons: true,
        onLike: (isHidden) {
          Navigator.pop(context);
          _swipeUser(user, true, isHidden: isHidden);
        },
        onPass: () {
          Navigator.pop(context);
          _swipeUser(user, false);
        },
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

    if (isMatch && mounted) {
      Helpers.showSnackBar(context, "It's a Match with ${user.name}!", isError: false);
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
      await eventProvider.leaveEvent();
    }
  }
}
