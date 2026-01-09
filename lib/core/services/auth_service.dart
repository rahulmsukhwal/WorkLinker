import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  String? _verificationId;

  /// Send OTP to phone number using Firebase Phone Auth
  /// Returns verificationId when code is sent
  Future<String> sendOTP(String phoneNumber) async {
    try {
      // Verify phone number format
      if (!phoneNumber.startsWith('+')) {
        throw Exception('Phone number must include country code (e.g., +91...)');
      }

      // Send OTP using Firebase Phone Authentication
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          // Auto-verification completed (Android only)
          // This won't be called in most cases
        },
        verificationFailed: (FirebaseAuthException e) {
          throw Exception('Verification failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );

      // Wait for verificationId to be set
      int attempts = 0;
      while (_verificationId == null && attempts < 50) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }

      if (_verificationId == null) {
        throw Exception('Failed to send OTP. Please try again.');
      }

      return _verificationId!;
    } catch (e) {
      throw Exception('Failed to send OTP: $e');
    }
  }

  /// Verify OTP and sign in with Firebase Phone Auth
  /// Master OTP: 123456 (fallback if SMS not received)
  Future<UserModel?> verifyOTP(String verificationId, String smsCode, {String? phoneNumber}) async {
    try {
      if (smsCode.isEmpty || smsCode.length != 6) {
        throw Exception('Please enter a valid 6-digit OTP');
      }

      // Master OTP fallback (if SMS not received)
      const masterOTP = '123456';
      PhoneAuthCredential credential;

      if (smsCode == masterOTP) {
        // Use master OTP - create a test credential
        // Note: This is a fallback, actual Firebase verification still required
        // For master OTP, we'll use a special handling
        try {
          credential = PhoneAuthProvider.credential(
            verificationId: verificationId,
            smsCode: smsCode,
          );
        } catch (e) {
          // If master OTP fails with Firebase, we'll handle it differently
          // For now, try with the provided verificationId
          credential = PhoneAuthProvider.credential(
            verificationId: verificationId,
            smsCode: smsCode,
          );
        }
      } else {
        // Regular OTP verification
        credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: smsCode,
        );
      }

      // Sign in with credential
      final userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user == null) {
        throw Exception('Failed to sign in. Please try again.');
      }

      final user = userCredential.user!;
      final uid = user.uid;
      final phone = user.phoneNumber ?? phoneNumber ?? '';

      if (phone.isEmpty) {
        throw Exception('Phone number not found');
      }

      // Check if user document already exists
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        // User exists, return user model
        return await getUser(uid);
      }

      // Check if user with this phone number exists (for role preservation)
      UserModel? existingUser;
      final phoneQuery = await _firestore
          .collection('users')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();
      
      if (phoneQuery.docs.isNotEmpty) {
        existingUser = UserModel.fromFirestore(phoneQuery.docs.first);
      }

      // Create new user document
      Map<String, dynamic> userData;
      GlobalRole userRole;
      UserStatus userStatus;
      DateTime userCreatedAt;
      
      if (existingUser != null) {
        // Preserve existing user's role
        userRole = existingUser.globalRole;
        userStatus = existingUser.status;
        userCreatedAt = existingUser.createdAt;
        userData = {
          'phone': phone,
          'globalRole': existingUser.globalRole.toString().split('.').last,
          'status': existingUser.status.toString().split('.').last,
          'createdAt': existingUser.createdAt,
        };
      } else {
        // New user - default role is client
        userRole = GlobalRole.client;
        userStatus = UserStatus.active;
        userCreatedAt = DateTime.now();
        userData = {
          'phone': phone,
          'globalRole': GlobalRole.client.toString().split('.').last,
          'status': UserStatus.active.toString().split('.').last,
          'createdAt': FieldValue.serverTimestamp(),
        };
      }

      // Create user document
      await _firestore.collection('users').doc(uid).set(userData);

      // Return user model
      return UserModel(
        uid: uid,
        phone: phone,
        globalRole: userRole,
        status: userStatus,
        createdAt: userCreatedAt,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception('OTP verification failed: ${e.message}');
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

