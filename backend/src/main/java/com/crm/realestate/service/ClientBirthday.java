package com.crm.realestate.service;

import com.crm.realestate.entity.Client;
import com.crm.realestate.exception.BusinessException;
import org.springframework.http.HttpStatus;

import java.time.LocalDate;
import java.time.Month;
import java.time.Year;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * A client's birthday: a day and a month, and the year only when somebody knows it.
 *
 * <p>Over the wire it is ISO 8601: {@code 1990-05-14}, or {@code --05-14} when the year is not
 * known. The same text goes out in the export and is read back by the import.
 *
 * <p>The 29th of February is a real birthday and is kept as typed. In a year without one it is
 * marked on the 28th — see {@link #inYear}. A purchase made on the 29th is treated the same way.
 */
public record ClientBirthday(int month, int day, Integer year) {

    public static final String INVALID = "INVALID_BIRTHDAY";

    /** The earliest birth year accepted; anything before it is a typing mistake. */
    static final int MIN_YEAR = 1900;

    private static final Pattern FULL = Pattern.compile("(\\d{4})-(\\d{2})-(\\d{2})");
    private static final Pattern NO_YEAR = Pattern.compile("--(\\d{2})-(\\d{2})");

    /** The client's, or null when none is recorded. */
    public static ClientBirthday of(Client client) {
        if (client.getBirthMonth() == null || client.getBirthDay() == null) {
            return null;
        }
        return new ClientBirthday(client.getBirthMonth(), client.getBirthDay(), client.getBirthYear());
    }

    /**
     * Reads the API's text. Blank means "no birthday", and returns null; anything that is not a
     * real day of the year — or, with a year, a real date that is not in the future — is refused
     * with {@link #INVALID}.
     */
    public static ClientBirthday parse(String text, LocalDate today) {
        if (text == null || text.isBlank()) {
            return null;
        }
        String value = text.strip();
        Matcher full = FULL.matcher(value);
        Matcher noYear = NO_YEAR.matcher(value);
        ClientBirthday birthday;
        if (full.matches()) {
            birthday = new ClientBirthday(Integer.parseInt(full.group(2)), Integer.parseInt(full.group(3)),
                    Integer.parseInt(full.group(1)));
        } else if (noYear.matches()) {
            birthday = new ClientBirthday(Integer.parseInt(noYear.group(1)), Integer.parseInt(noYear.group(2)), null);
        } else {
            throw invalid("Birthday must be YYYY-MM-DD, or --MM-DD when the year is not known");
        }
        String problem = birthday.problem(today);
        if (problem != null) {
            throw invalid(problem);
        }
        return birthday;
    }

    private static final Pattern DOTTED = Pattern.compile("(\\d{1,2})[./](\\d{1,2})(?:[./](\\d{4}))?");

    /**
     * A spreadsheet cell, as people type a birthday or as a spreadsheet writes one back: the API's
     * own {@code 1990-05-14} and {@code --05-14}, or day first, {@code 14.05.1990}, {@code 14.05},
     * {@code 14/05/1990}. A time after the date, which a spreadsheet may add, is ignored. Null
     * when the cell is not a birthday.
     */
    public static ClientBirthday read(String cell, LocalDate today) {
        if (cell == null || cell.isBlank()) {
            return null;
        }
        String value = cell.strip().split("[\\sT]", 2)[0];
        Matcher dotted = DOTTED.matcher(value);
        if (dotted.matches()) {
            ClientBirthday birthday = new ClientBirthday(Integer.parseInt(dotted.group(2)),
                    Integer.parseInt(dotted.group(1)),
                    dotted.group(3) == null ? null : Integer.parseInt(dotted.group(3)));
            return birthday.problem(today) == null ? birthday : null;
        }
        try {
            return parse(value, today);
        } catch (BusinessException e) {
            return null;
        }
    }

    /** Why these numbers are not a birthday, or null when they are one. */
    public String problem(LocalDate today) {
        if (month < 1 || month > 12) {
            return "Birthday month must be between 1 and 12";
        }
        if (day < 1 || day > Month.of(month).maxLength()) {
            return "Birthday day does not exist in that month";
        }
        if (year != null) {
            if (year < MIN_YEAR) {
                return "Birth year must be " + MIN_YEAR + " or later";
            }
            if (day == 29 && month == 2 && !Year.isLeap(year)) {
                return "There was no 29 February in " + year;
            }
            if (LocalDate.of(year, month, day).isAfter(today)) {
                return "Birthday cannot be in the future";
            }
        }
        return null;
    }

    public void applyTo(Client client) {
        client.setBirthMonth(month);
        client.setBirthDay(day);
        client.setBirthYear(year);
    }

    public static void clear(Client client) {
        client.setBirthMonth(null);
        client.setBirthDay(null);
        client.setBirthYear(null);
    }

    /** {@code 1990-05-14}, or {@code --05-14} without a year. */
    public String format() {
        String monthDay = String.format("%02d-%02d", month, day);
        return year == null ? "--" + monthDay : String.format("%04d-", year) + monthDay;
    }

    /** The client's birthday as the API writes it, or null. */
    public static String format(Client client) {
        ClientBirthday birthday = of(client);
        return birthday == null ? null : birthday.format();
    }

    /** The day it falls on in {@code year}; the 29th of February is the 28th in a common year. */
    public LocalDate inYear(int year) {
        return inYear(month, day, year);
    }

    /** {@link #inYear(int)} for any day of the year, a purchase date's included. */
    public static LocalDate inYear(int month, int day, int year) {
        if (month == 2 && day == 29 && !Year.isLeap(year)) {
            return LocalDate.of(year, 2, 28);
        }
        return LocalDate.of(year, month, day);
    }

    private static BusinessException invalid(String message) {
        return new BusinessException(HttpStatus.BAD_REQUEST, INVALID, message);
    }
}
