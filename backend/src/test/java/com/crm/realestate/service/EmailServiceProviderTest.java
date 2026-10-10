package com.crm.realestate.service;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.test.util.ReflectionTestUtils;

import static org.assertj.core.api.Assertions.assertThatCode;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.contains;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;

/** Which way a message leaves, and that a failure there stays inside the mail service. */
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

    private void sendTeamRequest(EmailService service) {
        service.sendTeamRequest("irina@example.kz", "Irina", "Almaty Realty", "Aigerim");
    }

    @Test
    @DisplayName("with provider=brevo a message goes through Brevo, not SMTP")
    void mailGoesThroughBrevo() {
        sendTeamRequest(service("brevo"));

        verify(brevo).send(eq("owner@gmail.com"), eq("Estate CRM"), eq("irina@example.kz"),
                contains("Almaty Realty"), contains("Almaty Realty"), contains("Almaty Realty"));
        verifyNoInteractions(smtp);
    }

    @Test
    @DisplayName("a message Brevo refuses never breaks the action that sent it")
    void brevoFailureIsSwallowed() {
        doThrow(new IllegalStateException("401")).when(brevo)
                .send(anyString(), anyString(), anyString(), anyString(), anyString(), anyString());

        assertThatCode(() -> sendTeamRequest(service("brevo"))).doesNotThrowAnyException();
    }

    @Test
    @DisplayName("the default stays SMTP and never touches Brevo")
    void defaultIsSmtp() {
        // The mocked sender hands back no message, so the SMTP path fails here — what matters is
        // that it was the one tried.
        sendTeamRequest(service("smtp"));

        verify(smtp).createMimeMessage();
        verifyNoInteractions(brevo);
    }
}
