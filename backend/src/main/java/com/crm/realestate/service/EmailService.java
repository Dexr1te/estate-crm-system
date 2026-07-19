package com.crm.realestate.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

/**
 * Sends transactional emails (currently invite codes).
 *
 * <p>Every send is asynchronous and swallows its own exceptions: the admin/manager
 * already receives the invite code in the API response, so a mail failure (bad
 * SMTP creds, network, etc.) must never break invite creation. When
 * {@code app.mail.enabled} is false the service is a no-op, so the app runs fine
 * with no SMTP configured.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class EmailService {

    private final JavaMailSender mailSender;

    @Value("${app.mail.enabled:false}")
    private boolean enabled;

    @Value("${app.mail.from:no-reply@estatecrm.app}")
    private String from;

    @Async
    public void sendInvite(String toEmail, String fullName, String inviteToken) {
        if (!enabled) {
            log.info("Mail disabled (app.mail.enabled=false); skipping invite email to {}", toEmail);
            return;
        }
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setFrom(from);
            message.setTo(toEmail);
            message.setSubject("You've been invited to Estate CRM");
            message.setText(buildInviteBody(fullName, inviteToken));
            mailSender.send(message);
            log.info("Invite email sent to {}", toEmail);
        } catch (Exception e) {
            log.error("Failed to send invite email to {}: {}", toEmail, e.getMessage());
        }
    }

    private String buildInviteBody(String fullName, String inviteToken) {
        String name = (fullName == null || fullName.isBlank()) ? "there" : fullName;
        return "Hi " + name + ",\n\n"
                + "You've been invited to Estate CRM.\n\n"
                + "To finish setting up your account:\n"
                + "  1. Open the Estate CRM app.\n"
                + "  2. On the login screen, tap \"Have an invite?\".\n"
                + "  3. Paste this invite code and choose your password:\n\n"
                + "     " + inviteToken + "\n\n"
                + "This code expires in 48 hours.\n\n"
                + "— Estate CRM";
    }
}
