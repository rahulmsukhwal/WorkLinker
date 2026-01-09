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
  /// NOTE: OTP sending is disabled for testing - using hardcoded OTP "123456"
  Future<String> sendOTP(String phoneNumber) async {
    // Bypass actual OTP sending - return dummy verificationId
    // For testing, use hardcoded OTP: 123456
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    return 'dummy_verification_id_for_testing';
  }

  /// Verify OTP and sign in
  /// NOTE: For testing, hardcoded OTP "123456" is accepted
  Future<UserModel?> verifyOTP(String verificationId, String smsCode, {String? phoneNumber}) async {
    try {
      // Hardcoded OTP for testing - accept "123456"
      if (smsCode != '123456') {
        throw Exception('Invalid OTP. Use 123456 for testing.');
      }

      if (phoneNumber == null || phoneNumber.isEmpty) {
        throw Exception('Phone number is required');
      }

      // Check if user with this phone number already exists in Firestore
      UserModel? existingUser;
      
      final phoneQuery = await _firestore
          .collection('users')
          .where('phone', isEqualTo: phoneNumber)
          .limit(1)
          .get();
      
      if (phoneQuery.docs.isNotEmpty) {
        existingUser = UserModel.fromFirestore(phoneQuery.docs.first);
      }

      // Sign in anonymously to get Firebase Auth user (bypassing phone auth)
      final anonymousCredential = await _auth.signInAnonymously();
      
      if (anonymousCredential.user == null) {
        throw Exception('Failed to create authentication session');
      }
      
      final uid = anonymousCredential.user!.uid;
      
      // Check if user document already exists for this auth UID
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        // User already exists, update phone if needed and return
        final currentPhone = userDoc.data()?['phone'] as String?;
        if (currentPhone != phoneNumber) {
          await _firestore.collection('users').doc(uid).update({
            'phone': phoneNumber,
          });
        }
        return await getUser(uid);
      }
      
      // Create new user document
      if (existingUser != null) {
        // User exists with this phone number but different auth UID
        // Create new document with existing user's role and data
        await _firestore.collection('users').doc(uid).set({
          'phone': phoneNumber,
          'globalRole': existingUser.globalRole.toString().split('.').last,
          'status': existingUser.status.toString().split('.').last,
          'createdAt': existingUser.createdAt ?? FieldValue.serverTimestamp(),
        });
      } else {
        // Brand new user - default role is client
        await _firestore.collection('users').doc(uid).set({
          'phone': phoneNumber,
          'globalRole': GlobalRole.client.toString().split('.').last,
          'status': UserStatus.active.toString().split('.').last,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      
      return await getUser(uid);
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

