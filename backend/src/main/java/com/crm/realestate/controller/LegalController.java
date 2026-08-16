package com.crm.realestate.controller;

import java.nio.charset.StandardCharsets;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * The two pages the App Store requires a link to, and the app links to from its profile screen.
 *
 * <p>They are served from here rather than from a marketing site because the app has no other host:
 * App Store Connect needs a privacy policy URL that resolves before review starts, and Guideline
 * 5.1.1(v) wants a route to account help that a reviewer can reach without an account.
 *
 * <p>The privacy text is a working draft written against what the app actually collects. It has not
 * been through a lawyer — read it before you submit, and fill in the operator details below.
 */
@RestController
public class LegalController {

    @Value("${app.support-email:support@estatecrm.app}")
    private String supportEmail;

    @Value("${app.operator-name:EstateCRM}")
    private String operatorName;

    @GetMapping(value = "/privacy", produces = MediaType.TEXT_HTML_VALUE)
    public ResponseEntity<String> privacy() {
        return html(page("Privacy Policy", """
                <p class="meta">Last updated 16 August 2026</p>

                <h2>Who we are</h2>
                <p>EstateCRM is a customer-relationship tool for real-estate agencies, operated by
                %1$s. It is not a consumer product: accounts are created by an agency
                administrator who invites their staff, and there is no public sign-up.</p>

                <h2>What we collect</h2>
                <p><strong>Your account.</strong> Your name, work email, phone number if you give
                one, your role and the team you belong to. This is entered by the administrator who
                invites you, and by you when you accept the invite.</p>
                <p><strong>Work you record in the app.</strong> Clients and their contact details,
                properties, deals, meetings and documents you upload. This is your agency's business
                data. Client records describe people who are not app users, and the agency is the
                controller of that data — we process it on the agency's behalf.</p>
                <p><strong>Operational records.</strong> An audit trail of administrative actions
                (who invited, deactivated or removed whom, and when), kept so an agency can account
                for changes to its own workspace.</p>

                <h2>What we do not do</h2>
                <p>We do not use third-party analytics or advertising SDKs. We do not track you
                across other companies' apps or websites. We do not sell personal data, and we do
                not use your agency's data to train anything.</p>

                <h2>Why we hold it</h2>
                <p>To provide the service you were invited to use: to authenticate you, to show your
                agency's records to the people in your agency who are allowed to see them, and to
                send transactional email such as invites and password resets.</p>

                <h2>How long</h2>
                <p>Your account and its records are kept while your agency's workspace is active.
                Delete your account from the app — Profile, then Delete account — and the account is
                removed; the deals, meetings and documents you were responsible for pass to the
                colleague you nominate, because they belong to the agency rather than to you. Audit
                entries survive the account and stop naming it.</p>

                <h2>Your rights</h2>
                <p>You can see and correct your own details in the app, and delete your account from
                it. For access to, correction of, or deletion of anything else — including data an
                agency holds about you as a client rather than as a user — write to
                <a href="mailto:%2$s">%2$s</a>.</p>

                <h2>Contact</h2>
                <p><a href="mailto:%2$s">%2$s</a></p>
                """.formatted(escape(operatorName), escape(supportEmail))));
    }

    @GetMapping(value = "/support", produces = MediaType.TEXT_HTML_VALUE)
    public ResponseEntity<String> support() {
        return html(page("Support", """
                <h2>Getting in</h2>
                <p>EstateCRM is invite-only. If you do not have an account, ask your agency's
                administrator to invite you — there is no way to create one yourself, by design.
                Lost the invite email? An administrator can resend it from the admin console.</p>
                <p>Forgotten your password? Use “Forgot password” on the sign-in screen.</p>

                <h2>Deleting your account</h2>
                <p>Open the app, go to Profile and choose <strong>Delete account</strong>. You will
                be asked to nominate a colleague to take over any deals, meetings and documents you
                are responsible for; those belong to the agency and cannot be deleted with the
                account. The account itself is removed immediately.</p>
                <p>If you are the only administrator, promote someone else first, or write to us and
                we will help close the workspace.</p>

                <h2>Anything else</h2>
                <p><a href="mailto:%1$s">%1$s</a> — we answer on working days.</p>
                """.formatted(escape(supportEmail))));
    }

    private ResponseEntity<String> html(String body) {
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE,
                        MediaType.TEXT_HTML_VALUE + ";charset=" + StandardCharsets.UTF_8.name())
                .header(HttpHeaders.CACHE_CONTROL, "public, max-age=3600")
                .body(body);
    }

    private String page(String title, String body) {
        return """
                <!doctype html>
                <html lang="en">
                  <head>
                    <meta charset="utf-8">
                    <meta name="viewport" content="width=device-width,initial-scale=1">
                    <title>EstateCRM — %1$s</title>
                    <style>
                      :root { color-scheme: light dark; }
                      body { margin:0; padding:24px; background:#F4F6FB; color:#0F1E3C;
                             font-family:-apple-system,Segoe UI,Roboto,Helvetica,Arial,sans-serif;
                             line-height:1.55; }
                      main { max-width:680px; margin:40px auto; background:#FFFFFF;
                             border:1px solid #E8ECF4; border-radius:16px; padding:32px; }
                      .brand { font-size:20px; font-weight:700; }
                      h1 { font-size:22px; margin:18px 0 4px; }
                      h2 { font-size:15px; margin:26px 0 6px; }
                      p { font-size:14px; margin:0 0 12px; }
                      .meta { color:#6B7A99; font-size:12.5px; }
                      a { color:#0F1E3C; }
                      @media (prefers-color-scheme: dark) {
                        body { background:#0B1220; color:#E8ECF4; }
                        main { background:#141B2D; border-color:#26304A; }
                        .meta { color:#94A3C4; }
                        a { color:#E8B44A; }
                      }
                    </style>
                  </head>
                  <body>
                    <main>
                      <div class="brand">EstateCRM</div>
                      <h1>%1$s</h1>
                      %2$s
                    </main>
                  </body>
                </html>
                """.formatted(escape(title), body);
    }

    private String escape(String value) {
        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;");
    }
}
