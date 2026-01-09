import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_verification_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/project/screens/project_details_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/admin/screens/admin_panel_screen.dart';
import '../../features/project/screens/create_project_screen.dart';
import '../../features/project/screens/members_list_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/otp-verify',
        builder: (context, state) {
          final phone = state.uri.queryParameters['phone'] ?? '';
          final verificationId = state.uri.queryParameters['verificationId'] ?? '';
          return OTPVerificationScreen(
            phone: phone,
            verificationId: verificationId,
          );
        },
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/project/:projectId',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          return ProjectDetailsScreen(projectId: projectId);
        },
      ),
      GoRoute(
        path: '/project/:projectId/chat',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          return ChatScreen(projectId: projectId);
        },
      ),
      GoRoute(
        path: '/project/:projectId/members',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          return MembersListScreen(projectId: projectId);
        },
      ),
      GoRoute(
        path: '/create-project',
        builder: (context, state) => const CreateProjectScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminPanelScreen(),
      ),
    ],
  );
}

