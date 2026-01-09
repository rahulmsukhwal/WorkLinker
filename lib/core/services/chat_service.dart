import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/message_model.dart';
import '../utils/anti_bypass_filter.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Send text message
  Future<void> sendTextMessage({
    required String projectId,
    required String senderId,
    required String content,
  }) async {
    // Validate message
    final validationError = AntiBypassFilter.validateMessage(content);
    if (validationError != null) {
      throw Exception(validationError);
    }

    // Sanitize content
    final sanitizedContent = AntiBypassFilter.sanitizeText(content);

    await _firestore.collection('messages').add({
      'projectId': projectId,
      'senderId': senderId,
      'type': MessageType.text.toString().split('.').last,
      'content': sanitizedContent,
      'timestamp': FieldValue.serverTimestamp(),
      'readBy': [senderId],
    });
  }

  /// Send voice message
  Future<void> sendVoiceMessage({
    required String projectId,
    required String senderId,
    required File audioFile,
  }) async {
    try {
      // Upload audio file
      final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final ref = _storage.ref().child('voice_messages/$projectId/$fileName');
      await ref.putFile(audioFile);
      final downloadUrl = await ref.getDownloadURL();

      await _firestore.collection('messages').add({
        'projectId': projectId,
        'senderId': senderId,
        'type': MessageType.voice.toString().split('.').last,
        'content': 'Voice message',
        'fileUrl': downloadUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'readBy': [senderId],
      });
    } catch (e) {
      throw Exception('Failed to send voice message: $e');
    }
  }

  /// Send file attachment
  Future<void> sendFileMessage({
    required String projectId,
    required String senderId,
    required File file,
    required String fileName,
  }) async {
    try {
      // Upload file
      final ref = _storage.ref().child('files/$projectId/$fileName');
      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();

      await _firestore.collection('messages').add({
        'projectId': projectId,
        'senderId': senderId,
        'type': MessageType.file.toString().split('.').last,
        'content': fileName,
        'fileUrl': downloadUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'readBy': [senderId],
      });
    } catch (e) {
      throw Exception('Failed to send file: $e');
    }
  }

  /// Get messages for a project
  Stream<List<MessageModel>> getMessages(String projectId) {
    return _firestore
        .collection('messages')
        .where('projectId', isEqualTo: projectId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromFirestore(doc))
            .toList());
  }

  /// Mark message as read
  Future<void> markAsRead(String messageId, String userId) async {
    final doc = await _firestore.collection('messages').doc(messageId).get();
    if (doc.exists) {
      final readBy = List<String>.from(doc.data()?['readBy'] ?? []);
      if (!readBy.contains(userId)) {
        readBy.add(userId);
        await _firestore.collection('messages').doc(messageId).update({
          'readBy': readBy,
        });
      }
    }
  }
}

