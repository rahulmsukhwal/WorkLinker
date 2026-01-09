import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project_model.dart';
import '../models/project_member_model.dart';
import '../models/group_model.dart';
import '../models/user_model.dart';
import '../utils/permissions.dart';

class ProjectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a new project
  Future<String> createProject({
    required String title,
    String? description,
    required String clientPhone,
    String? assignedManagerId,
    required String createdBy,
    required GlobalRole creatorRole,
  }) async {
    if (!Permissions.canCreateProject(creatorRole)) {
      throw Exception('You do not have permission to create projects');
    }

    try {
      // Create project
      final projectRef = await _firestore.collection('projects').add({
        'title': title,
        'description': description,
        'createdBy': createdBy,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final projectId = projectRef.id;

      // Get or create client user
      String clientId = await _getOrCreateUserByPhone(clientPhone);

      // Determine manager
      String managerId = assignedManagerId ?? createdBy;

      // Add members
      final members = <String>[];

      // Add admin (always)
      if (creatorRole == GlobalRole.admin) {
        await _firestore.collection('projectMembers').add({
          'projectId': projectId,
          'userId': createdBy,
          'projectRole': ProjectRole.manager.toString().split('.').last,
          'addedBy': createdBy,
          'addedAt': FieldValue.serverTimestamp(),
        });
        members.add(createdBy);
      }

      // Add manager
      await _firestore.collection('projectMembers').add({
        'projectId': projectId,
        'userId': managerId,
        'projectRole': ProjectRole.manager.toString().split('.').last,
        'addedBy': createdBy,
        'addedAt': FieldValue.serverTimestamp(),
      });
      members.add(managerId);

      // Add client
      await _firestore.collection('projectMembers').add({
        'projectId': projectId,
        'userId': clientId,
        'projectRole': ProjectRole.client.toString().split('.').last,
        'addedBy': createdBy,
        'addedAt': FieldValue.serverTimestamp(),
      });
      members.add(clientId);

      // Create group
      await _firestore.collection('groups').doc(projectId).set({
        'memberIds': members,
      });

      return projectId;
    } catch (e) {
      throw Exception('Failed to create project: $e');
    }
  }

  /// Get or create user by phone number
  Future<String> _getOrCreateUserByPhone(String phone) async {
    final query = await _firestore
        .collection('users')
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first.id;
    }

    // Create new user
    final newUserRef = await _firestore.collection('users').add({
      'phone': phone,
      'globalRole': GlobalRole.client.toString().split('.').last,
      'status': UserStatus.active.toString().split('.').last,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return newUserRef.id;
  }

  /// Get user projects
  Stream<List<ProjectModel>> getUserProjects(String userId) {
    return _firestore
        .collection('projectMembers')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      final projectIds = snapshot.docs
          .map((doc) => doc.data()['projectId'] as String)
          .toSet()
          .toList();

      if (projectIds.isEmpty) return [];

      final projects = await Future.wait(
        projectIds.map((id) async {
          final doc = await _firestore.collection('projects').doc(id).get();
          if (doc.exists) {
            return ProjectModel.fromFirestore(doc);
          }
          return null;
        }),
      );

      return projects.whereType<ProjectModel>().toList();
    });
  }

  /// Get project details
  Future<ProjectModel?> getProject(String projectId) async {
    final doc = await _firestore.collection('projects').doc(projectId).get();
    if (doc.exists) {
      return ProjectModel.fromFirestore(doc);
    }
    return null;
  }

  /// Get project members
  Stream<List<ProjectMemberModel>> getProjectMembers(String projectId) {
    return _firestore
        .collection('projectMembers')
        .where('projectId', isEqualTo: projectId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProjectMemberModel.fromFirestore(doc))
            .toList());
  }

  /// Add developer to project
  Future<void> addDeveloper({
    required String projectId,
    required String developerPhone,
    required String addedBy,
    required GlobalRole addedByRole,
    required ProjectRole? addedByProjectRole,
  }) async {
    if (!Permissions.canManageDevelopers(addedByRole, addedByProjectRole)) {
      throw Exception('You do not have permission to add developers');
    }

    final developerId = await _getOrCreateUserByPhone(developerPhone);

    await _firestore.collection('projectMembers').add({
      'projectId': projectId,
      'userId': developerId,
      'projectRole': ProjectRole.developer.toString().split('.').last,
      'addedBy': addedBy,
      'addedAt': FieldValue.serverTimestamp(),
    });

    // Add to group
    final groupDoc = await _firestore.collection('groups').doc(projectId).get();
    if (groupDoc.exists) {
      final memberIds = List<String>.from(groupDoc.data()?['memberIds'] ?? []);
      if (!memberIds.contains(developerId)) {
        memberIds.add(developerId);
        await _firestore.collection('groups').doc(projectId).update({
          'memberIds': memberIds,
        });
      }
    }
  }

  /// Remove member from project
  Future<void> removeMember({
    required String projectId,
    required String userId,
    required String removedBy,
    required GlobalRole removedByRole,
    required ProjectRole? removedByProjectRole,
  }) async {
    final memberDoc = await _firestore
        .collection('projectMembers')
        .where('projectId', isEqualTo: projectId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (memberDoc.docs.isEmpty) {
      throw Exception('Member not found in project');
    }

    final member = ProjectMemberModel.fromFirestore(memberDoc.docs.first);

    if (!Permissions.canRemoveMember(
      removedByRole,
      removedByProjectRole,
      userId,
      removedBy,
      member.projectRole,
    )) {
      throw Exception('You do not have permission to remove this member');
    }

    // Remove from projectMembers
    await _firestore.collection('projectMembers').doc(memberDoc.docs.first.id).delete();

    // Remove from group
    final groupDoc = await _firestore.collection('groups').doc(projectId).get();
    if (groupDoc.exists) {
      final memberIds = List<String>.from(groupDoc.data()?['memberIds'] ?? []);
      memberIds.remove(userId);
      await _firestore.collection('groups').doc(projectId).update({
        'memberIds': memberIds,
      });
    }
  }

  /// Get all projects (admin only)
  Stream<List<ProjectModel>> getAllProjects() {
    return _firestore
        .collection('projects')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProjectModel.fromFirestore(doc))
            .toList());
  }

  /// Close/Delete project (admin only)
  Future<void> closeProject(String projectId) async {
    await _firestore.collection('projects').doc(projectId).delete();
  }
}

