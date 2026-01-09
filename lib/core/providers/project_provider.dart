import 'package:flutter/foundation.dart';
import '../models/project_model.dart';
import '../models/project_member_model.dart';
import '../services/project_service.dart';
import '../services/chat_service.dart';

class ProjectProvider with ChangeNotifier {
  final ProjectService projectService;
  final ChatService chatService;

  List<ProjectModel> _projects = [];
  ProjectModel? _selectedProject;
  List<ProjectMemberModel> _projectMembers = [];
  bool _isLoading = false;

  ProjectProvider({
    required this.projectService,
    required this.chatService,
  });

  List<ProjectModel> get projects => _projects;
  ProjectModel? get selectedProject => _selectedProject;
  List<ProjectMemberModel> get projectMembers => _projectMembers;
  bool get isLoading => _isLoading;

  Future<void> loadUserProjects(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      projectService.getUserProjects(userId).listen((projects) {
        _projects = projects;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Error loading projects: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectProject(String projectId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedProject = await projectService.getProject(projectId);
      projectService.getProjectMembers(projectId).listen((members) {
        _projectMembers = members;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Error selecting project: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createProject({
    required String title,
    String? description,
    required String clientPhone,
    String? assignedManagerId,
    required String createdBy,
    required dynamic creatorRole,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await projectService.createProject(
        title: title,
        description: description,
        clientPhone: clientPhone,
        assignedManagerId: assignedManagerId,
        createdBy: createdBy,
        creatorRole: creatorRole,
      );
    } catch (e) {
      debugPrint('Error creating project: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

