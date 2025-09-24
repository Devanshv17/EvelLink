import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/services.dart';
import '../../providers/providers.dart';
import '../profile/profile_type_selection_screen.dart';
import '../main/main_navigation_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          // User is signed in, check if they have a profile
          return FutureBuilder<bool>(
            future: authService.hasProfile(),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (profileSnapshot.data == true) {
                // User has profile, load it and go to main app
                return Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    if (!userProvider.hasProfile) {
                      // Load user profile
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        userProvider.loadUser(authService.currentUser!.uid);
                      });
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return const MainNavigationScreen();
                  },
                );
              } else {
                // User needs to create profile
                return const ProfileTypeSelectionScreen();
              }
            },
          );
        } else {
          // User is not signed in
          return const LoginScreen();
        }
      },
    );
  }
}
