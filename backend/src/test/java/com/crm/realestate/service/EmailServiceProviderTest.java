package com.crm.realestate.service;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.test.util.ReflectionTestUtils;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.contains;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;

/** Which way a message leaves, and whether a failure there is reported as one. */
class EmailServiceProviderTest {

    private final JavaMailSender smtp = mock(JavaMailSender.class);
    private final BrevoMailClient brevo = mock(BrevoMailClient.class);

    private EmailService service(String provider) {
        EmailService service = new EmailService(smtp, brevo);
        ReflectionTestUtils.setField(service, "enabled", true);
        ReflectionTestUtils.setField(service, "provider", provider);
        ReflectionTestUtils.setField(service, "from", "owner@gmail.com");
        ReflectionTestUtils.setField(service, "fromName", "Estate CRM");
        return service;
    }

    @Test
    @DisplayName("with provider=brevo a sign-up code goes through Brevo, not SMTP")
    void codeGoesThroughBrevo() {
        boolean sent = service("brevo").sendVerificationCode("irina@example.kz", "Irina", "123456");

        assertThat(sent).isTrue();
        verify(brevo).send(eq("owner@gmail.com"), eq("Estate CRM"), eq("irina@example.kz"),
                contains("123456"), contains("123456"), contains("123456"));
        verifyNoInteractions(smtp);
    }

    @Test
    @DisplayName("a code Brevo refuses is reported as not sent")
    void brevoFailureIsNotSent() {
        doThrow(new IllegalStateException("401")).when(brevo)
                .send(anyString(), anyString(), anyString(), anyString(), anyString(), anyString());

        boolean sent = service("brevo").sendVerificationCode("irina@example.kz", "Irina", "123456");

        assertThat(sent).isFalse();
    }

    @Test
    @DisplayName("the default stays SMTP and never touches Brevo")
    void defaultIsSmtp() {
        // The mocked sender hands back no message, so the SMTP path fails here — what matters is
        // that it was the one tried.
        boolean sent = service("smtp").sendVerificationCode("irina@example.kz", "Irina", "123456");

        assertThat(sent).isFalse();
        verify(smtp).createMimeMessage();
        verifyNoInteractions(brevo);
    }
}
