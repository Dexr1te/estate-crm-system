package com.crm.realestate.service.exports;

import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

/**
 * Records written as a spreadsheet opens them: UTF-8 with a byte-order mark (so Excel shows
 * Cyrillic as letters), CRLF between records, and RFC 4180 quoting — a field holding the
 * delimiter, a quote or a line break is wrapped in quotes, and its quotes are doubled.
 *
 * <p>Numbers carry no thousands separators. With semicolons the decimal point is a comma, which is
 * what Excel in a Russian or Kazakh locale expects and what the importer reads back.
 */
public final class CsvWriter {

    static final DateTimeFormatter DATE_TIME = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    private final Writer out;
    private final char delimiter;

    public CsvWriter(OutputStream stream, char delimiter) throws IOException {
        stream.write(new byte[]{(byte) 0xEF, (byte) 0xBB, (byte) 0xBF});
        this.out = new OutputStreamWriter(stream, StandardCharsets.UTF_8);
        this.delimiter = delimiter;
    }

    public void row(List<String> cells) throws IOException {
        for (int i = 0; i < cells.size(); i++) {
            if (i > 0) {
                out.write(delimiter);
            }
            out.write(quote(cells.get(i)));
        }
        out.write("\r\n");
    }

    public void flush() throws IOException {
        out.flush();
    }

    String quote(String value) {
        if (value == null || value.isEmpty()) {
            return "";
        }
        boolean needs = value.indexOf(delimiter) >= 0 || value.indexOf('"') >= 0
                || value.indexOf('\n') >= 0 || value.indexOf('\r') >= 0;
        return needs ? '"' + value.replace("\"", "\"\"") + '"' : value;
    }

    /** A plain number, with a comma for its decimal point when the delimiter is a semicolon. */
    public String decimal(BigDecimal value) {
        if (value == null) {
            return "";
        }
        String plain = value.stripTrailingZeros().toPlainString();
        return delimiter == ';' ? plain.replace('.', ',') : plain;
    }

    public String decimal(Double value) {
        return value == null ? "" : decimal(BigDecimal.valueOf(value));
    }

    public static String whole(Number value) {
        return value == null ? "" : value.toString();
    }

    public static String date(LocalDateTime value) {
        return value == null ? "" : value.format(DATE_TIME);
    }
}
