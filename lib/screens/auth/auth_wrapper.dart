import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/services.dart';
import '../../providers/providers.dart';
import '../profile/profile_type_selection_screen.dart';
import '../main/main_navigation_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {

  Future<Widget> _checkUserStatus(String uid) async {
    // This function centralizes all checks after a user is logged in.
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    // 1. Load the user profile first.
    await userProvider.loadUser(uid);

    // 2. Check if a profile exists.
    if (userProvider.hasProfile) {
      // 3. If profile exists, try rejoining a previous event.
      await eventProvider.tryRejoinPreviousEvent(uid);
      return const MainNavigationScreen();
    } else {
      // 4. If no profile, go to profile creation.
      return const ProfileTypeSelectionScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (authSnapshot.hasData) {
          // User is signed in.
          return FutureBuilder<Widget>(
            // Use our new helper function to determine the correct screen.
            future: _checkUserStatus(authSnapshot.data!.uid),
            builder: (context, screenSnapshot) {
              if (screenSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              // Once the future completes, it returns the correct screen widget.
              return screenSnapshot.data ?? const LoginScreen();
            },
          );
        } else {
          // User is not signed in.
          return const LoginScreen();
        }
      },
    );
  }
}