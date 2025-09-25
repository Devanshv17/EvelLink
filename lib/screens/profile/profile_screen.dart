import 'package:evelink/providers/user_provider.dart';
import 'package:evelink/screens/profile/profile_edit_screen.dart';
import 'package:evelink/services/auth_service.dart';
import 'package:evelink/utils/helpers.dart';
import 'package:evelink/widgets/private_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('No user data found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Helpers.getRandomColor(user.uid),
                child: user.photoUrls.isNotEmpty
                    ? ClipOval(
                  child: SizedBox.fromSize(
                    size: const Size.fromRadius(50),
                    child: PrivateNetworkImage(
                      imageUrl: user.photoUrls.first,
                      fit: BoxFit.cover,
                      seedForFallbackColor: user.uid,
                    ),
                  ),
                )
                    : Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontSize: 50),
                ),
              ),
              const SizedBox(height: 16),
              Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  user.bio,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileEditScreen()));
                    },
                    child: const Text('Edit Profile'),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Navigate to Settings screen later
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Navigate to Privacy Policy screen later
                },
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Terms & Conditions'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Navigate to Terms & Conditions screen later
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  final shouldSignOut = await Helpers.showConfirmDialog(
                    context,
                    title: 'Sign Out',
                    content: 'Are you sure you want to sign out?',
                  );
                  if (shouldSignOut == true && context.mounted) {
                    final authService = Provider.of<AuthService>(context, listen: false);
                    await authService.signOut();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

