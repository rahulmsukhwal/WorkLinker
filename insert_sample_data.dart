import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:worklinker/firebase_options.dart';

/// Script to insert sample admin and manager data
/// Usage: dart run insert_sample_data.dart
Future<void> main() async {
  print('🔧 Inserting sample data...');
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    final firestore = FirebaseFirestore.instance;
    
    // Sample users data
    final sampleUsers = [
      {
        'phone': '+918209556233',
        'globalRole': 'admin',
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'phone': '+918209556222',
        'globalRole': 'manager',
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];
    
    print('📱 Creating sample users...');
    
    for (var userData in sampleUsers) {
      final phone = userData['phone'] as String;
      
      // Check if user already exists
      final querySnapshot = await firestore
          .collection('users')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        final existingDoc = querySnapshot.docs.first;
        print('⚠️  User with phone $phone already exists (ID: ${existingDoc.id})');
        print('   Current role: ${existingDoc.data()['globalRole']}');
        
        // Update to ensure correct role
        await firestore.collection('users').doc(existingDoc.id).update({
          'globalRole': userData['globalRole'],
          'status': userData['status'],
        });
        print('✅ Updated user: $phone -> ${userData['globalRole']}');
      } else {
        // Create new user with a temporary document ID
        // Note: In production, this would be linked to Firebase Auth UID
        // For now, we'll create with a generated ID
        final newDocRef = firestore.collection('users').doc();
        await newDocRef.set(userData);
        print('✅ Created user: $phone -> ${userData['globalRole']} (ID: ${newDocRef.id})');
        print('   ⚠️  Note: This user needs to login once to link with Firebase Auth');
      }
    }
    
    print('');
    print('✅ Sample data insertion complete!');
    print('');
    print('📝 Next steps:');
    print('1. Login with phone +918209556233 (admin)');
    print('2. Login with phone +918209556222 (manager)');
    print('3. The users will be linked to Firebase Auth UID on first login');
    print('');
    
    exit(0);
  } catch (e) {
    print('❌ Error: $e');
    exit(1);
  }
}
