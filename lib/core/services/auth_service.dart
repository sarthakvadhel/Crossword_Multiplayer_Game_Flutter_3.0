class AuthService {
  String? userName;
  String? userEmail;
  String? profileImageUrl;
  bool isSignedIn = false;

  // Placeholder for Google Sign-In integration
  Future<bool> signIn() async {
    // In production, this would use GoogleSignIn
    // For now, simulate a successful sign-in
    userName = 'Player';
    userEmail = 'player@example.com';
    isSignedIn = true;
    return true;
  }

  Future<void> signOut() async {
    userName = null;
    userEmail = null;
    profileImageUrl = null;
    isSignedIn = false;
  }
}
