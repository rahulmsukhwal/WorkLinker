import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:worklinker/core/services/project_service.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Projects'),
              Tab(text: 'Users'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ProjectsTab(),
            _UsersTab(),
          ],
        ),
      ),
    );
  }
}

class _ProjectsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final projectService = context.read<ProjectService>();

    return StreamBuilder(
      stream: projectService.getAllProjects(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final projects = snapshot.data ?? [];

        if (projects.isEmpty) {
          return const Center(child: Text('No projects found'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(project.title),
                subtitle: project.description != null
                    ? Text(project.description!)
                    : null,
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'close',
                      child: Text('Close Project'),
                    ),
                  ],
                  onSelected: (value) async {
                    if (value == 'close') {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Close Project'),
                          content: const Text(
                            'Are you sure you want to close this project?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        try {
                          await projectService.closeProject(project.projectId);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Project closed successfully'),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: ${e.toString()}')),
                            );
                          }
                        }
                      }
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _UsersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Implement user management
    return const Center(
      child: Text('User management coming soon'),
    );
  }
}

