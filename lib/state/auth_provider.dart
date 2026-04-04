import 'package:flutter/foundation.dart';
import '../core/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool get isSignedIn => _authService.isSignedIn;
  String? get userName => _authService.userName;
  String? get userEmail => _authService.userEmail;
  String? get profileImageUrl => _authService.profileImageUrl;

  Future<bool> signIn() async {
    final result = await _authService.signIn();
    notifyListeners();
    return result;
  }

  Future<void> signOut() async {
    await _authService.signOut();
    notifyListeners();
  }
}
