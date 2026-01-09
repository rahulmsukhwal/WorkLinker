class GroupModel {
  final String projectId;
  final List<String> memberIds;

  GroupModel({
    required this.projectId,
    required this.memberIds,
  });

  factory GroupModel.fromMap(String projectId, Map<String, dynamic> data) {
    return GroupModel(
      projectId: projectId,
      memberIds: List<String>.from(data['memberIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'memberIds': memberIds,
    };
  }
}

