import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel {
  final String projectId;
  final String title;
  final String? description;
  final String createdBy;
  final DateTime createdAt;

  ProjectModel({
    required this.projectId,
    required this.title,
    this.description,
    required this.createdBy,
    required this.createdAt,
  });

  factory ProjectModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProjectModel(
      projectId: doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

