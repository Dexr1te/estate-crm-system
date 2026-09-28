package com.crm.realestate.service.imports;

import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

/** Cells as people type them, read as the values they mean. */
class ImportValuesTest {

    private static void price(String typed, String expected) {
        BigDecimal value = ImportValues.price(typed);
        assertThat(value).as(typed).isNotNull();
        assertThat(value.compareTo(new BigDecimal(expected))).as(typed + " -> " + value).isZero();
    }

    @Test
    @DisplayName("prices in the ways agencies write them")
    void prices() {
        price("12500000", "12500000");
        price("12 500 000", "12500000");
        price("12 500 000 ₸", "12500000");
        price("12,5 млн", "12500000");
        price("12.5M", "12500000");
        price("12,5 млн тг", "12500000");
        price("$12,500,000", "12500000");
        price("12.500.000", "12500000");
        price("12 500 000,50", "12500000.50");
        price("1.234.567,89", "1234567.89");
        price("1,234,567.89", "1234567.89");
        price("12,500", "12500");
        price("850 тыс.", "850000");
        price("850k", "850000");
        price("1,2 млрд", "1200000000");
        price("45 000 000 тенге", "45000000");
        price("99000 руб.", "99000");
        // What the app itself writes, in every currency an agency can choose.
        price("12,5\u00A0млн\u00A0₸", "12500000");
        price("12\u00A0500\u00A0000\u00A0₽", "12500000");
        price("€1,200", "1200");
        price("$1.2B", "1200000000");
        price("12,500,000 UZS", "12500000");
        price("12 500 000 сум", "12500000");
        price("850 000 сом", "850000");
        price("1 200 000 KGS", "1200000");
    }

    @Test
    @DisplayName("what is not a price reads as nothing")
    void notPrices() {
        for (String typed : List.of("", "договорная", "12-15 млн", "abc", "млн", "1.2.3,4,5")) {
            assertThat(ImportValues.price(typed)).as(typed).isNull();
        }
    }

    @Test
    @DisplayName("areas take a decimal comma or a unit")
    void areas() {
        assertThat(ImportValues.decimal("45,5")).isEqualByComparingTo("45.5");
        assertThat(ImportValues.decimal("45.5 м²")).isEqualByComparingTo("45.5");
        assertThat(ImportValues.decimal("120 кв.м")).isEqualByComparingTo("120");
        assertThat(ImportValues.decimal("80m2")).isEqualByComparingTo("80");
        assertThat(ImportValues.decimal("big")).isNull();
    }

    @Test
    @DisplayName("whole numbers with a word after them, and floors written 5/9")
    void integers() {
        assertThat(ImportValues.integer("3")).isEqualTo(3);
        assertThat(ImportValues.integer(" 3 комн. ")).isEqualTo(3);
        assertThat(ImportValues.integer("2-к")).isEqualTo(2);
        assertThat(ImportValues.integer("3.5")).isNull();
        assertThat(ImportValues.integer("three")).isNull();
        assertThat(ImportValues.floorOf("5/9")).containsExactly(5, 9);
        assertThat(ImportValues.floorOf("5 из 9")).containsExactly(5, 9);
        assertThat(ImportValues.floorOf("5")).isNull();
    }

    @Test
    @DisplayName("client and listing types, and statuses, in English, Russian and Kazakh")
    void synonyms() {
        assertThat(ImportValues.clientType("Покупатель")).isEqualTo(ClientType.BUYER);
        assertThat(ImportValues.clientType("сатып алушы")).isEqualTo(ClientType.BUYER);
        assertThat(ImportValues.clientType("BUYER")).isEqualTo(ClientType.BUYER);
        assertThat(ImportValues.clientType("продавец")).isEqualTo(ClientType.SELLER);
        assertThat(ImportValues.clientType("Сатушы")).isEqualTo(ClientType.SELLER);
        assertThat(ImportValues.clientType("landlord")).isNull();

        assertThat(ImportValues.propertyType("Квартира")).isEqualTo(PropertyType.APARTMENT);
        assertThat(ImportValues.propertyType("кв.")).isEqualTo(PropertyType.APARTMENT);
        assertThat(ImportValues.propertyType("пәтер")).isEqualTo(PropertyType.APARTMENT);
        assertThat(ImportValues.propertyType("Частный дом")).isEqualTo(PropertyType.HOUSE);
        assertThat(ImportValues.propertyType("үй")).isEqualTo(PropertyType.HOUSE);
        assertThat(ImportValues.propertyType("Земельный участок")).isEqualTo(PropertyType.LAND);
        assertThat(ImportValues.propertyType("кеңсе")).isEqualTo(PropertyType.OFFICE);
        assertThat(ImportValues.propertyType("commercial")).isEqualTo(PropertyType.COMMERCIAL);

        assertThat(ImportValues.propertyStatus("В продаже")).isEqualTo(PropertyStatus.AVAILABLE);
        assertThat(ImportValues.propertyStatus("Продаётся")).isEqualTo(PropertyStatus.AVAILABLE);
        assertThat(ImportValues.propertyStatus("бронь")).isEqualTo(PropertyStatus.RESERVED);
        assertThat(ImportValues.propertyStatus("сатылды")).isEqualTo(PropertyStatus.SOLD);
    }

    @Test
    @DisplayName("headings are matched in three languages, each field to one column at most")
    void headingSuggestions() {
        assertThat(ImportField.suggest(ImportKind.CLIENTS,
                List.of("ФИО", "Телефон клиента", "E-mail", "Тип", "Город", "Бюджет до", "Комнаты", "Что-то ещё")))
                .containsExactly(ImportField.CLIENT_FULL_NAME, ImportField.CLIENT_PHONE,
                        ImportField.CLIENT_EMAIL, ImportField.CLIENT_TYPE, ImportField.CLIENT_WANTED_CITY,
                        ImportField.CLIENT_BUDGET_MAX, ImportField.CLIENT_MIN_ROOMS, null);
        assertThat(ImportField.suggest(ImportKind.PROPERTIES,
                List.of("Атауы", "Мекенжай", "Қала", "Түрі", "Баға", "Аудан", "Бөлме саны", "Қабат", "Қабат саны")))
                .containsExactly(ImportField.PROPERTY_TITLE, ImportField.PROPERTY_ADDRESS,
                        ImportField.PROPERTY_CITY, ImportField.PROPERTY_TYPE, ImportField.PROPERTY_PRICE,
                        ImportField.PROPERTY_AREA, ImportField.PROPERTY_ROOMS, ImportField.PROPERTY_FLOOR,
                        ImportField.PROPERTY_TOTAL_FLOORS);
        assertThat(ImportField.suggest(ImportKind.PROPERTIES, List.of("Name", "Address", "Price", "Name")))
                .containsExactly(ImportField.PROPERTY_TITLE, ImportField.PROPERTY_ADDRESS,
                        ImportField.PROPERTY_PRICE, null);
    }

    @Test
    @DisplayName("a row reports every problem, keyed by field, and a seller keeps no wish list")
    void rowValidation() {
        List<ImportField> mapping = List.of(ImportField.CLIENT_FULL_NAME, ImportField.CLIENT_PHONE,
                ImportField.CLIENT_EMAIL, ImportField.CLIENT_TYPE, ImportField.CLIENT_BUDGET_MAX);
        ImportRow bad = ImportRow.read(ImportKind.CLIENTS,
                new CsvTable.Row(2, List.of("", "12", "not-an-email", "landlord", "a lot")), mapping);
        assertThat(bad.errors()).containsOnlyKeys("fullName", "phone", "email", "type", "budgetMax");
        assertThat(bad.errors().get("fullName")).isEqualTo("REQUIRED");
        assertThat(bad.errors().get("phone")).isEqualTo("INVALID_PHONE");

        ImportRow seller = ImportRow.read(ImportKind.CLIENTS,
                new CsvTable.Row(3, List.of("Aigerim", "8 701 111 22 33", "A@Mail.kz", "продавец", "a lot")), mapping);
        assertThat(seller.valid()).isTrue();
        assertThat(seller.values()).containsEntry("email", "a@mail.kz").doesNotContainKey("budgetMax");

        ImportRow flat = ImportRow.read(ImportKind.PROPERTIES,
                new CsvTable.Row(2, List.of("2-к", "Абая 1", "кв", "12,5 млн", "5/9")),
                List.of(ImportField.PROPERTY_TITLE, ImportField.PROPERTY_ADDRESS, ImportField.PROPERTY_TYPE,
                        ImportField.PROPERTY_PRICE, ImportField.PROPERTY_FLOOR));
        assertThat(flat.errors()).isEmpty();
        assertThat(flat.values()).containsEntry("floor", 5).containsEntry("totalFloors", 9);
        assertThat((BigDecimal) flat.get(ImportField.PROPERTY_PRICE)).isEqualByComparingTo("12500000");
    }
}
