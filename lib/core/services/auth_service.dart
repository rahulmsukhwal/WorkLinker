import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Send OTP to phone number
  /// Returns verificationId when code is sent
  Future<String> sendOTP(String phoneNumber) async {
    final completer = Completer<String>();
    
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!completer.isCompleted) {
          completer.completeError(e);
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        if (!completer.isCompleted) {
          completer.complete(verificationId);
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        if (!completer.isCompleted) {
          completer.complete(verificationId);
        }
      },
      timeout: const Duration(seconds: 60),
    );
    
    return completer.future;
  }

  /// Verify OTP and sign in
  Future<UserModel?> verifyOTP(String verificationId, String smsCode) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // Check if user exists in Firestore
        final userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          // Create new user with client role by default
          await _firestore.collection('users').doc(user.uid).set({
            'phone': user.phoneNumber ?? '',
            'globalRole': GlobalRole.client.toString().split('.').last,
            'status': UserStatus.active.toString().split('.').last,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        return await getUser(user.uid);
      }
      return null;
    } catch (e) {
      throw Exception('OTP verification failed: $e');
    }
  }

  /// Get user data from Firestore
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Check if user is admin
  Future<bool> isAdmin(String uid) async {
    final user = await getUser(uid);
    return user?.globalRole == GlobalRole.admin;
  }
}

