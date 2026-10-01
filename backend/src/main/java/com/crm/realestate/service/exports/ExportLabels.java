package com.crm.realestate.service.exports;

import com.crm.realestate.enums.ClientSource;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DealLostReason;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.LeadSource;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import com.crm.realestate.service.imports.ImportService;

import java.util.Map;

/**
 * The words an export writes, in English, Russian and Kazakh (index 0, 1, 2).
 *
 * <p>A column the importer can fill takes the heading of the import template, and a value it can
 * read is written as one of the words it accepts — "Покупатель", "Квартира", "В продаже" — so a
 * sheet that goes out comes back in without a single column to map by hand. Columns an import has
 * no field for (agent, source, dates, deals altogether) use headings no import synonym starts
 * with, so they are left unmapped rather than taken for something else.
 */
final class ExportLabels {

    private ExportLabels() {
    }

    static int language(String lang) {
        return "ru".equals(lang) ? 1 : "kk".equals(lang) ? 2 : 0;
    }

    /** The template's heading for an importable field. */
    static String imported(String key, int language) {
        return ImportService.heading(key, language);
    }

    private static final Map<String, String[]> HEADINGS = Map.ofEntries(
            Map.entry("agent", new String[]{"Agent", "Агент", "Агент"}),
            Map.entry("source", new String[]{"Source", "Источник", "Дереккөз"}),
            Map.entry("created", new String[]{"Created", "Создан", "Құрылған"}),
            Map.entry("linkViews", new String[]{"Link views", "Просмотры ссылки", "Сілтеме қаралымы"}),
            Map.entry("dealTitle", new String[]{"Title", "Название", "Атауы"}),
            Map.entry("dealStatus", new String[]{"Status", "Статус", "Мәртебе"}),
            Map.entry("client", new String[]{"Client", "Клиент", "Клиент"}),
            Map.entry("listing", new String[]{"Listing", "Объект", "Нысан"}),
            Map.entry("dealPrice", new String[]{"Deal price", "Цена сделки", "Мәміле бағасы"}),
            Map.entry("budget", new String[]{"Budget", "Бюджет", "Бюджет"}),
            Map.entry("commissionPercent", new String[]{"Commission %", "Комиссия %", "Комиссия %"}),
            Map.entry("commission", new String[]{"Commission", "Комиссия", "Комиссия"}),
            Map.entry("dealCreated", new String[]{"Created", "Создана", "Құрылған"}),
            Map.entry("closed", new String[]{"Closed", "Закрыта", "Жабылған"}),
            Map.entry("lostReason", new String[]{"Lost reason", "Причина проигрыша", "Жоғалту себебі"}),
            Map.entry("lostNote", new String[]{"Lost note", "Комментарий к проигрышу", "Жоғалту түсініктемесі"}));

    static String heading(String key, int language) {
        return HEADINGS.get(key)[language];
    }

    private static final Map<Enum<?>, String[]> VALUES = Map.ofEntries(
            Map.entry(ClientType.BUYER, new String[]{"Buyer", "Покупатель", "Сатып алушы"}),
            Map.entry(ClientType.SELLER, new String[]{"Seller", "Продавец", "Сатушы"}),
            Map.entry(PropertyType.APARTMENT, new String[]{"Apartment", "Квартира", "Пәтер"}),
            Map.entry(PropertyType.HOUSE, new String[]{"House", "Дом", "Жеке үй"}),
            Map.entry(PropertyType.COMMERCIAL, new String[]{"Commercial", "Коммерческая недвижимость", "Коммерциялық"}),
            Map.entry(PropertyType.LAND, new String[]{"Land", "Земельный участок", "Жер учаскесі"}),
            Map.entry(PropertyType.OFFICE, new String[]{"Office", "Офис", "Кеңсе"}),
            Map.entry(PropertyStatus.AVAILABLE, new String[]{"Available", "В продаже", "Сатылымда"}),
            Map.entry(PropertyStatus.RESERVED, new String[]{"Reserved", "Забронирована", "Брондалған"}),
            Map.entry(PropertyStatus.SOLD, new String[]{"Sold", "Продана", "Сатылды"}),
            Map.entry(ClientSource.MANUAL, new String[]{"Manual", "Вручную", "Қолмен"}),
            Map.entry(ClientSource.IMPORT, new String[]{"Imported", "Из импорта", "Импорттан"}),
            Map.entry(ClientSource.PUBLIC_LINK, new String[]{"Public link", "С публичной ссылки", "Жария сілтемеден"}),
            Map.entry(LeadSource.REFERRAL, new String[]{"Referral", "Рекомендация", "Ұсыныс"}),
            Map.entry(LeadSource.WEBSITE, new String[]{"Website", "Сайт", "Сайт"}),
            Map.entry(LeadSource.PORTAL, new String[]{"Listings portal", "Портал объявлений", "Хабарландыру порталы"}),
            Map.entry(LeadSource.SOCIAL, new String[]{"Social media", "Соцсети", "Әлеуметтік желілер"}),
            Map.entry(LeadSource.WALK_IN, new String[]{"Walk-in", "Пришёл в офис", "Кеңсеге келді"}),
            Map.entry(LeadSource.COLD_CALL, new String[]{"Cold call", "Холодный звонок", "Суық қоңырау"}),
            Map.entry(LeadSource.REPEAT, new String[]{"Repeat client", "Повторный клиент", "Тұрақты клиент"}),
            Map.entry(LeadSource.OTHER, new String[]{"Other", "Другое", "Басқа"}),
            Map.entry(DealStatus.LEAD, new String[]{"Lead", "Лид", "Лид"}),
            Map.entry(DealStatus.NEGOTIATION, new String[]{"Negotiation", "Переговоры", "Келіссөздер"}),
            Map.entry(DealStatus.CLOSED_WON, new String[]{"Won", "Выиграна", "Жеңіске жетті"}),
            Map.entry(DealStatus.CLOSED_LOST, new String[]{"Lost", "Проиграна", "Жоғалтылды"}),
            Map.entry(DealLostReason.PRICE, new String[]{"Price", "Цена", "Баға"}),
            Map.entry(DealLostReason.CHOSE_ANOTHER, new String[]{"Chose another option", "Выбрал другой вариант", "Басқа нұсқаны таңдады"}),
            Map.entry(DealLostReason.FINANCING, new String[]{"Financing fell through", "Не получилось с финансированием", "Қаржыландыру болмады"}),
            Map.entry(DealLostReason.CHANGED_MIND, new String[]{"Changed their mind", "Передумал", "Ойынан айнып қалды"}),
            Map.entry(DealLostReason.NO_RESPONSE, new String[]{"Stopped responding", "Перестал выходить на связь", "Байланысқа шықпай кетті"}),
            Map.entry(DealLostReason.OTHER, new String[]{"Other", "Другое", "Басқа"}));

    static String value(Enum<?> value, int language) {
        return value == null ? "" : VALUES.get(value)[language];
    }
}
