package com.crm.realestate.service.imports;

import java.nio.ByteBuffer;
import java.nio.charset.CharacterCodingException;
import java.nio.charset.Charset;
import java.nio.charset.CodingErrorAction;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

/**
 * A spreadsheet saved as CSV, read the way the person who saved it meant it.
 *
 * <p><b>Encoding.</b> A byte-order mark decides it when there is one (UTF-8, or UTF-16 from
 * Excel's "Unicode text"). Without one the bytes are tried as strict UTF-8; anything that is not
 * valid UTF-8 is read as Windows-1251, which is what Excel in a Russian or Kazakh locale writes.
 * Valid UTF-8 is very unlikely to be Cyrillic 1251 by accident: 1251 letters are single high bytes,
 * and UTF-8 never has a lone high byte.
 *
 * <p><b>Delimiter.</b> Comma, semicolon or tab — whichever occurs most in the header line outside
 * quotes. Excel in RU/KZ locales saves semicolons, because the comma is the decimal separator
 * there. On a tie the semicolon wins, for the same reason.
 *
 * <p><b>Records.</b> RFC 4180: a quoted field may hold the delimiter, a line break, and a doubled
 * quote. Lines may end in CRLF, LF or CR. A record with nothing in it is skipped but still counted,
 * so the row numbers reported back match the row numbers in the spreadsheet.
 */
public final class CsvTable {

    public static final Charset WINDOWS_1251 = Charset.forName("windows-1251");

    /** How the file was decoded, as reported back to the person importing it. */
    public enum Encoding { UTF_8, UTF_8_BOM, UTF_16, WINDOWS_1251 }

    /** One data record and the spreadsheet row it came from (the header is row 1). */
    public record Row(int number, List<String> cells) {
        public String cell(int column) {
            return column < cells.size() ? cells.get(column) : "";
        }
    }

    /** Thrown once the file holds more data rows than an import accepts. */
    public static final class TooManyRowsException extends RuntimeException {
        public TooManyRowsException(int limit) {
            super("More than " + limit + " rows");
        }
    }

    private final Encoding encoding;
    private final char delimiter;
    private final List<String> headers;
    private final List<Row> rows;

    private CsvTable(Encoding encoding, char delimiter, List<String> headers, List<Row> rows) {
        this.encoding = encoding;
        this.delimiter = delimiter;
        this.headers = headers;
        this.rows = rows;
    }

    public Encoding encoding() {
        return encoding;
    }

    public char delimiter() {
        return delimiter;
    }

    public List<String> headers() {
        return headers;
    }

    public List<Row> rows() {
        return rows;
    }

    /** Reads the file; more than {@code maxRows} data rows throws {@link TooManyRowsException}. */
    public static CsvTable parse(byte[] bytes, int maxRows) {
        Decoded decoded = decode(bytes);
        String text = decoded.text();
        char delimiter = detectDelimiter(text);
        List<String> headers = null;
        List<Row> rows = new ArrayList<>();
        Reader reader = new Reader(text, delimiter);
        int number = 0;
        List<String> record;
        while ((record = reader.next()) != null) {
            number++;
            if (isBlank(record)) {
                continue;
            }
            if (headers == null) {
                headers = record.stream().map(String::strip).toList();
                continue;
            }
            if (rows.size() == maxRows) {
                throw new TooManyRowsException(maxRows);
            }
            rows.add(new Row(number, record));
        }
        return new CsvTable(decoded.encoding(), delimiter, headers == null ? List.of() : headers, rows);
    }

    record Decoded(String text, Encoding encoding) {
    }

    static Decoded decode(byte[] bytes) {
        if (startsWith(bytes, 0xEF, 0xBB, 0xBF)) {
            return new Decoded(new String(bytes, 3, bytes.length - 3, StandardCharsets.UTF_8), Encoding.UTF_8_BOM);
        }
        if (startsWith(bytes, 0xFF, 0xFE)) {
            return new Decoded(new String(bytes, 2, bytes.length - 2, StandardCharsets.UTF_16LE), Encoding.UTF_16);
        }
        if (startsWith(bytes, 0xFE, 0xFF)) {
            return new Decoded(new String(bytes, 2, bytes.length - 2, StandardCharsets.UTF_16BE), Encoding.UTF_16);
        }
        try {
            String text = StandardCharsets.UTF_8.newDecoder()
                    .onMalformedInput(CodingErrorAction.REPORT)
                    .onUnmappableCharacter(CodingErrorAction.REPORT)
                    .decode(ByteBuffer.wrap(bytes))
                    .toString();
            return new Decoded(text, Encoding.UTF_8);
        } catch (CharacterCodingException notUtf8) {
            return new Decoded(new String(bytes, WINDOWS_1251), Encoding.WINDOWS_1251);
        }
    }

    private static boolean startsWith(byte[] bytes, int... prefix) {
        if (bytes.length < prefix.length) {
            return false;
        }
        for (int i = 0; i < prefix.length; i++) {
            if ((bytes[i] & 0xFF) != prefix[i]) {
                return false;
            }
        }
        return true;
    }

    /** Counts each candidate outside quotes on the first non-empty line. */
    static char detectDelimiter(String text) {
        int semicolons = 0;
        int commas = 0;
        int tabs = 0;
        boolean quoted = false;
        boolean seenContent = false;
        for (int i = 0; i < text.length(); i++) {
            char c = text.charAt(i);
            if (c == '"') {
                quoted = !quoted;
            } else if (!quoted && (c == '\n' || c == '\r')) {
                if (seenContent) {
                    break;
                }
            } else if (!quoted) {
                if (c == ';') semicolons++;
                else if (c == ',') commas++;
                else if (c == '\t') tabs++;
            }
            if (!Character.isWhitespace(c)) {
                seenContent = true;
            }
        }
        if (semicolons >= commas && semicolons >= tabs && semicolons > 0) return ';';
        if (tabs >= commas && tabs > 0) return '\t';
        return ',';
    }

    private static boolean isBlank(List<String> record) {
        return record.stream().allMatch(String::isBlank);
    }

    /** RFC 4180 records, one at a time. */
    private static final class Reader {
        private final String text;
        private final char delimiter;
        private int pos;

        Reader(String text, char delimiter) {
            this.text = text;
            this.delimiter = delimiter;
        }

        List<String> next() {
            if (pos >= text.length()) {
                return null;
            }
            List<String> cells = new ArrayList<>();
            StringBuilder cell = new StringBuilder();
            boolean quoted = false;
            while (pos < text.length()) {
                char c = text.charAt(pos++);
                if (quoted) {
                    if (c == '"') {
                        if (pos < text.length() && text.charAt(pos) == '"') {
                            cell.append('"');
                            pos++;
                        } else {
                            quoted = false;
                        }
                    } else {
                        cell.append(c);
                    }
                } else if (c == '"' && cell.toString().isBlank()) {
                    // An opening quote, possibly after stray spaces that Excel never writes.
                    cell.setLength(0);
                    quoted = true;
                } else if (c == delimiter) {
                    cells.add(cell.toString());
                    cell.setLength(0);
                } else if (c == '\r' || c == '\n') {
                    if (c == '\r' && pos < text.length() && text.charAt(pos) == '\n') {
                        pos++;
                    }
                    cells.add(cell.toString());
                    return cells;
                } else {
                    cell.append(c);
                }
            }
            cells.add(cell.toString());
            return cells;
        }
    }
}
