import '../models/user_model.dart';
import '../models/project_member_model.dart';

class Permissions {
  /// Check if user can create project
  static bool canCreateProject(GlobalRole globalRole) {
    return globalRole == GlobalRole.admin || globalRole == GlobalRole.manager;
  }

  /// Check if user can add/remove managers
  static bool canManageManagers(GlobalRole globalRole) {
    return globalRole == GlobalRole.admin;
  }

  /// Check if user can add/remove developers
  static bool canManageDevelopers(
    GlobalRole globalRole,
    ProjectRole? projectRole,
  ) {
    return globalRole == GlobalRole.admin ||
        projectRole == ProjectRole.manager;
  }

  /// Check if user can add/remove clients
  static bool canManageClients(GlobalRole globalRole) {
    return globalRole == GlobalRole.admin;
  }

  /// Check if user can remove member from project
  static bool canRemoveMember(
    GlobalRole globalRole,
    ProjectRole? projectRole,
    String targetUserId,
    String currentUserId,
    ProjectRole? targetProjectRole,
  ) {
    // Admin can remove anyone
    if (globalRole == GlobalRole.admin) {
      return true;
    }

    // Manager can remove developers only
    if (projectRole == ProjectRole.manager) {
      return targetProjectRole == ProjectRole.developer;
    }

    // Developers can only leave themselves
    if (projectRole == ProjectRole.developer) {
      return targetUserId == currentUserId;
    }

    return false;
  }

  /// Check if user can close/delete project
  static bool canCloseProject(GlobalRole globalRole) {
    return globalRole == GlobalRole.admin;
  }

  /// Check if user can view admin panel
  static bool canViewAdminPanel(GlobalRole globalRole) {
    return globalRole == GlobalRole.admin;
  }

  /// Check if user can chat in project
  static bool canChat(ProjectRole? projectRole) {
    return projectRole != null;
  }
}

