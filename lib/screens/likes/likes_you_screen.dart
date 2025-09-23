
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/likes_provider.dart';
import '../../services/database_service.dart';
import '../../widgets/profile_card.dart';
import '../discovery/profile_detail_screen.dart';

class LikesYouScreen extends StatefulWidget {
const LikesYouScreen({super.key});

@override
State<LikesYouScreen> createState() => _LikesYouScreenState();
}

class _LikesYouScreenState extends State<LikesYouScreen> {
final DatabaseService _databaseService = DatabaseService();

@override
void initState() {
super.initState();
WidgetsBinding.instance.addPostFrameCallback((_) {
_loadUsersWhoLiked();
});
}

Future<void> _loadUsersWhoLiked() async {
final eventProvider = Provider.of<EventProvider>(context, listen: false);
final likesProvider = Provider.of<LikesProvider>(context, listen: false);

if (eventProvider.currentEvent != null) {
await likesProvider.loadUsersWhoLiked(
eventProvider.currentEvent!.id,
eventProvider.eventUsers
);
}
}

Future<void> _likeBack(String userId) async {
final eventProvider = Provider.of<EventProvider>(context, listen: false);
final likesProvider = Provider.of<LikesProvider>(context, listen: false);

if (eventProvider.currentEvent == null) return;

final success = await likesProvider.likeUser(
eventProvider.currentEvent!.id,
userId
);

if (success && mounted) {
// Create match
await _databaseService.createMatch(
eventProvider.currentEvent!.activeUsers.first, // Current user
userId
);

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('It\'s a match! 🎉'),
backgroundColor: Colors.green,
),
);

// Refresh the list
await _loadUsersWhoLiked();
}
}

@override
Widget build(BuildContext context) {
return Consumer2<EventProvider, LikesProvider>(
builder: (context, eventProvider, likesProvider, child) {
if (likesProvider.usersWhoLiked.isEmpty) {
return const Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(
Icons.favorite_border,
size: 80,
color: Colors.grey,
),
SizedBox(height: 16),
Text(
'No likes yet',
style: TextStyle(
fontSize: 18,
color: Colors.grey,
),
),
SizedBox(height: 8),
Text(
'People who like you will appear here',
style: TextStyle(
fontSize: 14,
color: Colors.grey,
),
),
],
),
);
}

return RefreshIndicator(
onRefresh: _loadUsersWhoLiked,
child: GridView.builder(
padding: const EdgeInsets.all(16),
gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
crossAxisCount: 2,
childAspectRatio: 0.7,
mainAxisSpacing: 16,
crossAxisSpacing: 16,
),
itemCount: likesProvider.usersWhoLiked.length,
itemBuilder: (context, index) {
final user = likesProvider.usersWhoLiked[index];
final isHidden = likesProvider.hiddenLikesMap[user.uid] ?? false;

return Stack(
children: [
ProfileCard(
user: user,
isBlurred: isHidden,
onTap: () {
Navigator.of(context).push(
MaterialPageRoute(
builder: (_) => ProfileDetailScreen(user: user),
),
);
},
),

// Hidden like indicator
if (isHidden)
const Positioned(
top: 8,
right: 8,
child: CircleAvatar(
radius: 16,
backgroundColor: Colors.purple,
child: Icon(
Icons.visibility_off,
color: Colors.white,
size: 16,
),
),
),

// Like back button
Positioned(
bottom: 8,
left: 8,
right: 8,
child: ElevatedButton.icon(
onPressed: () => _likeBack(user.uid),
icon: const Icon(Icons.favorite, size: 16),
label: const Text('Like Back'),
style: ElevatedButton.styleFrom(
backgroundColor: Colors.pink,
foregroundColor: Colors.white,
padding: const EdgeInsets.symmetric(vertical: 8),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(20),
),
),
),
),
],
);
},
),
);
},
);
}
}
