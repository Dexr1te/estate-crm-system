/// Emails a new account the link that confirms its address, and tells when
/// that link has been opened.
///
/// The backend hands out the token to send the link with; the proof that it
/// was opened goes back to the backend, which issues the app's own session.
abstract class EmailVerifier {
  /// Signs in with [firebaseToken] from the backend and emails the link.
  Future<void> sendLink(String firebaseToken);

  /// Emails the link again to the account [sendLink] signed in.
  Future<void> resendLink();

  /// A fresh ID token once the link has been opened, or null until then.
  Future<String?> confirmedIdToken();

  Future<void> signOut();
}

/// Why sending or checking the link failed, in terms a screen can word.
enum EmailVerificationProblem {
  tooManyRequests,
  offline,

  /// The sign-in [EmailVerifier.sendLink] made is gone; signing in to the app
  /// again starts a new one.
  signedOut,
  unknown,
}

class EmailVerificationException implements Exception {
  final EmailVerificationProblem problem;
  const EmailVerificationException(this.problem);

  @override
  String toString() => 'EmailVerificationException: ${problem.name}';
}
