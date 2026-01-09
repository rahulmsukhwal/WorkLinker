import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:worklinker/core/providers/user_provider.dart';
import 'package:worklinker/core/providers/project_provider.dart';
import 'package:worklinker/core/models/user_model.dart';
import 'package:worklinker/core/utils/permissions.dart';
import 'package:worklinker/features/project/screens/create_project_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      if (userProvider.currentUser != null) {
        context.read<ProjectProvider>().loadUserProjects(
              userProvider.currentUser!.uid,
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WorkLinker'),
        actions: [
          Consumer<UserProvider>(
            builder: (context, userProvider, _) {
              if (userProvider.currentUser?.globalRole == GlobalRole.admin) {
                return IconButton(
                  icon: const Icon(Icons.admin_panel_settings),
                  onPressed: () => context.go('/admin'),
                  tooltip: 'Admin Panel',
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final userProvider = context.read<UserProvider>();
              await userProvider.signOut();
              if (!mounted) return;
              context.go('/login');
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Consumer2<UserProvider, ProjectProvider>(
        builder: (context, userProvider, projectProvider, _) {
          if (userProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = userProvider.currentUser;
          if (user == null) {
            return const Center(child: Text('Not authenticated'));
          }

          return Column(
            children: [
              // User info card
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        child: Text(user.getAlias()[0]),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.getAlias(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Role: ${user.globalRole.toString().split('.').last}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Projects section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'My Projects',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (Permissions.canCreateProject(user.globalRole))
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CreateProjectScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('New Project'),
                      ),
                  ],
                ),
              ),

              // Projects list
              Expanded(
                child: StreamBuilder(
                  stream: projectProvider.projectService.getUserProjects(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }

                    final projects = snapshot.data ?? [];

                    if (projects.isEmpty) {
                      return const Center(
                        child: Text('No active projects assigned.'),
                      );
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
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              context.go('/project/${project.projectId}');
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

