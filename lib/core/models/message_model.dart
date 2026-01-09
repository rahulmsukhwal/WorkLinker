import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  text,
  voice,
  file,
}

class MessageModel {
  final String messageId;
  final String projectId;
  final String senderId;
  final MessageType type;
  final String content;
  final String? fileUrl;
  final DateTime timestamp;
  final List<String> readBy;

  MessageModel({
    required this.messageId,
    required this.projectId,
    required this.senderId,
    required this.type,
    required this.content,
    this.fileUrl,
    required this.timestamp,
    required this.readBy,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      messageId: doc.id,
      projectId: data['projectId'] ?? '',
      senderId: data['senderId'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
        orElse: () => MessageType.text,
      ),
      content: data['content'] ?? '',
      fileUrl: data['fileUrl'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readBy: List<String>.from(data['readBy'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'projectId': projectId,
      'senderId': senderId,
      'type': type.toString().split('.').last,
      'content': content,
      'fileUrl': fileUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      'readBy': readBy,
    };
  }
}

