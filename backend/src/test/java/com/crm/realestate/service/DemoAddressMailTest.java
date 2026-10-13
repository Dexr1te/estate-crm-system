package com.crm.realestate.service;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.test.util.ReflectionTestUtils;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verifyNoInteractions;

class DemoAddressMailTest {

    private final JavaMailSender smtp = mock(JavaMailSender.class);
    private final BrevoMailClient brevo = mock(BrevoMailClient.class);

    private EmailService service(String provider) {
        EmailService service = new EmailService(smtp, brevo);
        ReflectionTestUtils.setField(service, "enabled", true);
        ReflectionTestUtils.setField(service, "provider", provider);
        ReflectionTestUtils.setField(service, "from", "owner@gmail.com");
        ReflectionTestUtils.setField(service, "fromName", "Estate CRM");
        ReflectionTestUtils.setField(service, "inviteUrl", "https://example.com/api/invite");
        ReflectionTestUtils.setField(service, "resetUrl", "https://example.com/api/reset");
        return service;
    }

    @ParameterizedTest
    @ValueSource(strings = {"smtp", "brevo"})
    @DisplayName("nothing is ever mailed to a demo address, whatever the provider")
    void demoAddressesGetNoMail(String provider) {
        EmailService service = service(provider);
        String demo = "demo-0123456789abcdef01234567@demo.estatecrm.app";

        service.sendInvite(demo, "Demo Agent", "token");
        service.sendPasswordReset(demo, "Demo Agent", "token");
        service.sendTeamRequest(demo, "Demo Agent", "Almaty Realty", "Aigerim");
        service.sendPasswordReset("Reviewer@Demo.EstateCRM.app ", "App Review", "token");

        verifyNoInteractions(smtp, brevo);
    }
}
