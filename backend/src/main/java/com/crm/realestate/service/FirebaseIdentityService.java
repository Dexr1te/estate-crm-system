package com.crm.realestate.service;

import com.crm.realestate.exception.BusinessException;
import com.google.firebase.FirebaseApp;
import com.google.firebase.auth.AuthErrorCode;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;
import com.google.firebase.auth.UserRecord;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

/**
 * The part of sign-up that Firebase does: proving that whoever registered an address can read
 * its mail.
 *
 * <p>This host cannot send mail reliably, so the app does it instead: it signs in to a Firebase
 * user with the custom token handed out here and asks Firebase to email that user a link. Opening
 * the link marks the Firebase user verified, which {@link #identify} reads back. Passwords and
 * sessions stay with this backend; Firebase only ever holds the address.
 */
@Service
@Slf4j
public class FirebaseIdentityService {

    /** Who an ID token belongs to, read fresh from Firebase rather than from the token's claims. */
    public record Identity(String uid, String email, boolean emailVerified) {}

    /**
     * Finds or creates the Firebase user for an address.
     *
     * @param resetVerified true for a new sign-up: an address verified for an earlier account (one
     *     since deleted, say) must be proven again by whoever is registering it now
     * @return the Firebase uid
     */
    public String prepare(String email, String displayName, boolean resetVerified) {
        FirebaseAuth auth = auth();
        try {
            UserRecord existing = auth.getUserByEmail(email);
            if (resetVerified && existing.isEmailVerified()) {
                auth.updateUser(new UserRecord.UpdateRequest(existing.getUid()).setEmailVerified(false));
            }
            return existing.getUid();
        } catch (FirebaseAuthException e) {
            if (e.getAuthErrorCode() != AuthErrorCode.USER_NOT_FOUND) {
                throw unavailable(e);
            }
        }
        try {
            return auth.createUser(new UserRecord.CreateRequest()
                    .setEmail(email)
                    .setEmailVerified(false)
                    .setDisplayName(displayName)).getUid();
        } catch (FirebaseAuthException e) {
            throw unavailable(e);
        }
    }

    /** What the app signs in to the Firebase user with, so it can ask for the link to be sent. */
    public String customToken(String uid) {
        try {
            return auth().createCustomToken(uid);
        } catch (FirebaseAuthException e) {
            throw unavailable(e);
        }
    }

    /**
     * Checks an ID token and says whose it is.
     *
     * <p>Verification is read from the user record, not the token: a token minted before the link
     * was opened still says unverified, and the app should not have to know to refresh it.
     */
    public Identity identify(String idToken) {
        FirebaseAuth auth = auth();
        FirebaseToken token;
        try {
            token = auth.verifyIdToken(idToken);
        } catch (FirebaseAuthException | IllegalArgumentException e) {
            throw invalid();
        }
        try {
            UserRecord user = auth.getUser(token.getUid());
            return new Identity(user.getUid(), user.getEmail(), user.isEmailVerified());
        } catch (FirebaseAuthException e) {
            if (e.getAuthErrorCode() == AuthErrorCode.USER_NOT_FOUND) {
                throw invalid();
            }
            throw unavailable(e);
        }
    }

    private FirebaseAuth auth() {
        if (FirebaseApp.getApps().isEmpty()) {
            log.error("Sign-up needs Firebase, and it did not start. Set FIREBASE_CREDENTIALS_PATH to "
                    + "the service-account key, or SIGNUP_VERIFY_EMAIL=false to sign up without it.");
            throw unavailable(null);
        }
        return FirebaseAuth.getInstance();
    }

    static BusinessException invalid() {
        return new BusinessException(HttpStatus.BAD_REQUEST, "VERIFICATION_INVALID",
                "This confirmation is not valid. Sign in again to get a new link.");
    }

    private static BusinessException unavailable(Exception cause) {
        if (cause != null) {
            log.error("Firebase refused a sign-up call: {}", cause.getMessage());
        }
        return new BusinessException(HttpStatus.SERVICE_UNAVAILABLE, "VERIFICATION_UNAVAILABLE",
                "We cannot confirm email addresses right now. Please try again in a few minutes.");
    }
}
