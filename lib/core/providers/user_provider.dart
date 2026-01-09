import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class UserProvider with ChangeNotifier {
  final AuthService authService;

  UserModel? _currentUser;
  bool _isLoading = false;

  UserProvider({required this.authService}) {
    _init();
  }

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  void _init() {
    authService.authStateChanges.listen((user) async {
      if (user != null) {
        await loadUser(user.uid);
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  Future<void> loadUser(String uid) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await authService.getUser(uid);
    } catch (e) {
      debugPrint('Error loading user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await authService.signOut();
    _currentUser = null;
    notifyListeners();
  }
}

