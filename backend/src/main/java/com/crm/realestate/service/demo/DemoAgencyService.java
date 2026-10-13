package com.crm.realestate.service.demo;

import com.crm.realestate.dto.response.AuthResponse;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.security.AuthResponseFactory;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.util.Base64;
import java.util.HexFormat;

@Service
@RequiredArgsConstructor
@Slf4j
public class DemoAgencyService {

    static final String AGENT_NAME = "Demo Agent";

    private final TeamRepository teamRepository;
    private final UserRepository userRepository;
    private final DemoSampleRecords sampleRecords;
    private final DemoRateLimiter rateLimiter;
    private final PasswordEncoder passwordEncoder;
    private final AuthResponseFactory authResponseFactory;
    private final SecureRandom random = new SecureRandom();

    @Value("${app.demo.try-enabled:true}")
    private boolean enabled;

    @Transactional
    public AuthResponse start(String address) {
        if (!enabled) {
            throw new BusinessException(HttpStatus.NOT_FOUND, "DEMO_UNAVAILABLE",
                    "The demo is not available");
        }
        if (!rateLimiter.tryAcquire(address)) {
            throw new BusinessException(HttpStatus.TOO_MANY_REQUESTS, "DEMO_RATE_LIMITED",
                    "Too many demos started. Try again later.");
        }

        String mailbox = DemoAccounts.TRY_MAILBOX_PREFIX + HexFormat.of().formatHex(bytes(12));
        Team team = teamRepository.save(Team.builder().name(DemoAccounts.TEAM_NAME).build());
        User agent = userRepository.save(member(mailbox + DemoAccounts.EMAIL_DOMAIN, AGENT_NAME, team));
        userRepository.save(member(mailbox + "-handover" + DemoAccounts.EMAIL_DOMAIN,
                DemoAccounts.HANDOVER_NAME, team));
        sampleRecords.seed(agent);

        log.info("Started demo agency {} for {}", team.getId(), agent.getEmail());
        return authResponseFactory.withNewTokens(agent);
    }

    private User member(String email, String fullName, Team team) {
        return User.builder()
                .email(email)
                .password(passwordEncoder.encode(Base64.getEncoder().encodeToString(bytes(32))))
                .fullName(fullName)
                .role(Role.AGENT)
                .dataScope(DataScope.OWN)
                .team(team)
                .status(UserStatus.ACTIVE)
                .isActive(true)
                .mustChangePassword(false)
                .build();
    }

    private byte[] bytes(int length) {
        byte[] bytes = new byte[length];
        random.nextBytes(bytes);
        return bytes;
    }
}
