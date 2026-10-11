package com.crm.realestate.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Where a new account stands. Either the address still has to be proven — {@link #firebaseToken}
 * is what the app signs in to Firebase with to have the link emailed — or, with verification
 * switched off, the account is signed in and {@link #auth} is its session.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RegisterResponse {
    private String email;
    private boolean verificationRequired;
    /** A Firebase custom token for the account's Firebase user. Null once signed in. */
    private String firebaseToken;
    /** The session, when nothing is left to prove. Null while verification is pending. */
    private AuthResponse auth;
}
