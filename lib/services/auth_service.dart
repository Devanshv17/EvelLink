import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'database_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _databaseService = DatabaseService();

  // singleton instance
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  bool get isSignedIn => _auth.currentUser != null;

  Future<User?> signInWithGoogle() async {
    try {
      // IMPORTANT: must pass your Web Client ID here
      await _googleSignIn.initialize(
        clientId: "1054354074866-jnl300isk5vnbrk1imq85bjqigtvj9jd.apps.googleusercontent.com",
      );

      // ask user to sign in
      final GoogleSignInAccount? googleUser =
      await _googleSignIn.authenticate();
      if (googleUser == null) return null;

      // get ID token
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final String? idToken = googleAuth.idToken;
      if (idToken == null) {
        print("No idToken returned");
        return null;
      }

      // request OAuth access token for scopes (e.g. email)
      final clientAuth = await googleUser.authorizationClient
          .authorizationForScopes(['email']);

      final String? accessToken = clientAuth?.accessToken;

      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: accessToken,
      );

      final userCred = await _auth.signInWithCredential(credential);
      return userCred.user;
    } catch (e, st) {
      print("Error signing in with Google: $e\n$st");
      return null;
    }
  }

  Future<bool> hasProfile() async {
    if (!isSignedIn) return false;
    return await _databaseService.userExists(currentUser!.uid);
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
