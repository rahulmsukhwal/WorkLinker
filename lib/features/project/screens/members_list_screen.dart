import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:worklinker/core/providers/project_provider.dart';
import 'package:worklinker/core/providers/user_provider.dart';
import 'package:worklinker/core/services/auth_service.dart';

class MembersListScreen extends StatelessWidget {
  final String projectId;

  const MembersListScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Members'),
      ),
      body: Consumer2<UserProvider, ProjectProvider>(
        builder: (context, userProvider, projectProvider, _) {
          final currentUser = userProvider.currentUser;
          if (currentUser == null) {
            return const Center(child: Text('Not authenticated'));
          }

          return StreamBuilder(
            stream: projectProvider.projectService.getProjectMembers(projectId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final members = snapshot.data ?? [];

              if (members.isEmpty) {
                return const Center(child: Text('No members found'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final member = members[index];
                  return FutureBuilder(
                    future: context.read<AuthService>().getUser(member.userId),
                    builder: (context, userSnapshot) {
                      if (!userSnapshot.hasData) {
                        return const ListTile(
                          leading: CircularProgressIndicator(),
                          title: Text('Loading...'),
                        );
                      }

                      final user = userSnapshot.data;
                      if (user == null) {
                        return const ListTile(
                          title: Text('User not found'),
                        );
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(user.getAlias()[0]),
                          ),
                          title: Text(user.getAlias()),
                          subtitle: Text(
                            'Role: ${member.projectRole.toString().split('.').last}',
                          ),
                          trailing: member.userId == currentUser.uid
                              ? const Chip(
                                  label: Text('You'),
                                  backgroundColor: Colors.blue,
                                )
                              : null,
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

