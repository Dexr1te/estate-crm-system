import 'package:firebase_auth/firebase_auth.dart';
import 'package:real_estate_crm/features/auth/domain/email_verifier.dart';

class FirebaseEmailVerifier implements EmailVerifier {
  const FirebaseEmailVerifier();

  // Looked up on every call, never held: tests run without Firebase, and the
  // app still starts when Firebase does not (see main.dart).
  FirebaseAuth get _auth => FirebaseAuth.instance;

  @override
  Future<void> sendLink(String firebaseToken) => _guard(() async {
        await _auth.signInWithCustomToken(firebaseToken);
        final user = _signedIn();
        // Opened on an earlier attempt: another email would only confuse.
        if (!user.emailVerified) await user.sendEmailVerification();
      });

  @override
  Future<void> resendLink() =>
      _guard(() => _signedIn().sendEmailVerification());

  @override
  Future<String?> confirmedIdToken() => _guard(() async {
        await _signedIn().reload();
        // reload() swaps in a new User; the one it was called on is stale.
        final user = _signedIn();
        return user.emailVerified ? user.getIdToken(true) : null;
      });

  @override
  Future<void> signOut() => _auth.signOut();

  User _signedIn() {
    final user = _auth.currentUser;
    if (user == null) {
      throw const EmailVerificationException(
          EmailVerificationProblem.signedOut);
    }
    return user;
  }

  static Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on FirebaseAuthException catch (e) {
      throw EmailVerificationException(_problemOf(e.code));
    } on FirebaseException {
      // Firebase itself never started.
      throw const EmailVerificationException(EmailVerificationProblem.unknown);
    }
  }

  static EmailVerificationProblem _problemOf(String code) {
    switch (code) {
      case 'too-many-requests':
        return EmailVerificationProblem.tooManyRequests;
      case 'network-request-failed':
        return EmailVerificationProblem.offline;
      case 'invalid-custom-token':
      case 'custom-token-mismatch':
      case 'user-token-expired':
      case 'invalid-user-token':
      case 'user-not-found':
      case 'user-disabled':
      case 'no-current-user':
        return EmailVerificationProblem.signedOut;
      default:
        return EmailVerificationProblem.unknown;
    }
  }
}
