abstract class EmailVerifier {
  Future<void> sendLink(String firebaseToken);

  Future<void> resendLink();

  Future<String?> confirmedIdToken();

  Future<void> signOut();
}

enum EmailVerificationProblem {
  tooManyRequests,
  offline,

  signedOut,
  unknown,
}

class EmailVerificationException implements Exception {
  final EmailVerificationProblem problem;
  const EmailVerificationException(this.problem);

  @override
  String toString() => 'EmailVerificationException: ${problem.name}';
}
