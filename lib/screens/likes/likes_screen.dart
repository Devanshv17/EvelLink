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

  bool _hasLoaded = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Use didChangeDependencies instead of initState to safely access providers
    // and check the flag to ensure data is loaded only once.
    if (!_hasLoaded) {
      _loadLikes();
      setState(() {
        _hasLoaded = true;
      });
    }
  }

  void _loadLikes() {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final likesProvider = Provider.of<LikesProvider>(context, listen: false);

    if (eventProvider.isInEvent && userProvider.currentUser != null) {
      likesProvider.loadLikes(
        eventProvider.currentEvent!.eventId,
        userProvider.currentUser!.uid,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Likes'),
      ),
      body: Consumer3<EventProvider, UserProvider, LikesProvider>(
        builder: (context, eventProvider, userProvider, likesProvider, child) {
          if (!eventProvider.isInEvent) {
            return _buildNoEventState();
          }

          if (likesProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final clearLikes = likesProvider.clearLikes;
          final hiddenLikes = likesProvider.hiddenLikes;

          if (clearLikes.isEmpty && hiddenLikes.isEmpty) {
            return _buildEmptyState();
          }

          return SingleChildScrollView(
            padding: AppConstants.defaultPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Clear Likes', clearLikes.length, Icons.favorite),
                      Container(width: 1, height: 40, color: Colors.grey.shade300),
                      _buildStatItem('Hidden Likes', hiddenLikes.length, Icons.favorite_border),
                    ],
                  ),
                ),

                if (clearLikes.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildSection('Clear Likes', clearLikes, false),
                ],

                if (hiddenLikes.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildSection('Hidden Likes', hiddenLikes, true),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoEventState() {
    return Center(
      child: Padding(
        padding: AppConstants.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: AppConstants.textSecondary,
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'No Event Joined',
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
            ),
          ],
        ),
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
              Icons.favorite_border,
              size: 80,
              color: AppConstants.textSecondary,
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
              'When people like you, they\'ll appear here',
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

  Widget _buildStatItem(String label, int count, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppConstants.primaryColor,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppConstants.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<UserModel> users, bool isHidden) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 12),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: AppConstants.userGridCrossAxisCount,
            crossAxisSpacing: AppConstants.userGridSpacing,
            mainAxisSpacing: AppConstants.userGridSpacing,
            childAspectRatio: AppConstants.userGridAspectRatio,
          ),
          itemCount: users.length,
          itemBuilder: (context, index) {
            return UserCard(
              user: users[index],
              isBlurred: isHidden,
              onTap: isHidden ? null : () => _showUserDetail(users[index]),
            );
          },
        ),
      ],
    );
  }

  void _showUserDetail(UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UserDetailBottomSheet(
        user: user,
        showLikeButtons: false,
      ),
    );
  }
}
