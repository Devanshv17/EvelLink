import 'package:evelink/screens/chat/chat_screen.dart';
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
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.currentUser != null) {
        Provider.of<EventProvider>(context, listen: false).listenToEventData(userProvider.currentUser!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Discover People',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimary,
              ),
            ),
            Text(
              widget.event.name,
              style: TextStyle(
                fontSize: 12,
                color: AppConstants.textSecondary,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: _leaveEvent,
            icon: Icon(Icons.exit_to_app, color: AppConstants.primaryColor),
            tooltip: 'Leave Event',
          ),
        ],
      ),
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, child) {
          if (eventProvider.isLoading && eventProvider.eventParticipants.isEmpty) {
            return _buildLoadingState();
          }

          final participants = eventProvider.getFilteredParticipants();

          if (participants.isEmpty) {
            return _buildEmptyState(eventProvider.eventParticipants.isNotEmpty);
          }

          return Column(
            children: [
              // Stats bar
              _buildStatsBar(participants.length),

              // Grid of user cards
              Expanded(
                child: _buildParticipantsGrid(participants),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading participants...',
            style: TextStyle(
              color: AppConstants.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar(int totalParticipants) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.people, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                '$totalParticipants people to discover',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textPrimary,
                ),
              ),
            ],
          ),
          Text(
            'Swipe to connect',
            style: TextStyle(
              color: AppConstants.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsGrid(List<UserModel> participants) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: participants.length,
      itemBuilder: (context, index) {
        final user = participants[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(UserModel user) {
    return GestureDetector(
      onTap: () => _showUserDetail(user),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // User Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  image: user.photoUrls.isNotEmpty ? DecorationImage(
                    image: NetworkImage(user.photoUrls.first),
                    fit: BoxFit.cover,
                  ) : null,
                  color: user.photoUrls.isEmpty ? AppConstants.primaryColor.withOpacity(0.1) : null,
                ),
                child: Stack(
                  children: [
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.4),
                          ],
                        ),
                      ),
                    ),

                    // User info overlay
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  user.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${user.age}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // No photo placeholder
                    if (user.photoUrls.isEmpty)
                      Center(
                        child: Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                      ),

                    // Action buttons overlay
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Row(
                        children: [
                          // Spark button (small)
                          _buildSmallActionButton(
                            Icons.auto_awesome,
                            Colors.purple,
                                () => _swipeUser(user, true, isHidden: true),
                          ),
                          const SizedBox(width: 4),
                          // Like button (small)
                          _buildSmallActionButton(
                            Icons.favorite,
                            AppConstants.primaryColor,
                                () => _swipeUser(user, true),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // User info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${user.age} years',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppConstants.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (user.bio.isNotEmpty)
                      Expanded(
                        child: Text(
                          user.bio,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppConstants.textLight,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const SizedBox(height: 4),
                    // Quick info chips
                    Row(
                      children: [
                        if (user.occupation != null && user.occupation!.isNotEmpty)
                          Expanded(
                            child: _buildInfoChip(user.occupation!),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallActionButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          color: AppConstants.primaryColor,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildEmptyState(bool hasParticipants) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasParticipants ? Icons.search_off : Icons.people_outline,
              size: 80,
              color: AppConstants.textLight,
            ),
            const SizedBox(height: 24),
            Text(
              hasParticipants ? 'No matches found' : 'Everyone discovered!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasParticipants
                  ? 'Try adjusting your search terms'
                  : "You've seen all participants for now. Check back later!",
              style: TextStyle(
                color: AppConstants.textSecondary,
              ),
              textAlign: TextAlign.center,
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
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: UserDetailBottomSheet(
          user: user,
          showActionButtons: true,
          onSkip: () {
            Navigator.pop(context);
            _swipeUser(user, false);
          },
          onSpark: () {
            Navigator.pop(context);
            _swipeUser(user, true, isHidden: true);
          },
          onLike: () {
            Navigator.pop(context);
            _swipeUser(user, true);
          },
        ),
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
      // Remove the matched user from participants list
      eventProvider.removeMatchedUser(user.uid);
      _showMatchDialog(user);
    } else if (isLike && mounted) {
      // Show feedback
      Helpers.showSnackBar(
        context,
        isHidden ? 'Spark sent! ✨' : 'Like sent! 💖',
      );
    }
  }

  void _showMatchDialog(UserModel user) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Celebration animation
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppConstants.primaryColor, Colors.purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.celebration,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),

              // Match text
              Text(
                "It's a Match!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'You and ${user.name} liked each other',
                style: TextStyle(
                  color: AppConstants.textSecondary,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // User info
              CircleAvatar(
                radius: 50,
                backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                backgroundImage: user.photoUrls.isNotEmpty
                    ? NetworkImage(user.photoUrls.first)
                    : null,
                child: user.photoUrls.isEmpty
                    ? Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
                    : null,
              ),
              const SizedBox(height: 16),

              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),

              Text(
                '${user.age} years • ${user.occupation ?? 'Not specified'}',
                style: TextStyle(
                  color: AppConstants.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Keep Browsing'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Navigate to chat screen
                        final matchProvider = Provider.of<MatchProvider>(context, listen: false);
                        final match = matchProvider.getMatchWithUser(user.uid);
                        if (match != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                match: match,
                                otherUser: user,
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Say Hi 👋'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _leaveEvent() async {
    final shouldLeave = await Helpers.showConfirmDialog(
      context,
      title: 'Leave Event',
      content: 'Are you sure you want to leave this event? You\'ll lose all your matches and conversations.',
      confirmText: 'Leave Event',
      cancelText: 'Stay',
    );

    if (shouldLeave == true && mounted) {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      await eventProvider.leaveEvent();
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}