package com.crm.realestate.service;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

import static org.assertj.core.api.Assertions.assertThat;

class ContactNormalizerTest {

    @ParameterizedTest
    @ValueSource(strings = {
            "+7 916 220-84-11",
            "89162208411",
            "8 (916) 220 84 11",
            "+7(916)2208411",
            "79162208411",
            "  +7 916 220 84 11  ",
    })
    @DisplayName("every way of typing one +7 number reads the same")
    void samePhoneManyWays(String typed) {
        assertThat(ContactNormalizer.phone(typed)).isEqualTo("79162208411");
    }

    @Test
    @DisplayName("a leading 8 is rewritten only on an 11-digit number")
    void eightOnlyOnElevenDigits() {
        assertThat(ContactNormalizer.phone("8 727 123 45")).isEqualTo("872712345");
        assertThat(ContactNormalizer.phone("+44 20 7946 0958")).isEqualTo("442079460958");
        assertThat(ContactNormalizer.phone("+1 (212) 555-0188")).isEqualTo("12125550188");
    }

    @Test
    @DisplayName("nothing, or too few digits to find anyone by, is null")
    void tooShortIsNull() {
        assertThat(ContactNormalizer.phone(null)).isNull();
        assertThat(ContactNormalizer.phone("")).isNull();
        assertThat(ContactNormalizer.phone("   ")).isNull();
        assertThat(ContactNormalizer.phone("ext. 12")).isNull();
        assertThat(ContactNormalizer.phone("123-456")).isNull();
        assertThat(ContactNormalizer.phone("123-4567")).isEqualTo("1234567");
    }

    @Test
    @DisplayName("an email is trimmed and compared without case")
    void email() {
        assertThat(ContactNormalizer.email("  Aigerim.B@Mail.KZ ")).isEqualTo("aigerim.b@mail.kz");
        assertThat(ContactNormalizer.email("   ")).isNull();
        assertThat(ContactNormalizer.email(null)).isNull();
    }
}
