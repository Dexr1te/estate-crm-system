package com.crm.realestate.service;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.Arrays;
import java.util.List;
import java.util.stream.IntStream;

import static org.assertj.core.api.Assertions.assertThat;

class ClientTagsTest {

    @Test
    @DisplayName("a tag is trimmed, its inner spaces collapsed and a leading # dropped")
    void display() {
        assertThat(ClientTags.display("  new   build ")).isEqualTo("new build");
        assertThat(ClientTags.display("#VIP")).isEqualTo("VIP");
        assertThat(ClientTags.display("## ипотека одобрена")).isEqualTo("ипотека одобрена");
        assertThat(ClientTags.display("   ")).isNull();
        assertThat(ClientTags.display("#")).isNull();
        assertThat(ClientTags.display(null)).isNull();
    }

    @Test
    @DisplayName("the same word in another case is the same tag, and the first spelling is kept")
    void caseInsensitiveFirstSpellingWins() {
        assertThat(ClientTags.normalise(List.of("VIP", "vip", " Vip ", "Инвестор", "ИНВЕСТОР")))
                .containsExactly("VIP", "Инвестор");
        assertThat(ClientTags.key("Инвестор")).isEqualTo(ClientTags.key("иНВЕСТОР"));
    }

    @Test
    @DisplayName("commas and semicolons separate tags; blanks and nulls are dropped")
    void separators() {
        assertThat(ClientTags.normalise(Arrays.asList("investor, urgent", null, "", "urgent;#Қала")))
                .containsExactly("investor", "urgent", "Қала");
        assertThat(ClientTags.normalise(null)).isEmpty();
    }

    @Test
    @DisplayName("32 characters fit, 33 do not; ten tags fit, eleven do not")
    void limits() {
        assertThat(ClientTags.violation(List.of("x".repeat(32)))).isNull();
        assertThat(ClientTags.violation(List.of("x".repeat(33)))).isEqualTo(ClientTags.TOO_LONG);
        assertThat(ClientTags.violation(List.of("ж".repeat(32)))).as("letters, not bytes").isNull();

        List<String> ten = IntStream.range(0, 10).mapToObj(i -> "t" + i).toList();
        assertThat(ClientTags.violation(ten)).isNull();
        List<String> eleven = IntStream.range(0, 11).mapToObj(i -> "t" + i).toList();
        assertThat(ClientTags.violation(eleven)).isEqualTo(ClientTags.TOO_MANY);
        assertThat(ClientTags.violation(ClientTags.normalise(
                IntStream.range(0, 11).mapToObj(i -> "Same").toList())))
                .as("repeats count once").isNull();
    }
}
