import 'package:firebase_auth/firebase_auth.dart';
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
    final authService = Provider.of<AuthService>(context, listen: false);

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (authSnapshot.hasData) {
          return ProfileWrapper(uid: authSnapshot.data!.uid);
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

class ProfileWrapper extends StatefulWidget {
  final String uid;
  const ProfileWrapper({super.key, required this.uid});

  @override
  State<ProfileWrapper> createState() => _ProfileWrapperState();
}

class _ProfileWrapperState extends State<ProfileWrapper> {
  @override
  void initState() {
    super.initState();
    // This is the crucial fix.
    // It delays the call to listenToUser until after the first build is complete.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).listenToUser(widget.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.isLoading && userProvider.currentUser == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (userProvider.hasProfile) {
          return MainAppLoader(uid: widget.uid);
        } else {
          return const ProfileTypeSelectionScreen();
        }
      },
    );
  }
}

class MainAppLoader extends StatefulWidget {
  final String uid;
  const MainAppLoader({super.key, required this.uid});

  @override
  State<MainAppLoader> createState() => _MainAppLoaderState();
}

class _MainAppLoaderState extends State<MainAppLoader> {
  late Future<void> _rejoinFuture;

  @override
  void initState() {
    super.initState();
    _rejoinFuture = Provider.of<EventProvider>(context, listen: false).tryRejoinPreviousEvent(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _rejoinFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return const MainNavigationScreen();
      },
    );
  }
}