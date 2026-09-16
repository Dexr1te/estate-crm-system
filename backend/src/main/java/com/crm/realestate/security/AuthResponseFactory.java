package com.crm.realestate.security;

import com.crm.realestate.dto.response.AuthResponse;
import com.crm.realestate.entity.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

/**
 * The one shape every sign-in, refresh and profile read answers with.
 *
 * <p>It names the team as well as the role: the app decides from those two whether someone lands on
 * the dashboard, on "create your agency" or on "waiting to be added".
 */
@Component
@RequiredArgsConstructor
public class AuthResponseFactory {

    private final JwtService jwtService;

    /** A fresh pair of tokens along with who they belong to. */
    public AuthResponse withNewTokens(User user) {
        return build(user, jwtService.generateAccessToken(user), jwtService.generateRefreshToken(user));
    }

    public AuthResponse build(User user, String accessToken, String refreshToken) {
        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .userId(user.getId())
                .fullName(user.getFullName())
                .email(user.getEmail())
                .role(user.getRole())
                .dataScope(user.getDataScope())
                .status(user.getStatus())
                .teamId(user.getTeam() == null ? null : user.getTeam().getId())
                .teamName(user.getTeam() == null ? null : user.getTeam().getName())
                .mustChangePassword(user.isMustChangePassword())
                .build();
    }
}
