package com.crm.realestate.service;

import java.nio.charset.StandardCharsets;

import jakarta.annotation.PostConstruct;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.web.util.UriComponentsBuilder;

/**
 * Sends transactional emails: invites, password resets, sign-up codes and team requests.
 *
 * <p>Every send is asynchronous and swallows its own exceptions: the admin/manager already receives
 * the invite code in the API response, so a mail failure (bad SMTP creds, network, etc.) must never
 * break invite creation. When {@code app.mail.enabled} is false the service is a no-op, so the app
 * runs fine with no SMTP configured.
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

    /**
     * Where the invite link points. Defaults to the landing page this backend serves; override it
     * to send people at the web app or at a deep link instead, without touching this class.
     */
    @Value("${app.invite-url:${app.base-url:http://localhost:8080}/api/invite}")
    private String inviteUrl;

    /**
     * Where the password-reset link points. Same shape as {@link #inviteUrl}: the landing page this
     * backend serves, overridable without touching this class.
     */
    @Value("${app.reset-url:${app.base-url:http://localhost:8080}/api/reset}")
    private String resetUrl;

    /**
     * Writes sign-up codes to the log while mail is off, so a developer without SMTP can still
     * finish registering. Off by default: a code in a production log is a credential in a log.
     */
    @Value("${app.mail.log-codes:false}")
    private boolean logCodes;

    @Value("${spring.mail.host:}")
    private String host;

    @Value("${spring.mail.username:}")
    private String username;

    /**
     * States the resolved mail configuration once, at boot.
     *
     * <p>Without this the only sign that mail is off is a line printed when somebody happens to
     * click "invite", long after the deploy that broke it — and the usual cause is invisible from
     * inside the container: Compose substitutes {@code .env} into the compose file but does not
     * pass it through to the process unless the service declares {@code env_file}.
     */
    @PostConstruct
    void logConfiguration() {
        if (!enabled) {
            log.warn("Mail is OFF (app.mail.enabled=false) — invite emails will be skipped. "
                    + "If MAIL_ENABLED is set in .env, check that docker-compose actually "
                    + "forwards it into the container (env_file).");
            return;
        }
        if (username == null || username.isBlank()) {
            log.warn("Mail is ON but spring.mail.username is empty — SMTP will reject every send.");
        }
        log.info("Mail is ON — host={}, from={}, invite links point at {}, reset links at {}",
                host, from, inviteUrl, resetUrl);
    }

    @Async
    public void sendInvite(String toEmail, String fullName, String inviteToken) {
        if (!enabled) {
            log.info("Mail disabled (app.mail.enabled=false); skipping invite email to {}", toEmail);
            return;
        }
        String link = UriComponentsBuilder.fromUriString(inviteUrl)
                .queryParam("token", inviteToken)
                .build()
                .toUriString();
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper =
                    new MimeMessageHelper(message, true, StandardCharsets.UTF_8.name());
            helper.setFrom(from);
            helper.setTo(toEmail);
            helper.setSubject("You've been invited to Estate CRM");
            // Both parts, so a client that refuses HTML still shows a usable link and code.
            helper.setText(plainBody(fullName, inviteToken, link),
                    htmlBody(fullName, inviteToken, link));
            mailSender.send(message);
            log.info("Invite email sent to {}", toEmail);
        } catch (Exception e) {
            log.error("Failed to send invite email to {}: {}", toEmail, e.getMessage());
        }
    }

    /**
     * Tells someone how to get back in.
     *
     * <p>Until this existed {@code requestPasswordReset} minted a token, stored it and told nobody,
     * so the only route back into an invite-only app was asking an administrator.
     */
    @Async
    public void sendPasswordReset(String toEmail, String fullName, String resetToken) {
        if (!enabled) {
            log.info("Mail disabled (app.mail.enabled=false); skipping reset email to {}", toEmail);
            return;
        }
        String link = UriComponentsBuilder.fromUriString(resetUrl)
                .queryParam("token", resetToken)
                .build()
                .toUriString();
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper =
                    new MimeMessageHelper(message, true, StandardCharsets.UTF_8.name());
            helper.setFrom(from);
            helper.setTo(toEmail);
            helper.setSubject("Reset your Estate CRM password");
            helper.setText(resetPlainBody(fullName, resetToken, link),
                    resetHtmlBody(fullName, resetToken, link));
            mailSender.send(message);
            log.info("Password reset email sent to {}", toEmail);
        } catch (Exception e) {
            log.error("Failed to send reset email to {}: {}", toEmail, e.getMessage());
        }
    }

    /**
     * The code a new account proves its address with. Six digits, because it is typed from one
     * app into another on the same phone.
     */
    @Async
    public void sendVerificationCode(String toEmail, String fullName, String code) {
        if (!enabled) {
            if (logCodes) {
                log.info("Mail disabled; sign-up code for {} is {}", toEmail, code);
            } else {
                log.info("Mail disabled (app.mail.enabled=false); skipping sign-up code to {}", toEmail);
            }
            return;
        }
        send(toEmail, "Your Estate CRM code: " + code,
                "Hi " + greeting(fullName) + ",\n\n"
                        + "Enter this code in the Estate CRM app to confirm your email:\n\n"
                        + "     " + code + "\n\n"
                        + "It expires in 15 minutes. If you did not sign up, ignore this email.\n\n"
                        + "— Estate CRM",
                card("Hi %s, here is your code.".formatted(escape(greeting(fullName))),
                        "Enter it in the app to confirm your email. It expires in 15 minutes. "
                                + "If you did not sign up, ignore this email.",
                        """
                        <div style="font-family:ui-monospace,SFMono-Regular,Menlo,monospace;
                                    font-size:28px;letter-spacing:8px;font-weight:700;color:#0F1E3C;
                                    background:#EEF1F8;border-radius:12px;padding:16px;
                                    text-align:center;">%s</div>
                        """.formatted(escape(code))),
                "sign-up code");
    }

    /** Tells an agent that a manager wants them in their team. The answer is given in the app. */
    @Async
    public void sendTeamRequest(String toEmail, String fullName, String teamName, String invitedByName) {
        if (!enabled) {
            log.info("Mail disabled (app.mail.enabled=false); skipping team request email to {}", toEmail);
            return;
        }
        String who = invitedByName == null || invitedByName.isBlank() ? "A manager" : invitedByName;
        send(toEmail, who + " invited you to " + teamName + " on Estate CRM",
                "Hi " + greeting(fullName) + ",\n\n"
                        + who + " would like you to join " + teamName + " on Estate CRM.\n\n"
                        + "Open the app to accept or decline. Once you join, the team's manager\n"
                        + "can see the clients and deals you work on there.\n\n"
                        + "— Estate CRM",
                card("Hi %s, %s would like you to join %s.".formatted(
                                escape(greeting(fullName)), escape(who), escape(teamName)),
                        "Open the Estate CRM app to accept or decline. Once you join, the team's "
                                + "manager can see the clients and deals you work on there.",
                        ""),
                "team request");
    }

    private void send(String toEmail, String subject, String plain, String html, String what) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper =
                    new MimeMessageHelper(message, true, StandardCharsets.UTF_8.name());
            helper.setFrom(from);
            helper.setTo(toEmail);
            helper.setSubject(subject);
            helper.setText(plain, html);
            mailSender.send(message);
            log.info("Sent {} email to {}", what, toEmail);
        } catch (Exception e) {
            log.error("Failed to send {} email to {}: {}", what, toEmail, e.getMessage());
        }
    }

    /** The shared letterhead. Arguments are HTML already; escape anything user-supplied first. */
    private String card(String headline, String body, String extra) {
        return """
                <!doctype html>
                <html>
                  <body style="margin:0;padding:24px;background:#F4F6FB;
                               font-family:-apple-system,Segoe UI,Roboto,Helvetica,Arial,sans-serif;">
                    <div style="max-width:480px;margin:0 auto;background:#FFFFFF;
                                border:1px solid #E8ECF4;border-radius:16px;padding:28px;">
                      <div style="font-size:20px;font-weight:700;color:#0F1E3C;">EstateCRM</div>
                      <p style="font-size:14px;line-height:1.5;color:#0F1E3C;margin:20px 0 0;">%s</p>
                      <p style="font-size:13px;line-height:1.5;color:#6B7A99;margin:10px 0 22px;">%s</p>
                      %s
                    </div>
                  </body>
                </html>
                """.formatted(headline, escape(body), extra);
    }

    private String resetPlainBody(String fullName, String token, String link) {
        return "Hi " + greeting(fullName) + ",\n\n"
                + "Someone asked to reset the password for your Estate CRM account.\n\n"
                + "Open this link to choose a new one:\n"
                + link + "\n\n"
                + "If the link does not work, open the Estate CRM app, tap \"Forgot password?\"\n"
                + "and enter this code:\n\n"
                + "     " + token + "\n\n"
                + "The link expires in 24 hours. If this wasn't you, ignore this email —\n"
                + "your password has not changed.\n\n"
                + "— Estate CRM";
    }

    private String resetHtmlBody(String fullName, String token, String link) {
        return """
                <!doctype html>
                <html>
                  <body style="margin:0;padding:24px;background:#F4F6FB;
                               font-family:-apple-system,Segoe UI,Roboto,Helvetica,Arial,sans-serif;">
                    <div style="max-width:480px;margin:0 auto;background:#FFFFFF;
                                border:1px solid #E8ECF4;border-radius:16px;padding:28px;">
                      <div style="font-size:20px;font-weight:700;color:#0F1E3C;">EstateCRM</div>
                      <p style="font-size:14px;line-height:1.5;color:#0F1E3C;margin:20px 0 0;">
                        Hi %s, someone asked to reset your password.
                      </p>
                      <p style="font-size:13px;line-height:1.5;color:#6B7A99;margin:10px 0 22px;">
                        Choose a new one — the link expires in 24 hours. If this wasn't you,
                        ignore this email and nothing changes.
                      </p>
                      <a href="%s" style="display:inline-block;background:#0F1E3C;color:#FFFFFF;
                         text-decoration:none;font-size:14px;font-weight:600;padding:14px 22px;
                         border-radius:12px;">Choose a new password</a>
                      <p style="font-size:12px;line-height:1.5;color:#6B7A99;margin:22px 0 6px;">
                        Or enter this code in the app:
                      </p>
                      <div style="font-family:ui-monospace,SFMono-Regular,Menlo,monospace;
                                  font-size:13px;color:#0F1E3C;background:#EEF1F8;
                                  border-radius:10px;padding:12px 14px;word-break:break-all;">%s</div>
                    </div>
                  </body>
                </html>
                """
                .formatted(escape(greeting(fullName)), escape(link), escape(token));
    }

    private String greeting(String fullName) {
        return (fullName == null || fullName.isBlank()) ? "there" : fullName;
    }

    private String plainBody(String fullName, String token, String link) {
        return "Hi " + greeting(fullName) + ",\n\n"
                + "You've been invited to Estate CRM.\n\n"
                + "Open this link to set your password and sign in:\n"
                + link + "\n\n"
                + "If the link does not work, open the Estate CRM app, tap \"Have an invite?\"\n"
                + "and enter this code:\n\n"
                + "     " + token + "\n\n"
                + "The invite expires in 48 hours.\n\n"
                + "— Estate CRM";
    }

    private String htmlBody(String fullName, String token, String link) {
        return """
                <!doctype html>
                <html>
                  <body style="margin:0;padding:24px;background:#F4F6FB;
                               font-family:-apple-system,Segoe UI,Roboto,Helvetica,Arial,sans-serif;">
                    <div style="max-width:480px;margin:0 auto;background:#FFFFFF;
                                border:1px solid #E8ECF4;border-radius:16px;padding:28px;">
                      <div style="font-size:20px;font-weight:700;color:#0F1E3C;">EstateCRM</div>
                      <p style="font-size:14px;line-height:1.5;color:#0F1E3C;margin:20px 0 0;">
                        Hi %s, you've been invited to Estate CRM.
                      </p>
                      <p style="font-size:13px;line-height:1.5;color:#6B7A99;margin:10px 0 22px;">
                        Set your password and sign in — the invite expires in 48 hours.
                      </p>
                      <a href="%s" style="display:inline-block;background:#0F1E3C;color:#FFFFFF;
                         text-decoration:none;font-size:14px;font-weight:600;padding:14px 22px;
                         border-radius:12px;">Accept the invite</a>
                      <p style="font-size:12px;line-height:1.5;color:#6B7A99;margin:22px 0 6px;">
                        Or enter this code in the app:
                      </p>
                      <div style="font-family:ui-monospace,SFMono-Regular,Menlo,monospace;
                                  font-size:13px;color:#0F1E3C;background:#EEF1F8;
                                  border-radius:10px;padding:12px 14px;word-break:break-all;">%s</div>
                    </div>
                  </body>
                </html>
                """
                .formatted(escape(greeting(fullName)), escape(link), escape(token));
    }

    private String escape(String value) {
        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;");
    }
}
