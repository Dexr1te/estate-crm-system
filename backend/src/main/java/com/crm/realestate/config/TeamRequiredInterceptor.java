package com.crm.realestate.config;

import com.crm.realestate.entity.User;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.security.SecurityUtils;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

/**
 * Keeps the CRM shut until someone belongs to an agency.
 *
 * <p>Records live in a team, so an account without one has nowhere to put a client and nothing to
 * read. A manager has to create their agency first, an agent has to be added to one. Answering
 * {@code TEAM_REQUIRED} rather than an empty list is what lets the app send them to the right
 * screen instead of showing an agency with nothing in it.
 *
 * <p>Admins run the platform rather than an agency, so they are not held here.
 */
@Component
@RequiredArgsConstructor
public class TeamRequiredInterceptor implements HandlerInterceptor {

    private final SecurityUtils securityUtils;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            // Not our call to make: the security filter chain answers for this one.
            return true;
        }
        User user = currentUser(authentication);
        if (user == null || user.getRole() == com.crm.realestate.enums.Role.ADMIN || user.getTeam() != null) {
            return true;
        }
        throw new BusinessException(HttpStatus.FORBIDDEN, "TEAM_REQUIRED",
                user.getRole() == com.crm.realestate.enums.Role.MANAGER
                        ? "Create your team first"
                        : "You are not in a team yet");
    }

    /**
     * The signed-in user, from the token's principal when the filter chain put one there and from
     * the database otherwise — the latter is how tests that set a bare authentication still work.
     */
    private User currentUser(Authentication authentication) {
        if (authentication.getPrincipal() instanceof User user) {
            return user;
        }
        try {
            return securityUtils.getCurrentUser();
        } catch (RuntimeException e) {
            return null;
        }
    }
}
