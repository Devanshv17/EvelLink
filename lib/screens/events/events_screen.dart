import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';
import '../../services/services.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';
import 'qr_scanner_screen.dart';
import 'event_participants_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        actions: [
          IconButton(
            onPressed: _showProfileMenu,
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, child) {
          if (eventProvider.isInEvent) {
            return EventParticipantsScreen(event: eventProvider.currentEvent!);
          } else {
            return _buildNoEventState();
          }
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
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.qr_code_scanner,
                size: 60,
                color: AppConstants.primaryColor,
              ),
            ),
            
            const SizedBox(height: 32),
            
            Text(
              'Join an Event',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimary,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Scan a QR code to join an event and start\nconnecting with people around you',
              style: TextStyle(
                fontSize: 16,
                color: AppConstants.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 48),
            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _scanQRCode,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text(
                  'Scan Event QR Code',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scanQRCode() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );
  }

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildProfileMenu(),
    );
  }

  Widget _buildProfileMenu() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.currentUser;
        if (user == null) return const SizedBox();

        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Profile Info
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Helpers.getRandomColor(user.uid),
                    // Use ClipOval for a circular image with PrivateNetworkImage
                    child: user.photoUrls.isNotEmpty
                        ? ClipOval(
                      child: PrivateNetworkImage(
                        imageUrl: user.photoUrls.first,
                        seedForFallbackColor: user.uid,
                        fit: BoxFit.cover,
                      ),
                    )
                        : Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${user.age} • ${user.profileType.toString().split('.').last}',
                          style: TextStyle(
                            color: AppConstants.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // ... rest of the menu options
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Profile'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to edit profile
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to settings
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context);
                  final shouldSignOut = await Helpers.showConfirmDialog(
                    context,
                    title: 'Sign Out',
                    content: 'Are you sure you want to sign out?',
                  );

                  if (shouldSignOut == true && mounted) {
                    final authService = Provider.of<AuthService>(context, listen: false);
                    await authService.signOut();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
