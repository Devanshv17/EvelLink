import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static const List<String> scopes = <String>[
    'email',
    'https://www.googleapis.com/auth/userinfo.profile',
  ];

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Initialize GoogleSignIn (call this once at app startup)
  Future<void> initialize({
    String? clientId,
    String? serverClientId,
  }) async {
    try {
      await _googleSignIn.initialize(

        clientId: clientId ?? '',
        serverClientId: serverClientId ?? '',
      );
    } catch (e) {
      print('GoogleSignIn initialization error: $e');
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication authentication = googleUser.authentication;
      final String? idToken = authentication.idToken;

      final GoogleSignInClientAuthorization? clientAuth =
      await googleUser.authorizationClient.authorizationForScopes(scopes);
      final String? accessToken = clientAuth?.accessToken;

      if (idToken == null || accessToken == null) {
        print('Missing idToken or accessToken');
        return null;
      }

      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: accessToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      return userCredential.user;
    } on Exception catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  bool get isSignedIn => _auth.currentUser != null;
}