package com.crm.realestate.controller;

import com.crm.realestate.service.ListingShareService.PublicListing;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.text.MessageFormat;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.MissingResourceException;
import java.util.ResourceBundle;

/**
 * The HTML of the public listing page, written as a string like the invite and reset pages.
 *
 * <p>No script, one inline stylesheet, the system font stack (every one of which draws Cyrillic
 * and Kazakh). Every value that came from a person goes through {@link #escape} — a description is
 * typed by an agent and read by a stranger, so it is the one place a {@code <script>} could land.
 */
@Component
public class ListingPageRenderer {

    static final List<String> LANGUAGES = List.of("en", "ru", "kk");
    static final String FALLBACK_LANGUAGE = "ru";

    /** The first of en/ru/kk the browser asks for, Russian when it asks for none of them. */
    public Locale pickLocale(String acceptLanguage) {
        if (acceptLanguage == null || acceptLanguage.isBlank()) {
            return Locale.forLanguageTag(FALLBACK_LANGUAGE);
        }
        try {
            List<Locale.LanguageRange> ranges = Locale.LanguageRange.parse(acceptLanguage);
            for (Locale.LanguageRange range : ranges) {
                String language = range.getRange().split("-")[0].toLowerCase(Locale.ROOT);
                if (range.getWeight() > 0 && LANGUAGES.contains(language)) {
                    return Locale.forLanguageTag(language);
                }
            }
        } catch (IllegalArgumentException malformed) {
            // A header nobody can parse asks for nothing in particular.
        }
        return Locale.forLanguageTag(FALLBACK_LANGUAGE);
    }

    public String notFound(Locale locale) {
        ResourceBundle t = bundle(locale);
        String body = """
                <main class="card empty">
                  <h1>%s</h1>
                  <p class="muted">%s</p>
                </main>
                """.formatted(escape(t.getString("notfound.title")),
                escape(t.getString("notfound.body")));
        return document(locale, t.getString("notfound.title"), "", body);
    }

    public String listing(PublicListing l, Locale locale) {
        ResourceBundle t = bundle(locale);
        String price = formatPrice(l.price(), locale);
        String place = joinNonBlank(", ", l.address(), l.city());

        StringBuilder head = new StringBuilder();
        meta(head, "og:type", "website");
        meta(head, "og:title", l.title());
        meta(head, "og:description", joinNonBlank(" · ", price, place));
        meta(head, "og:url", l.url());
        if (!l.photoIds().isEmpty()) {
            meta(head, "og:image", l.url() + "/photos/" + l.photoIds().get(0));
            head.append("<meta name=\"twitter:card\" content=\"summary_large_image\">\n");
        }

        StringBuilder body = new StringBuilder("<main>\n");
        body.append(gallery(l, t, locale));
        body.append("<section class=\"card\">\n");
        String badge = badge(l, t);
        body.append("<div class=\"price-row\"><div class=\"price\">").append(escape(price))
                .append("</div>").append(badge).append("</div>\n");
        body.append("<h1>").append(escape(l.title())).append("</h1>\n");
        if (!place.isEmpty()) {
            body.append("<p class=\"muted\">").append(escape(place)).append("</p>\n");
        }
        body.append(specs(l, t, locale));
        body.append("</section>\n");
        if (l.description() != null && !l.description().isBlank()) {
            body.append("<section class=\"card\"><h2>")
                    .append(escape(t.getString("section.description")))
                    .append("</h2><p class=\"description\">")
                    .append(escape(l.description().strip()))
                    .append("</p></section>\n");
        }
        body.append(agent(l, t));
        body.append("<p class=\"footer\">").append(escape(t.getString("footer"))).append("</p>\n");
        body.append("</main>\n");
        return document(locale, l.title(), head.toString(), body.toString());
    }

    /**
     * The cover, full width, then the rest two to a row. Paths are relative to the page, so the
     * page works whatever host it is reached on; only the preview tag needs an absolute address.
     */
    private String gallery(PublicListing l, ResourceBundle t, Locale locale) {
        List<Long> ids = l.photoIds();
        if (ids.isEmpty()) {
            return "";
        }
        String token = l.url().substring(l.url().lastIndexOf('/') + 1);
        StringBuilder out = new StringBuilder("<div class=\"gallery\">\n");
        for (int i = 0; i < ids.size(); i++) {
            String src = escape(token + "/photos/" + ids.get(i));
            String alt = new MessageFormat(t.getString("photo.alt"), locale)
                    .format(new Object[] {String.valueOf(i + 1), String.valueOf(ids.size())});
            out.append("<a href=\"").append(src).append("\" class=\"")
                    .append(i == 0 ? "cover" : "thumb").append("\">")
                    .append("<img src=\"").append(src).append("\" alt=\"").append(escape(alt))
                    .append("\"").append(i == 0 ? "" : " loading=\"lazy\"")
                    .append(" decoding=\"async\"></a>\n");
        }
        return out.append("</div>\n").toString();
    }

    private String badge(PublicListing l, ResourceBundle t) {
        if (l.status() == null || l.status().name().equals("AVAILABLE")) {
            return "";
        }
        String name = l.status().name();
        return "<span class=\"badge badge-" + name.toLowerCase(Locale.ROOT) + "\">"
                + escape(t.getString("status." + name)) + "</span>";
    }

    private String specs(PublicListing l, ResourceBundle t, Locale locale) {
        List<String[]> rows = new ArrayList<>();
        if (l.type() != null) {
            rows.add(new String[] {t.getString("spec.type"), t.getString("type." + l.type().name())});
        }
        if (l.rooms() != null) {
            rows.add(new String[] {t.getString("spec.rooms"), String.valueOf(l.rooms())});
        }
        if (l.areaSqm() != null) {
            NumberFormat area = NumberFormat.getNumberInstance(locale);
            area.setMaximumFractionDigits(1);
            rows.add(new String[] {t.getString("spec.area"),
                    area.format(l.areaSqm()) + " " + t.getString("unit.sqm")});
        }
        if (l.floor() != null) {
            String floor = l.totalFloors() != null ? l.floor() + " / " + l.totalFloors()
                    : String.valueOf(l.floor());
            rows.add(new String[] {t.getString("spec.floor"), floor});
        }
        if (rows.isEmpty()) {
            return "";
        }
        StringBuilder out = new StringBuilder("<dl class=\"specs\">\n");
        for (String[] row : rows) {
            out.append("<div><dt>").append(escape(row[0])).append("</dt><dd>")
                    .append(escape(row[1])).append("</dd></div>\n");
        }
        return out.append("</dl>\n").toString();
    }

    /** Name and agency, and a way to call only when the agent has left a number. */
    private String agent(PublicListing l, ResourceBundle t) {
        if (l.agentName() == null && l.agencyName() == null) {
            return "";
        }
        StringBuilder out = new StringBuilder("<section class=\"card\"><h2>")
                .append(escape(t.getString("section.agent"))).append("</h2>\n");
        if (l.agentName() != null) {
            out.append("<div class=\"agent\">").append(escape(l.agentName())).append("</div>\n");
        }
        if (l.agencyName() != null) {
            out.append("<div class=\"muted\">").append(escape(l.agencyName())).append("</div>\n");
        }
        String digits = l.agentPhone() == null ? "" : l.agentPhone().replaceAll("[^0-9]", "");
        if (!digits.isEmpty()) {
            String tel = (l.agentPhone().trim().startsWith("+") ? "+" : "") + digits;
            out.append("<div class=\"actions\">")
                    .append("<a class=\"button\" href=\"tel:").append(escape(tel)).append("\">")
                    .append(escape(t.getString("contact.call"))).append("</a>")
                    .append("<a class=\"button button-light\" href=\"https://wa.me/")
                    .append(escape(digits)).append("\">")
                    .append(escape(t.getString("contact.whatsapp"))).append("</a></div>\n");
        }
        return out.append("</section>\n").toString();
    }

    private String document(Locale locale, String title, String head, String body) {
        return """
                <!doctype html>
                <html lang="%s">
                <head>
                <meta charset="utf-8">
                <meta name="viewport" content="width=device-width,initial-scale=1">
                <meta name="robots" content="noindex,nofollow">
                <meta name="referrer" content="no-referrer">
                <title>%s</title>
                %s<style>%s</style>
                </head>
                <body>
                %s</body>
                </html>
                """.formatted(locale.getLanguage(), escape(title), head, CSS, body);
    }

    private static final String CSS = """
            *{box-sizing:border-box}
            body{margin:0;background:#F4F6FB;color:#0F1E3C;-webkit-text-size-adjust:100%;\
            font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",\
            Arial,"Noto Sans",sans-serif;line-height:1.45}
            main{max-width:640px;margin:0 auto;padding:16px}
            .card{background:#FFF;border:1px solid #E8ECF4;border-radius:16px;padding:18px;\
            margin:0 0 12px}
            .empty{margin-top:48px;text-align:center}
            h1{font-size:20px;margin:6px 0 4px;overflow-wrap:anywhere}
            h2{font-size:13px;text-transform:uppercase;letter-spacing:.04em;color:#6B7A99;\
            margin:0 0 10px}
            .muted{color:#6B7A99;font-size:14px;margin:0;overflow-wrap:anywhere}
            .price-row{display:flex;align-items:center;gap:10px;flex-wrap:wrap}
            .price{font-size:24px;font-weight:700}
            .badge{font-size:12px;font-weight:700;text-transform:uppercase;padding:4px 10px;\
            border-radius:999px;letter-spacing:.04em}
            .badge-sold{background:#FDECEC;color:#B42318}
            .badge-reserved{background:#FEF4E6;color:#9A5B00}
            .specs{display:grid;grid-template-columns:repeat(auto-fit,minmax(120px,1fr));gap:8px;\
            margin:14px 0 0}
            .specs div{background:#EEF1F8;border-radius:10px;padding:8px 10px}
            dt{font-size:12px;color:#6B7A99}dd{margin:0;font-weight:600;overflow-wrap:anywhere}
            .description{white-space:pre-line;margin:0;overflow-wrap:anywhere}
            .gallery{display:grid;grid-template-columns:1fr 1fr;gap:6px;margin:0 0 12px}
            .gallery a{display:block;border-radius:12px;overflow:hidden;background:#E8ECF4}
            .gallery .cover{grid-column:1/-1;aspect-ratio:4/3}
            .gallery .thumb{aspect-ratio:1}
            .gallery img{width:100%;height:100%;object-fit:cover;display:block}
            .agent{font-weight:600;font-size:16px}
            .actions{display:flex;gap:8px;margin-top:14px;flex-wrap:wrap}
            .button{flex:1;min-width:140px;text-align:center;background:#0F1E3C;color:#FFF;\
            text-decoration:none;font-weight:600;padding:13px 16px;border-radius:12px}
            .button-light{background:#EEF1F8;color:#0F1E3C}
            .footer{text-align:center;color:#9AA5BE;font-size:12px;margin:18px 0 8px}
            """;

    private static void meta(StringBuilder head, String property, String content) {
        if (content == null || content.isBlank()) {
            return;
        }
        head.append("<meta property=\"").append(property).append("\" content=\"")
                .append(escape(content)).append("\">\n");
    }

    private static ResourceBundle bundle(Locale locale) {
        try {
            return ResourceBundle.getBundle("i18n.listing_page", locale,
                    ResourceBundle.Control.getNoFallbackControl(
                            ResourceBundle.Control.FORMAT_PROPERTIES));
        } catch (MissingResourceException e) {
            return ResourceBundle.getBundle("i18n.listing_page",
                    Locale.forLanguageTag(FALLBACK_LANGUAGE),
                    ResourceBundle.Control.getNoFallbackControl(
                            ResourceBundle.Control.FORMAT_PROPERTIES));
        }
    }

    /** Dollars, as the app shows them, grouped the way the reader's language groups digits. */
    static String formatPrice(BigDecimal price, Locale locale) {
        if (price == null) {
            return "";
        }
        NumberFormat format = NumberFormat.getIntegerInstance(locale);
        return "$" + format.format(price);
    }

    private static String joinNonBlank(String separator, String... parts) {
        List<String> kept = new ArrayList<>();
        for (String part : parts) {
            if (part != null && !part.isBlank()) {
                kept.add(part.strip());
            }
        }
        return String.join(separator, kept);
    }

    /** Text and attribute values alike: all five characters that can end either. */
    static String escape(String value) {
        if (value == null) {
            return "";
        }
        StringBuilder out = new StringBuilder(value.length());
        for (char c : value.toCharArray()) {
            switch (c) {
                case '&' -> out.append("&amp;");
                case '<' -> out.append("&lt;");
                case '>' -> out.append("&gt;");
                case '"' -> out.append("&quot;");
                case '\'' -> out.append("&#39;");
                default -> out.append(c);
            }
        }
        return out.toString();
    }
}
