package com.crm.realestate.config;

import com.crm.realestate.entity.User;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

/**
 * Gives the deployment its administrator, from configuration rather than from a migration.
 *
 * <p>The admin used to be seeded by {@code V8}, {@code V11} and {@code V12} with the password
 * written into the migration — which meant the password to every deployment of this repository was
 * published with it, on an account whose data scope is every agency at once. {@code V18} retires
 * those, and this puts the account back under whoever runs the host: set {@code ADMIN_PASSWORD}
 * and the named account is created or repaired at boot, with that password.
 *
 * <p>Without {@code ADMIN_PASSWORD} nothing is created and nothing is changed. A deployment that
 * has no administrator at all then says so in the log at every start, because the admin console is
 * the only way to move someone between teams or hand their records on.
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class AdminAccountBootstrap implements ApplicationRunner {

    private final UserRepository  userRepository;
    private final PasswordEncoder passwordEncoder;

    /** Follows {@code app.primary-admin-email} — the account AccountRemovalService protects. */
    @Value("${app.admin.email:${app.primary-admin-email:admin@gmail.com}}")
    private String adminEmail;

    @Value("${app.admin.password:}")
    private String adminPassword;

    @Value("${app.admin.full-name:Admin}")
    private String adminName;

    @Override
    @Transactional
    public void run(ApplicationArguments args) {
        if (adminPassword == null || adminPassword.isBlank()) {
            warnIfNoAdminCanSignIn();
            return;
        }

        User admin = userRepository.findFirstByEmailIgnoreCase(adminEmail.trim())
                .orElseGet(() -> User.builder().email(adminEmail.trim()).fullName(adminName).build());

        boolean created = admin.getId() == null;
        admin.setPassword(passwordEncoder.encode(adminPassword));
        admin.setRole(Role.ADMIN);
        admin.setDataScope(DataScope.ALL);
        admin.setStatus(UserStatus.ACTIVE);
        admin.setActive(true);
        admin.setMustChangePassword(false);
        userRepository.save(admin);

        log.info("{} the administrator {} from app.admin.password.",
                created ? "Created" : "Reset", adminEmail);
    }

    /**
     * Says, once per start, that nobody can reach the admin console.
     *
     * <p>Worth a line of its own: after {@code V18} the published passwords no longer work, so a
     * deployment that never set {@code ADMIN_PASSWORD} loses the console quietly — at the moment a
     * migration runs, not at the moment anyone tries to sign in.
     */
    private void warnIfNoAdminCanSignIn() {
        boolean hasWorkingAdmin = userRepository.findByRoleOrderByFullNameAsc(Role.ADMIN).stream()
                .anyMatch(u -> u.isEnabled() && u.getPassword() != null);
        if (!hasWorkingAdmin) {
            log.error("No administrator can sign in: every ADMIN account is disabled or has no "
                    + "password. Set ADMIN_PASSWORD (and ADMIN_EMAIL, if it is not {}) and "
                    + "restart.", adminEmail);
        }
    }
}
