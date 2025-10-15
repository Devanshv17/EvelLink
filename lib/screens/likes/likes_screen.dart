import 'package:evelink/screens/chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';

class LikesScreen extends StatefulWidget {
  const LikesScreen({super.key});

  @override
  State<LikesScreen> createState() => _LikesScreenState();
}

class _LikesScreenState extends State<LikesScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenToLikes();
    });
  }

  void _listenToLikes() {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final likesProvider = Provider.of<LikesProvider>(context, listen: false);

    if (eventProvider.isInEvent && userProvider.currentUser != null) {
      likesProvider.listenToLikes(
        eventProvider.currentEvent!.eventId,
        userProvider.currentUser!.uid,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'People Who Like You',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Consumer4<EventProvider, UserProvider, LikesProvider, MatchProvider>(
        builder: (context, eventProvider, userProvider, likesProvider, matchProvider, child) {
          if (!eventProvider.isInEvent) {
            return _buildNoEventState();
          }

          if (likesProvider.isLoading) {
            return _buildLoadingState();
          }

          // Filter out users who are already matched
          final clearLikes = _filterOutMatches(likesProvider.clearLikes, matchProvider.matches, userProvider.currentUser!.uid);
          final hiddenLikes = _filterOutMatches(likesProvider.hiddenLikes, matchProvider.matches, userProvider.currentUser!.uid);

          if (clearLikes.isEmpty && hiddenLikes.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              // Tab Bar
              _buildTabBar(clearLikes.length, hiddenLikes.length),

              // Content
              Expanded(
                child: _selectedTab == 0
                    ? _buildLikesList(clearLikes, false)
                    : _buildLikesList(hiddenLikes, true),
              ),
            ],
          );
        },
      ),
    );
  }

  // Filter out users who are already matched
  List<UserModel> _filterOutMatches(List<UserModel> likes, List<MatchModel> matches, String currentUserId) {
    return likes.where((user) {
      return !matches.any((match) => match.users.contains(user.uid));
    }).toList();
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
            'Loading your admirers...',
            style: TextStyle(
              color: AppConstants.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(int clearCount, int hiddenCount) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabItem(
              'Likes',
              clearCount,
              0,
              Icons.favorite,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.shade200,
          ),
          Expanded(
            child: _buildTabItem(
              'Sparks',
              hiddenCount,
              1,
              Icons.auto_awesome,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int count, int tabIndex, IconData icon) {
    final isSelected = _selectedTab == tabIndex;

    return GestureDetector(
      onTap: () => setState(() => _selectedTab = tabIndex),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppConstants.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: tabIndex == 0
              ? const BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          )
              : const BorderRadius.only(
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppConstants.primaryColor : AppConstants.textLight,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppConstants.primaryColor : AppConstants.textPrimary,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? AppConstants.primaryColor : AppConstants.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLikesList(List<UserModel> users, bool isHidden) {
    if (users.isEmpty) {
      return _buildTabEmptyState(isHidden);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        return _buildLikeCard(users[index], isHidden);
      },
    );
  }

  Widget _buildLikeCard(UserModel user, bool isHidden) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Stack(
          children: [
            // Blur effect for hidden likes
            if (isHidden)
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.grey.withOpacity(0.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ),

            // User avatar
            GestureDetector(
              onTap: () => _showUserProfile(user, isHidden),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isHidden ? Colors.purple : AppConstants.primaryColor,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: user.photoUrls.isNotEmpty
                      ? Image.network(
                    user.photoUrls.first,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppConstants.primaryColor.withOpacity(0.1),
                        child: Center(
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.primaryColor,
                            ),
                          ),
                        ),
                      );
                    },
                  )
                      : Container(
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    child: Center(
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Spark badge for hidden likes
            if (isHidden)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.purple,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
          ],
        ),
        title: GestureDetector(
          onTap: () => _showUserProfile(user, isHidden),
          child: Row(
            children: [
              Text(
                isHidden ? 'Secret Admirer' : user.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isHidden ? Colors.purple : AppConstants.textPrimary,
                ),
              ),
            ],
          ),
        ),
        subtitle: GestureDetector(
          onTap: () => _showUserProfile(user, isHidden),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isHidden) ...[
                Text('${user.age} years • ${user.occupation ?? 'Not specified'}'),
                if (user.bio.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    user.bio,
                    style: TextStyle(
                      color: AppConstants.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ] else ...[
                Text(
                  'Someone sparked you! View profile to reveal who it is.',
                  style: TextStyle(
                    color: AppConstants.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
        trailing: isHidden
            ? IconButton(
          onPressed: () => _showUserProfile(user, true),
          icon: const Icon(Icons.auto_awesome, color: Colors.purple),
        )
            : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _swipeUser(user, false),
              icon: const Icon(Icons.close, color: Colors.grey),
            ),
            IconButton(
              onPressed: () => _swipeUser(user, true),
              icon: const Icon(Icons.favorite, color: AppConstants.primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabEmptyState(bool isHidden) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isHidden ? Icons.auto_awesome : Icons.favorite_border,
              size: 60,
              color: AppConstants.textLight,
            ),
            const SizedBox(height: 16),
            Text(
              isHidden ? 'No Sparks' : 'No Likes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isHidden
                  ? 'When someone sends you a spark, they\'ll appear here'
                  : 'When someone likes you, they\'ll appear here',
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

  Widget _buildNoEventState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_available,
                color: AppConstants.primaryColor,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Join an Event',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Join an event to see who likes you!',
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border,
                color: AppConstants.primaryColor,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Likes Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "When people like you, they'll appear here",
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

  void _showUserProfile(UserModel user, bool isHidden) {
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
          showActionButtons: !isHidden, // Only show buttons for non-hidden likes
          isHiddenLike: isHidden, // Pass whether this is a hidden like
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
    final likesProvider = Provider.of<LikesProvider>(context, listen: false);
    final matchProvider = Provider.of<MatchProvider>(context, listen: false);

    if (userProvider.currentUser == null) return;

    final isMatch = await eventProvider.swipeUser(
      eventProvider.currentEvent!.eventId,
      userProvider.currentUser!.uid,
      user.uid,
      isLike,
      isHidden: isHidden,
    );

    if (isMatch && mounted) {
      // Remove from likes list immediately
      likesProvider.removeLike(user.uid);

      _showMatchDialog(user);
    } else if (isLike && mounted) {
      Helpers.showSnackBar(
        context,
        isHidden ? 'Spark sent! ✨' : 'Like sent! 💖',
      );

      // If it's a hidden like being revealed, remove from hidden likes
      if (isHidden) {
        likesProvider.removeLike(user.uid);
      }
    } else if (mounted) {
      // Remove from likes on skip
      likesProvider.removeLike(user.uid);
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
              CircleAvatar(
                radius: 40,
                backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                backgroundImage: user.photoUrls.isNotEmpty
                    ? NetworkImage(user.photoUrls.first)
                    : null,
                child: user.photoUrls.isEmpty
                    ? Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 20,
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
              const SizedBox(height: 24),
              ElevatedButton(
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
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Start Chatting 💬'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}