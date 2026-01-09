import 'package:cloud_firestore/cloud_firestore.dart';

enum ProjectRole {
  manager,
  developer,
  client,
}

class ProjectMemberModel {
  final String id;
  final String projectId;
  final String userId;
  final ProjectRole projectRole;
  final String addedBy;
  final DateTime addedAt;

  ProjectMemberModel({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.projectRole,
    required this.addedBy,
    required this.addedAt,
  });

  factory ProjectMemberModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProjectMemberModel(
      id: doc.id,
      projectId: data['projectId'] ?? '',
      userId: data['userId'] ?? '',
      projectRole: ProjectRole.values.firstWhere(
        (e) => e.toString().split('.').last == data['projectRole'],
        orElse: () => ProjectRole.developer,
      ),
      addedBy: data['addedBy'] ?? '',
      addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'projectId': projectId,
      'userId': userId,
      'projectRole': projectRole.toString().split('.').last,
      'addedBy': addedBy,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }
}
