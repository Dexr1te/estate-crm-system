package com.crm.realestate.controller;

import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.util.Optional;

import com.crm.realestate.entity.User;
import com.crm.realestate.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * The page a password-reset link opens, mirroring {@link InviteLandingController}.
 *
 * <p>Same reasoning: a link in an email cannot open the app directly until Universal Links are
 * verified for the domain, so this page validates the token server-side and then offers both ways
 * in — the custom scheme, and the code to type if the button does nothing.
 *
 * <p>Read-only on purpose. It says whether the token is still usable and never spends it; the
 * password is set through {@code POST /auth/reset-password}.
 */
@RestController
@RequestMapping("/reset")
@RequiredArgsConstructor
public class ResetLandingController {

    private final UserRepository userRepository;

    @Value("${app.reset-deep-link:estatecrm://reset-password}")
    private String deepLink;

    @GetMapping(produces = MediaType.TEXT_HTML_VALUE)
    public ResponseEntity<String> landing(@RequestParam(required = false) String token) {
        Optional<User> user = (token == null || token.isBlank())
                ? Optional.empty()
                : userRepository.findByPasswordResetToken(token);

        boolean expired = user
                .map(u -> u.getPasswordResetTokenExpiresAt() != null
                        && u.getPasswordResetTokenExpiresAt().isBefore(LocalDateTime.now()))
                .orElse(false);

        String body;
        if (user.isEmpty()) {
            body = page("This reset link is not valid",
                    "The link may have been mistyped, or it has already been used. "
                            + "Ask for a new one from the sign-in screen.",
                    null, null);
        } else if (expired) {
            body = page("This reset link has expired",
                    "Reset links are valid for 24 hours. Ask for a new one from the sign-in "
                            + "screen.",
                    null, null);
        } else {
            body = page("Choose a new password",
                    "Open the app to set it. If the button does nothing, enter the code below "
                            + "on the sign-in screen under \"Forgot password?\".",
                    deepLink + "?token=" + token, token);
        }

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE,
                        MediaType.TEXT_HTML_VALUE + ";charset=" + StandardCharsets.UTF_8.name())
                // The token is in the URL, so keep this out of shared caches.
                .header(HttpHeaders.CACHE_CONTROL, "no-store")
                .body(body);
    }

    private String page(String title, String message, String action, String code) {
        String button = action == null ? "" : """
                <a href="%s" style="display:inline-block;background:#0F1E3C;color:#FFFFFF;
                   text-decoration:none;font-size:15px;font-weight:600;padding:15px 24px;
                   border-radius:12px;margin-top:4px;">Open in the app</a>
                """.formatted(escape(action));

        String codeBlock = code == null ? "" : """
                <p style="font-size:12.5px;color:#6B7A99;margin:22px 0 6px;">Reset code</p>
                <div style="font-family:ui-monospace,SFMono-Regular,Menlo,monospace;font-size:13px;
                            color:#0F1E3C;background:#EEF1F8;border-radius:10px;padding:12px 14px;
                            word-break:break-all;">%s</div>
                """.formatted(escape(code));

        return """
                <!doctype html>
                <html lang="en">
                  <head>
                    <meta charset="utf-8">
                    <meta name="viewport" content="width=device-width,initial-scale=1">
                    <title>Estate CRM password reset</title>
                  </head>
                  <body style="margin:0;padding:24px;background:#F4F6FB;
                               font-family:-apple-system,Segoe UI,Roboto,Helvetica,Arial,sans-serif;">
                    <div style="max-width:420px;margin:40px auto;background:#FFFFFF;
                                border:1px solid #E8ECF4;border-radius:16px;padding:28px;">
                      <div style="font-size:20px;font-weight:700;color:#0F1E3C;">EstateCRM</div>
                      <h1 style="font-size:18px;font-weight:700;color:#0F1E3C;margin:20px 0 8px;">%s</h1>
                      <p style="font-size:13.5px;line-height:1.5;color:#6B7A99;margin:0 0 20px;">%s</p>
                      %s
                      %s
                    </div>
                  </body>
                </html>
                """.formatted(escape(title), escape(message), button, codeBlock);
    }

    private String escape(String value) {
        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;");
    }
}
