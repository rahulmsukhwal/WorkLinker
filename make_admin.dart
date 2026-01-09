import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:worklinker/firebase_options.dart';

/// Script to make a phone number admin
/// Usage: dart run make_admin.dart [phone_number]
/// Example: dart run make_admin.dart +918209556233
Future<void> main(List<String> args) async {
  // Default phone number
  String phoneNumber = '+918209556233';
  
  // If phone number provided as argument, use it
  if (args.isNotEmpty) {
    phoneNumber = args[0];
  }
  
  print('🔧 Making admin for phone number: $phoneNumber');
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    final firestore = FirebaseFirestore.instance;
    
    // Find user by phone number
    print('📱 Searching for user with phone: $phoneNumber');
    final querySnapshot = await firestore
        .collection('users')
        .where('phone', isEqualTo: phoneNumber)
        .limit(1)
        .get();
    
    if (querySnapshot.docs.isEmpty) {
      print('❌ User not found with phone number: $phoneNumber');
      print('💡 Make sure the user has logged in at least once.');
      exit(1);
    }
    
    final userDoc = querySnapshot.docs.first;
    final userId = userDoc.id;
    final userData = userDoc.data();
    
    print('✅ Found user: $userId');
    print('   Current role: ${userData['globalRole'] ?? 'not set'}');
    
    // Update user to admin
    await firestore.collection('users').doc(userId).update({
      'globalRole': 'admin',
    });
    
    print('✅ Successfully updated user to admin!');
    print('   User ID: $userId');
    print('   Phone: $phoneNumber');
    print('   Role: admin');
    
    exit(0);
  } catch (e) {
    print('❌ Error: $e');
    exit(1);
  }
}
