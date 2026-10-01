package com.crm.realestate.service.imports;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

/**
 * A field an imported row can fill, and the column headings people give it in English, Russian and
 * Kazakh. The key is what travels over the wire: {@code fullName}, {@code price}.
 *
 * <p>Headings are compared after {@link ImportValues#word}: case, punctuation and ё do not matter.
 * An exact match wins over a heading that merely starts with a synonym ("Телефон клиента").
 */
public enum ImportField {

    // Clients -----------------------------------------------------------------------------------
    CLIENT_FULL_NAME(ImportKind.CLIENTS, "fullName", true,
            "full name", "fullname", "name", "client", "client name", "contact", "фио", "имя",
            "ф и о", "клиент", "имя клиента", "контакт", "аты жөні", "аты", "клиенттің аты", "тұтынушы"),
    CLIENT_PHONE(ImportKind.CLIENTS, "phone", false,
            "phone", "phone number", "mobile", "tel", "telephone", "телефон", "тел", "номер телефона",
            "мобильный", "сотовый", "телефон нөмірі", "ұялы телефон"),
    CLIENT_EMAIL(ImportKind.CLIENTS, "email", false,
            "email", "e mail", "mail", "почта", "электронная почта", "эл почта", "емейл", "имейл",
            "электрондық пошта", "пошта"),
    CLIENT_TYPE(ImportKind.CLIENTS, "type", false,
            "type", "client type", "role", "тип", "тип клиента", "роль", "категория", "түрі",
            "клиент түрі"),
    CLIENT_NOTES(ImportKind.CLIENTS, "notes", false,
            "notes", "note", "comment", "comments", "примечание", "примечания", "заметки",
            "комментарий", "комментарии", "ескертпе", "түсініктеме", "пікір"),
    CLIENT_WANTED_CITY(ImportKind.CLIENTS, "wantedCity", false,
            "city", "wanted city", "желаемый город", "город", "қала", "қалаған қала"),
    CLIENT_WANTED_TYPE(ImportKind.CLIENTS, "wantedType", false,
            "property type", "wanted type", "тип недвижимости", "тип объекта", "что ищет",
            "объект", "жылжымайтын мүлік түрі", "нысан түрі", "мүлік түрі"),
    CLIENT_BUDGET_MIN(ImportKind.CLIENTS, "budgetMin", false,
            "budget min", "min budget", "budget from", "бюджет от", "мин бюджет",
            "минимальный бюджет", "бюджет мин", "бюджет бастап", "ең аз бюджет"),
    CLIENT_BUDGET_MAX(ImportKind.CLIENTS, "budgetMax", false,
            "budget", "budget max", "max budget", "budget to", "бюджет", "бюджет до", "макс бюджет",
            "максимальный бюджет", "бюджет макс", "цена", "бюджет дейін", "ең көп бюджет", "баға"),
    CLIENT_MIN_ROOMS(ImportKind.CLIENTS, "minRooms", false,
            "rooms", "min rooms", "bedrooms", "комнаты", "комнат", "кол во комнат",
            "количество комнат", "мин комнат", "бөлме", "бөлмелер", "бөлме саны"),
    CLIENT_MIN_AREA(ImportKind.CLIENTS, "minAreaSqm", false,
            "area", "min area", "size", "площадь", "мин площадь", "площадь от", "аудан",
            "ең аз аудан"),
    CLIENT_TAGS(ImportKind.CLIENTS, "tags", false,
            "tags", "tag", "labels", "label", "теги", "тег", "метки", "метка", "ярлыки", "тегтер",
            "белгілер", "белгі"),
    // Not "source" or "источник" alone: the export's Source column is how the card was entered,
    // which no import sets, and it must stay unmapped when a sheet comes back.
    CLIENT_LEAD_SOURCE(ImportKind.CLIENTS, "leadSource", false,
            "lead source", "channel", "lead channel", "how found", "came from", "источник лида",
            "источник клиента", "канал", "откуда", "откуда пришел", "откуда узнал", "лид көзі",
            "клиент көзі", "арна", "қайдан келді"),
    CLIENT_LEAD_SOURCE_DETAIL(ImportKind.CLIENTS, "leadSourceDetail", false,
            "lead source detail", "referred by", "referrer", "who referred", "источник лида подробности",
            "кто порекомендовал", "кто рекомендовал", "подробности источника", "лид көзі туралы",
            "кім ұсынды"),

    // Listings ----------------------------------------------------------------------------------
    PROPERTY_TITLE(ImportKind.PROPERTIES, "title", true,
            "title", "name", "listing", "headline", "название", "заголовок", "объект",
            "наименование", "объявление", "атауы", "тақырып", "нысан"),
    PROPERTY_ADDRESS(ImportKind.PROPERTIES, "address", true,
            "address", "street", "location", "адрес", "улица", "местоположение", "мекенжай",
            "көше", "мекен жай"),
    PROPERTY_CITY(ImportKind.PROPERTIES, "city", false,
            "city", "town", "город", "населенный пункт", "қала", "елді мекен"),
    PROPERTY_TYPE(ImportKind.PROPERTIES, "type", true,
            "type", "property type", "kind", "тип", "тип недвижимости", "тип объекта", "вид",
            "категория", "түрі", "мүлік түрі", "нысан түрі"),
    PROPERTY_STATUS(ImportKind.PROPERTIES, "status", false,
            "status", "state", "статус", "состояние", "мәртебе", "күйі"),
    PROPERTY_PRICE(ImportKind.PROPERTIES, "price", true,
            "price", "cost", "asking price", "amount", "цена", "стоимость", "сумма", "цена тг",
            "баға", "құны"),
    PROPERTY_AREA(ImportKind.PROPERTIES, "areaSqm", false,
            "area", "area sqm", "size", "sqm", "площадь", "общая площадь", "кв м", "м2", "аудан",
            "жалпы аудан"),
    PROPERTY_ROOMS(ImportKind.PROPERTIES, "rooms", false,
            "rooms", "bedrooms", "комнаты", "комнат", "кол во комнат", "количество комнат",
            "бөлме", "бөлмелер", "бөлме саны"),
    PROPERTY_FLOOR(ImportKind.PROPERTIES, "floor", false,
            "floor", "level", "этаж", "қабат"),
    PROPERTY_TOTAL_FLOORS(ImportKind.PROPERTIES, "totalFloors", false,
            "total floors", "floors", "storeys", "этажность", "этажей", "всего этажей",
            "этажей в доме", "қабат саны", "барлық қабат", "қабаттылығы"),
    PROPERTY_DESCRIPTION(ImportKind.PROPERTIES, "description", false,
            "description", "details", "about", "описание", "подробности", "текст", "сипаттама",
            "толығырақ");

    private final ImportKind kind;
    private final String key;
    private final boolean required;
    private final List<String> synonyms;

    ImportField(ImportKind kind, String key, boolean required, String... synonyms) {
        this.kind = kind;
        this.key = key;
        this.required = required;
        List<String> all = new ArrayList<>();
        all.add(ImportValues.word(key));
        for (String synonym : synonyms) {
            all.add(ImportValues.word(synonym));
        }
        this.synonyms = List.copyOf(all);
    }

    public ImportKind kind() {
        return kind;
    }

    public String key() {
        return key;
    }

    public boolean required() {
        return required;
    }

    public static List<ImportField> of(ImportKind kind) {
        return Arrays.stream(values()).filter(f -> f.kind == kind).toList();
    }

    public static Optional<ImportField> byKey(ImportKind kind, String key) {
        return of(kind).stream().filter(f -> f.key.equals(key)).findFirst();
    }

    /**
     * The field each heading most likely stands for, or null. Each field is given to at most one
     * column: exact matches are placed first, then headings that start with a synonym.
     */
    public static List<ImportField> suggest(ImportKind kind, List<String> headers) {
        ImportField[] result = new ImportField[headers.size()];
        List<ImportField> taken = new ArrayList<>();
        for (int pass = 0; pass < 2; pass++) {
            for (int i = 0; i < headers.size(); i++) {
                if (result[i] != null) continue;
                String heading = ImportValues.word(headers.get(i));
                if (heading.isEmpty()) continue;
                for (ImportField field : of(kind)) {
                    if (taken.contains(field)) continue;
                    boolean hit = pass == 0
                            ? field.synonyms.contains(heading)
                            : field.synonyms.stream().anyMatch(s -> s.length() > 2 && heading.startsWith(s + " "));
                    if (hit) {
                        result[i] = field;
                        taken.add(field);
                        break;
                    }
                }
            }
        }
        return Arrays.asList(result);
    }
}
