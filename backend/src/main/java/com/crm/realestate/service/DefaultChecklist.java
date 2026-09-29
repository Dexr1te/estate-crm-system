package com.crm.realestate.service;

import com.crm.realestate.enums.ChecklistStage;

import java.util.List;
import java.util.Map;

/**
 * The checklist an agency starts with: what closing a flat sale in Kazakhstan usually takes.
 *
 * <p>Written once, as ordinary rows in the agency's own template, in one language — the template
 * is the agency's text from then on, edited by its manager like any other. Translating it on the
 * fly would stop the moment a manager renamed a line, and would mix languages on a single deal.
 * The language is the manager's when the manager is the one who opens it (their app says which in
 * Accept-Language); otherwise Russian, the language most of our agencies work in.
 */
final class DefaultChecklist {

    static final String FALLBACK_LANGUAGE = "ru";

    record Line(ChecklistStage stage, boolean required, String en, String ru, String kk) {
        String title(String language) {
            return switch (language) {
                case "en" -> en;
                case "kk" -> kk;
                default -> ru;
            };
        }
    }

    static final List<Line> LINES = List.of(
            new Line(ChecklistStage.LEAD, true,
                    "Copy of the buyer's ID",
                    "Копия удостоверения личности покупателя",
                    "Сатып алушының жеке куәлігінің көшірмесі"),
            new Line(ChecklistStage.LEAD, false,
                    "Bank pre-approval",
                    "Предварительное одобрение банка",
                    "Банктің алдын ала мақұлдауы"),
            new Line(ChecklistStage.NEGOTIATION, true,
                    "Title extract for the property",
                    "Справка о зарегистрированных правах на объект",
                    "Нысанға тіркелген құқықтар туралы анықтама"),
            new Line(ChecklistStage.NEGOTIATION, true,
                    "Signed deposit agreement",
                    "Подписанный договор задатка",
                    "Қол қойылған кепілақы шарты"),
            new Line(ChecklistStage.NEGOTIATION, false,
                    "Copy of the seller's ID",
                    "Копия удостоверения личности продавца",
                    "Сатушының жеке куәлігінің көшірмесі"),
            new Line(ChecklistStage.CLOSED_WON, true,
                    "Signed sale contract",
                    "Подписанный договор купли-продажи",
                    "Қол қойылған сатып алу-сату шарты"),
            new Line(ChecklistStage.CLOSED_WON, false,
                    "Keys handed over",
                    "Ключи переданы",
                    "Кілттер тапсырылды"));

    /** How many lines, and how many required ones, each stage of the default has. */
    static final Map<ChecklistStage, long[]> STATS = Map.of(
            ChecklistStage.LEAD, count(ChecklistStage.LEAD),
            ChecklistStage.NEGOTIATION, count(ChecklistStage.NEGOTIATION),
            ChecklistStage.CLOSED_WON, count(ChecklistStage.CLOSED_WON));

    /** One of en, ru, kk from an Accept-Language value, or null when it names none of them. */
    static String supported(String acceptLanguage) {
        if (acceptLanguage == null || acceptLanguage.isBlank()) {
            return null;
        }
        String first = acceptLanguage.split(",")[0].trim().toLowerCase();
        String language = first.split("[-_;]")[0];
        return List.of("en", "ru", "kk").contains(language) ? language : null;
    }

    private static long[] count(ChecklistStage stage) {
        long total = LINES.stream().filter(l -> l.stage() == stage).count();
        long required = LINES.stream().filter(l -> l.stage() == stage && l.required()).count();
        return new long[] {total, required};
    }

    private DefaultChecklist() {
    }
}
