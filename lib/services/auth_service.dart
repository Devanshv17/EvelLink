import 'package:evelink/providers/all_events_provider.dart';
import 'package:evelink/providers/providers.dart';
import 'package:evelink/services/database_service.dart';
import 'package:evelink/services/storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  bool get isSignedIn => _auth.currentUser != null;

  String? _verificationId;
  int? _resendToken;

  // Send OTP to phone number
  Future<String?> sendOTP({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onVerificationFailed,
    required Function(UserCredential) onVerificationCompleted,
    required Function(String) onCodeAutoRetrievalTimeout,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed
          try {
            UserCredential userCredential = await _auth.signInWithCredential(credential);
            onVerificationCompleted(userCredential);
          } catch (e) {
            onVerificationFailed('Auto-verification failed: \$e');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          String errorMessage;
          switch (e.code) {
            case 'invalid-phone-number':
              errorMessage = 'The phone number entered is invalid.';
              break;
            case 'too-many-requests':
              errorMessage = 'Too many requests. Please try again later.';
              break;
            case 'operation-not-allowed':
              errorMessage = 'Phone authentication is not enabled for this project.';
              break;
            default:
              errorMessage = 'Verification failed: \${e.message}';
          }
          onVerificationFailed(errorMessage);
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          onCodeAutoRetrievalTimeout(verificationId);
        },
        forceResendingToken: _resendToken,
        timeout: const Duration(seconds: 60),
      );
      return _verificationId;
    } catch (e) {
      onVerificationFailed('Failed to send OTP: \$e');
      return null;
    }
  }

  // Verify OTP and sign in
  Future<UserCredential?> verifyOTP({
    required String verificationId,
    required String otp,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'invalid-verification-code':
          errorMessage = 'The verification code is invalid.';
          break;
        case 'session-expired':
          errorMessage = 'The verification session has expired.';
          break;
        case 'invalid-verification-id':
          errorMessage = 'The verification ID is invalid.';
          break;
        default:
          errorMessage = 'Failed to verify OTP: \${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Failed to verify OTP: \$e');
    }
  }

  // Resend OTP
  Future<String?> resendOTP({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onVerificationFailed,
    required Function(UserCredential) onVerificationCompleted,
    required Function(String) onCodeAutoRetrievalTimeout,
  }) async {
    return await sendOTP(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onVerificationFailed: onVerificationFailed,
      onVerificationCompleted: onVerificationCompleted,
      onCodeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
    );
  }

  // Sign out
  Future<void> signOut(BuildContext context) async {
    try {
      // Clear all user-specific data from providers
      Provider.of<UserProvider>(context, listen: false).clearUser();
      Provider.of<EventProvider>(context, listen: false).leaveEvent();
      Provider.of<LikesProvider>(context, listen: false).resetLikes();
      Provider.of<MatchProvider>(context, listen: false).clearMatches();
      Provider.of<AllEventsProvider>(context, listen: false).stopListening();

      // Clear caches
      DatabaseService().clearUserCache();
      await B2CacheManager().emptyCache();

      // Sign out from Firebase Auth
      await _auth.signOut();

      // Clear verification data
      _verificationId = null;
      _resendToken = null;
    } catch (e) {
      print('Error signing out: \$e');
      throw Exception('Failed to sign out: \$e');
    }
  }

  // Get current phone number
  String? getCurrentPhoneNumber() {
    return _auth.currentUser?.phoneNumber;
  }

  // Update phone number (requires re-authentication)
  Future<void> updatePhoneNumber({
    required String newPhoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onVerificationFailed,
    required Function() onVerificationCompleted,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in');
    }

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: newPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await user.updatePhoneNumber(credential);
            onVerificationCompleted();
          } catch (e) {
            onVerificationFailed('Failed to update phone number: \$e');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          String errorMessage;
          switch (e.code) {
            case 'invalid-phone-number':
              errorMessage = 'The phone number entered is invalid.';
              break;
            case 'too-many-requests':
              errorMessage = 'Too many requests. Please try again later.';
              break;
            default:
              errorMessage = 'Verification failed: \${e.message}';
          }
          onVerificationFailed(errorMessage);
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      onVerificationFailed('Failed to send verification code: \$e');
    }
  }

  // Verify OTP for phone number update
  Future<void> verifyPhoneNumberUpdate({
    required String verificationId,
    required String otp,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in');
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      await user.updatePhoneNumber(credential);
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'invalid-verification-code':
          errorMessage = 'The verification code is invalid.';
          break;
        case 'session-expired':
          errorMessage = 'The verification session has expired.';
          break;
        default:
          errorMessage = 'Failed to update phone number: \${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Failed to update phone number: \$e');
    }
  }
}