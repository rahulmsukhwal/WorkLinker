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

      // Check if user with this phone number already exists
      String? existingUserId;
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        final phoneQuery = await _firestore
            .collection('users')
            .where('phone', isEqualTo: phoneNumber)
            .limit(1)
            .get();
        
        if (phoneQuery.docs.isNotEmpty) {
          existingUserId = phoneQuery.docs.first.id;
        }
      }

      // Sign in anonymously to get Firebase Auth user (bypassing phone auth)
      final anonymousCredential = await _auth.signInAnonymously();
      
      if (anonymousCredential.user != null) {
        final uid = anonymousCredential.user!.uid;
        
        // If user with this phone exists, use that user's data
        if (existingUserId != null) {
          // Update the existing user's document to link with this auth UID
          // Or create a new document with the existing user's data
          final existingUserDoc = await _firestore.collection('users').doc(existingUserId).get();
          if (existingUserDoc.exists) {
            // Copy existing user data to new auth UID
            final existingData = existingUserDoc.data()!;
            await _firestore.collection('users').doc(uid).set(existingData);
            // Optionally delete old document or keep both
            return await getUser(uid);
          }
        }
        
        // Check if user exists in Firestore
        final userDoc = await _firestore.collection('users').doc(uid).get();

        if (!userDoc.exists) {
          // Check if this is the first user (no users exist in collection)
          final usersQuery = await _firestore.collection('users').limit(1).get();
          final isFirstUser = usersQuery.docs.isEmpty;
          
          // Create new user - first user becomes admin, others are clients
          await _firestore.collection('users').doc(uid).set({
            'phone': phoneNumber ?? 'unknown',
            'globalRole': isFirstUser 
                ? GlobalRole.admin.toString().split('.').last
                : GlobalRole.client.toString().split('.').last,
            'status': UserStatus.active.toString().split('.').last,
            'createdAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Update phone number if provided
          if (phoneNumber != null) {
            await _firestore.collection('users').doc(uid).update({
              'phone': phoneNumber,
            });
          }
        }
        
        return await getUser(uid);
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

