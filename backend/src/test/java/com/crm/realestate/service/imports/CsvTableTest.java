package com.crm.realestate.service.imports;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.nio.charset.StandardCharsets;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

/** A spreadsheet saved as CSV by whatever Excel or CRM the agency used before. */
class CsvTableTest {

    private static CsvTable parse(String text) {
        return CsvTable.parse(text.getBytes(StandardCharsets.UTF_8), 100);
    }

    @Test
    @DisplayName("comma, semicolon and tab are each recognised from the header line")
    void delimiters() {
        assertThat(parse("a,b,c\n1,2,3").delimiter()).isEqualTo(',');
        assertThat(parse("a;b;c\n1;2;3").delimiter()).isEqualTo(';');
        assertThat(parse("a\tb\tc\n1\t2\t3").delimiter()).isEqualTo('\t');
        // A comma inside a quoted heading does not count.
        CsvTable table = parse("\"Name, full\";Phone\nAigerim;8701");
        assertThat(table.delimiter()).isEqualTo(';');
        assertThat(table.headers()).containsExactly("Name, full", "Phone");
    }

    @Test
    @DisplayName("a semicolon file keeps decimal commas inside its cells")
    void semicolonWithDecimalCommas() {
        CsvTable table = parse("Цена;Площадь\n12 500 000;45,5\n");
        assertThat(table.rows()).hasSize(1);
        assertThat(table.rows().get(0).cells()).containsExactly("12 500 000", "45,5");
    }

    @Test
    @DisplayName("quoted fields hold delimiters, doubled quotes and line breaks")
    void quotedFields() {
        CsvTable table = parse("name,notes,phone\r\n"
                + "\"Bekova, Aigerim\",\"Said \"\"call after 6\"\"\nand then\r\nagain\",8701\r\n"
                + "Timur,,8702\r\n");
        assertThat(table.rows()).hasSize(2);
        assertThat(table.rows().get(0).cells())
                .containsExactly("Bekova, Aigerim", "Said \"call after 6\"\nand then\r\nagain", "8701");
        assertThat(table.rows().get(1).number()).isEqualTo(3);
        assertThat(table.rows().get(1).cell(1)).isEmpty();
        assertThat(table.rows().get(1).cell(7)).isEmpty();
    }

    @Test
    @DisplayName("blank lines are skipped but still counted, so row numbers match the spreadsheet")
    void blankLines() {
        CsvTable table = parse("\n\nname;phone\n;\nAigerim;1\n\nTimur;2");
        assertThat(table.headers()).containsExactly("name", "phone");
        assertThat(table.rows()).extracting(CsvTable.Row::number).containsExactly(5, 7);
    }

    @Test
    @DisplayName("UTF-8 with and without a byte-order mark")
    void utf8() {
        byte[] body = "ФИО;Телефон\nАйгерім;8701".getBytes(StandardCharsets.UTF_8);
        byte[] withBom = new byte[body.length + 3];
        withBom[0] = (byte) 0xEF;
        withBom[1] = (byte) 0xBB;
        withBom[2] = (byte) 0xBF;
        System.arraycopy(body, 0, withBom, 3, body.length);

        CsvTable plain = CsvTable.parse(body, 10);
        CsvTable bom = CsvTable.parse(withBom, 10);
        assertThat(plain.encoding()).isEqualTo(CsvTable.Encoding.UTF_8);
        assertThat(bom.encoding()).isEqualTo(CsvTable.Encoding.UTF_8_BOM);
        assertThat(bom.headers()).containsExactly("ФИО", "Телефон");
        assertThat(bom.rows().get(0).cell(0)).isEqualTo("Айгерім");
    }

    @Test
    @DisplayName("Windows-1251 from a Russian Excel is read as Cyrillic")
    void windows1251() {
        byte[] bytes = "ФИО;Телефон;Город\nБекова Айгерим;8 701 111 22 33;Алматы\n"
                .getBytes(CsvTable.WINDOWS_1251);
        CsvTable table = CsvTable.parse(bytes, 10);
        assertThat(table.encoding()).isEqualTo(CsvTable.Encoding.WINDOWS_1251);
        assertThat(table.headers()).containsExactly("ФИО", "Телефон", "Город");
        assertThat(table.rows().get(0).cells()).containsExactly("Бекова Айгерим", "8 701 111 22 33", "Алматы");
    }

    @Test
    @DisplayName("UTF-16 from Excel's Unicode text, tab-separated")
    void utf16() {
        byte[] body = "ФИО\tТелефон\nАйгерим\t8701".getBytes(StandardCharsets.UTF_16LE);
        byte[] bytes = new byte[body.length + 2];
        bytes[0] = (byte) 0xFF;
        bytes[1] = (byte) 0xFE;
        System.arraycopy(body, 0, bytes, 2, body.length);
        CsvTable table = CsvTable.parse(bytes, 10);
        assertThat(table.encoding()).isEqualTo(CsvTable.Encoding.UTF_16);
        assertThat(table.delimiter()).isEqualTo('\t');
        assertThat(table.rows().get(0).cells()).containsExactly("Айгерим", "8701");
    }

    @Test
    @DisplayName("more data rows than allowed is refused; exactly the limit is fine")
    void rowLimit() {
        String three = "a\n1\n2\n3\n";
        assertThat(CsvTable.parse(three.getBytes(StandardCharsets.UTF_8), 3).rows()).hasSize(3);
        assertThatThrownBy(() -> CsvTable.parse(three.getBytes(StandardCharsets.UTF_8), 2))
                .isInstanceOf(CsvTable.TooManyRowsException.class);
    }

    @Test
    @DisplayName("an empty file has no header")
    void empty() {
        assertThat(parse("").headers()).isEmpty();
        assertThat(parse("\n \n").headers()).isEmpty();
        assertThat(parse("only;header").rows()).isEqualTo(List.of());
    }
}
