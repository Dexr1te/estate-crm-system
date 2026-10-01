package com.crm.realestate.service;

import com.crm.realestate.exception.BusinessException;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class ClientBirthdayTest {

    private static final LocalDate TODAY = LocalDate.of(2026, 10, 1);

    @Test
    @DisplayName("the API's two forms read and write back the same")
    void isoForms() {
        assertThat(ClientBirthday.parse("1990-05-14", TODAY).format()).isEqualTo("1990-05-14");
        assertThat(ClientBirthday.parse(" --02-29 ", TODAY).format()).isEqualTo("--02-29");
        assertThat(ClientBirthday.parse("", TODAY)).isNull();
        assertThatThrownBy(() -> ClientBirthday.parse("2026-10-02", TODAY))
                .isInstanceOf(BusinessException.class);
        assertThat(ClientBirthday.parse("2026-10-01", TODAY).year()).isEqualTo(2026);
    }

    @Test
    @DisplayName("a spreadsheet cell may be day first, with dots or slashes, with or without a year or a time")
    void spreadsheetCells() {
        assertThat(ClientBirthday.read("14.05.1990", TODAY).format()).isEqualTo("1990-05-14");
        assertThat(ClientBirthday.read("14.05", TODAY).format()).isEqualTo("--05-14");
        assertThat(ClientBirthday.read("3/7/1985", TODAY).format()).isEqualTo("1985-07-03");
        assertThat(ClientBirthday.read("1990-05-14 00:00", TODAY).format()).isEqualTo("1990-05-14");
        assertThat(ClientBirthday.read("--05-14", TODAY).format()).isEqualTo("--05-14");
        assertThat(ClientBirthday.read("31.02", TODAY)).isNull();
        assertThat(ClientBirthday.read("29.02.1990", TODAY)).isNull();
        assertThat(ClientBirthday.read("May 14", TODAY)).isNull();
    }

    @Test
    @DisplayName("29 February falls on the 28th in a common year")
    void leapDay() {
        assertThat(ClientBirthday.inYear(2, 29, 2027)).isEqualTo(LocalDate.of(2027, 2, 28));
        assertThat(ClientBirthday.inYear(2, 29, 2028)).isEqualTo(LocalDate.of(2028, 2, 29));
        assertThat(ClientBirthday.inYear(3, 1, 2027)).isEqualTo(LocalDate.of(2027, 3, 1));
    }
}
