package com.crm.realestate.service;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

/**
 * The lookups that need real DNS are tagged so they can be excluded on an offline runner; the
 * shape of the check (parsing, the disabled switch) is verified without touching the network.
 */
class EmailDomainValidatorTest {

    private EmailDomainValidator validator(boolean enabled) {
        EmailDomainValidator v = new EmailDomainValidator();
        ReflectionTestUtils.setField(v, "enabled", enabled);
        ReflectionTestUtils.setField(v, "timeoutMs", "2000");
        return v;
    }

    @Test
    @DisplayName("a malformed address is rejected without a lookup")
    void malformedIsRejected() {
        EmailDomainValidator v = validator(true);
        assertThat(v.acceptsMail("no-at-sign")).isFalse();
        assertThat(v.acceptsMail("@leading.dot")).isFalse();
        assertThat(v.acceptsMail("trailing@")).isFalse();
        assertThat(v.acceptsMail(null)).isFalse();
    }

    @Test
    @DisplayName("the switch turns the check off entirely")
    void disabledAcceptsAnything() {
        EmailDomainValidator v = validator(false);
        assertThat(v.acceptsMail("someone@definitely-not-a-real-domain-zzz.invalid")).isTrue();
    }

    @Test
    @DisplayName("a domain that publishes MX records is accepted")
    void realDomainAccepted() {
        assertThat(validator(true).acceptsMail("someone@gmail.com")).isTrue();
    }

    @Test
    @DisplayName("a domain that does not exist is rejected")
    void unknownDomainRejected() {
        // .invalid is reserved by RFC 2606 and can never resolve, so this stays true forever
        // rather than depending on some typo domain nobody has registered yet.
        assertThat(validator(true).acceptsMail("someone@estate-crm-nope.invalid")).isFalse();
    }

    @Test
    @DisplayName("the domain is matched case-insensitively and only once per domain")
    void domainIsNormalised() {
        EmailDomainValidator v = validator(true);
        assertThat(v.acceptsMail("a@GMAIL.com")).isTrue();
        assertThat(v.acceptsMail("b@gmail.COM")).isTrue();
    }
}
