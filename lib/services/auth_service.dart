import 'package:evelink/providers/all_events_provider.dart';
import 'package:evelink/providers/providers.dart';
import 'package:evelink/services/database_service.dart';
import 'package:evelink/services/storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  bool get isSignedIn => _auth.currentUser != null;

  Future<User?> signInWithGoogle() async {
    try {
      await _googleSignIn.initialize(
        clientId: "1054354074866-jnl300isk5vnbrk1imq85bjqigtvj9jd.apps.googleusercontent.com",
      );
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      if (idToken == null) return null;

      final clientAuth = await googleUser.authorizationClient.authorizationForScopes(['email']);
      final String? accessToken = clientAuth?.accessToken;

      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: accessToken,
      );

      final userCred = await _auth.signInWithCredential(credential);
      return userCred.user;
    } catch (e) {
      print("Error signing in with Google: $e");
      return null;
    }
  }

  Future<void> signOut(BuildContext context) async {
    // Clear all user-specific data from providers
    Provider.of<UserProvider>(context, listen: false).clearUser();
    Provider.of<EventProvider>(context, listen: false).leaveEvent();
    Provider.of<LikesProvider>(context, listen: false).resetLikes();
    Provider.of<MatchProvider>(context, listen: false).clearMatches();
    Provider.of<AllEventsProvider>(context, listen: false).stopListening();

    // Clear caches
    DatabaseService().clearUserCache();
    await B2CacheManager().emptyCache();

    // Sign out from services
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}

