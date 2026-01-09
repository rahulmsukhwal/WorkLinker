import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:worklinker/core/router/app_router.dart';
import 'package:worklinker/core/services/auth_service.dart';
import 'package:worklinker/core/services/project_service.dart';
import 'package:worklinker/core/services/chat_service.dart';
import 'package:worklinker/core/providers/user_provider.dart';
import 'package:worklinker/core/providers/project_provider.dart';
import 'package:worklinker/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const WorkLinkerApp());
}

class WorkLinkerApp extends StatelessWidget {
  const WorkLinkerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<ProjectService>(
          create: (_) => ProjectService(),
        ),
        Provider<ChatService>(
          create: (_) => ChatService(),
        ),
        ChangeNotifierProvider(
          create: (context) => UserProvider(
            authService: context.read<AuthService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ProjectProvider(
            projectService: context.read<ProjectService>(),
            chatService: context.read<ChatService>(),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'WorkLinker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
