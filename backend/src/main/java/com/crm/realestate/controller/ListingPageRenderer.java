package com.crm.realestate.controller;

import com.crm.realestate.service.ListingLeadService;
import com.crm.realestate.service.ListingLeadService.LeadForm;
import com.crm.realestate.service.ListingShareService.PublicListing;
import org.springframework.stereotype.Component;

import com.crm.realestate.enums.AgencyCurrency;
import java.math.BigDecimal;
import java.math.RoundingMode;
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
        String price = formatPrice(l.price(), l.currency(), locale);
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
        body.append(mapLink(l, t));
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
        // Relative to the page, like the photos: /l/{token} posts to /l/{token}/interest.
        String token = l.url().substring(l.url().lastIndexOf('/') + 1);
        body.append(leadForm(token + "/interest", t, EMPTY_FORM, List.of(), false));
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
            String perSqm = formatPricePerSqm(l.price(), l.areaSqm(), l.currency(), locale);
            if (!perSqm.isEmpty()) {
                rows.add(new String[] {t.getString("spec.pricePerSqm"), perSqm});
            }
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

    /**
     * A plain link to the point on OpenStreetMap, only when the agent dropped a pin. No embedded
     * map: that would need scripts and a third-party frame the page's policy does not allow.
     */
    static String mapLink(PublicListing l, ResourceBundle t) {
        if (l.latitude() == null || l.longitude() == null) {
            return "";
        }
        String lat = coordinate(l.latitude());
        String lng = coordinate(l.longitude());
        String href = "https://www.openstreetmap.org/?mlat=" + lat + "&mlon=" + lng
                + "#map=17/" + lat + "/" + lng;
        return "<p class=\"map\"><a href=\"" + escape(href)
                + "\" rel=\"noopener noreferrer\" target=\"_blank\">"
                + escape(t.getString("map.open")) + "</a></p>\n";
    }

    /** Six places, a dot whatever the locale: ten centimetres is all a pin means. */
    private static String coordinate(double value) {
        return String.format(Locale.ROOT, "%.6f", value);
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

    private static final LeadForm EMPTY_FORM = new LeadForm(null, null, null, false);

    /**
     * The form again after a failed send: the listing's title, what was typed (escaped), and what
     * was wrong. It is served at {@code /l/{token}/interest}, so it posts to {@code interest} and
     * links back with {@code ../{token}}.
     */
    public String leadPage(String title, String token, LeadForm typed, List<String> errors,
            boolean tooMany, Locale locale) {
        ResourceBundle t = bundle(locale);
        String body = "<main>\n<section class=\"card\"><h1>" + escape(title) + "</h1>\n"
                + backLink(token, t) + "</section>\n"
                + leadForm("interest", t, typed, errors, tooMany)
                + "<p class=\"footer\">" + escape(t.getString("footer")) + "</p>\n</main>\n";
        return document(locale, title, "", body);
    }

    /** What a buyer sees once the agent has their details — and, for a bot, the same. */
    public String thanks(String title, String token, Locale locale) {
        ResourceBundle t = bundle(locale);
        String sentence = new MessageFormat(t.getString("lead.thanks.body"), locale)
                .format(new Object[] {title == null ? "" : title});
        String body = "<main class=\"card empty\">\n<h1>" + escape(t.getString("lead.thanks.title"))
                + "</h1>\n<p class=\"muted\">" + escape(sentence) + "</p>\n"
                + backLink(token, t) + "</main>\n";
        return document(locale, t.getString("lead.thanks.title"), "", body);
    }

    private static String backLink(String token, ResourceBundle t) {
        return "<p class=\"map\"><a href=\"../" + escape(token) + "\">"
                + escape(t.getString("lead.back")) + "</a></p>\n";
    }

    /**
     * "I'm interested": name, phone, an optional message, the consent box and a honeypot. Plain
     * HTML, posted by the browser; the policy's {@code form-action 'self'} is what lets it go.
     */
    private String leadForm(String action, ResourceBundle t, LeadForm typed, List<String> errors,
            boolean tooMany) {
        StringBuilder out = new StringBuilder("<section class=\"card\" id=\"interest\"><h2>")
                .append(escape(t.getString("lead.title"))).append("</h2>\n<p class=\"muted\">")
                .append(escape(t.getString("lead.intro"))).append("</p>\n");
        if (tooMany) {
            out.append("<p class=\"error\" role=\"alert\">")
                    .append(escape(t.getString("lead.error.tooMany"))).append("</p>\n");
        } else if (!errors.isEmpty()) {
            out.append("<p class=\"error\" role=\"alert\">")
                    .append(escape(t.getString("lead.error.summary"))).append("</p>\n");
        }
        out.append("<form class=\"lead\" method=\"post\" action=\"").append(escape(action))
                .append("\" accept-charset=\"utf-8\">\n");
        field(out, t, errors, "name", "text", "name", ListingLeadService.MAX_NAME, typed.name());
        field(out, t, errors, "phone", "tel", "tel", ListingLeadService.MAX_PHONE, typed.phone());
        out.append("<label for=\"lead-message\">").append(escape(t.getString("lead.message")))
                .append("</label>\n<textarea id=\"lead-message\" name=\"message\" rows=\"3\" maxlength=\"")
                .append(ListingLeadService.MAX_MESSAGE).append("\"")
                .append(invalid(errors, "message")).append(">")
                .append(escape(typed.message())).append("</textarea>\n")
                .append(fieldError(t, errors, "message"));
        // Hidden from people and from screen readers; a bot filling every field fills this too.
        out.append("<div class=\"hp\" aria-hidden=\"true\"><label for=\"lead-website\">")
                .append(escape(t.getString("lead.honeypot")))
                .append("</label><input id=\"lead-website\" name=\"website\" type=\"text\"")
                .append(" tabindex=\"-1\" autocomplete=\"off\"></div>\n");
        out.append("<label class=\"consent\"><input type=\"checkbox\" name=\"consent\" value=\"yes\"")
                .append(" required").append(typed.consent() ? " checked" : "")
                .append(invalid(errors, "consent")).append("> <span>")
                .append(escape(t.getString("lead.consent"))).append("</span></label>\n")
                .append(fieldError(t, errors, "consent"));
        out.append("<button type=\"submit\" class=\"button\">")
                .append(escape(t.getString("lead.submit"))).append("</button>\n</form>\n</section>\n");
        return out.toString();
    }

    private static void field(StringBuilder out, ResourceBundle t, List<String> errors, String name,
            String type, String autocomplete, int max, String value) {
        out.append("<label for=\"lead-").append(name).append("\">")
                .append(escape(t.getString("lead." + name))).append("</label>\n")
                .append("<input id=\"lead-").append(name).append("\" name=\"").append(name)
                .append("\" type=\"").append(type).append("\" required maxlength=\"").append(max)
                .append("\" autocomplete=\"").append(autocomplete).append("\" value=\"")
                .append(escape(value)).append("\"").append(invalid(errors, name)).append(">\n")
                .append(fieldError(t, errors, name));
    }

    private static String invalid(List<String> errors, String field) {
        return errors.contains(field) ? " aria-invalid=\"true\"" : "";
    }

    private static String fieldError(ResourceBundle t, List<String> errors, String field) {
        return errors.contains(field) ? "<p class=\"field-error\">"
                + escape(t.getString("lead.error." + field)) + "</p>\n" : "";
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
            .map{margin:10px 0 0;font-size:14px}
            .map a{color:#0F1E3C;font-weight:600}
            .footer{text-align:center;color:#9AA5BE;font-size:12px;margin:18px 0 8px}
            .lead label{display:block;font-size:13px;color:#6B7A99;margin:12px 0 4px}
            .lead input[type=text],.lead input[type=tel],.lead textarea{width:100%;font:inherit;\
            color:inherit;background:#F4F6FB;border:1px solid #E8ECF4;border-radius:12px;\
            padding:12px 14px}
            .lead textarea{resize:vertical;min-height:84px}
            .lead [aria-invalid=true]{border-color:#B42318}
            .lead .consent{display:flex;gap:10px;align-items:flex-start;color:#0F1E3C;\
            font-size:14px;margin:14px 0}
            .lead .consent input{margin:3px 0 0;width:18px;height:18px;flex:none}
            .lead .button{display:block;width:100%;border:0;font:inherit;font-weight:600;\
            cursor:pointer;margin-top:6px}
            .error{background:#FDECEC;color:#B42318;border-radius:10px;padding:10px 12px;\
            font-size:14px;margin:12px 0 0}
            .field-error{color:#B42318;font-size:13px;margin:4px 0 0}
            .hp{position:absolute;left:-10000px;width:1px;height:1px;overflow:hidden}
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

    /** In the agency's currency, grouped the way the reader's language groups digits. */
    static String formatPrice(BigDecimal price, AgencyCurrency currency, Locale locale) {
        if (price == null) {
            return "";
        }
        return (currency == null ? AgencyCurrency.USD : currency).format(price, locale);
    }

    /** Price over area, whole units; empty when either is missing or zero. */
    static String formatPricePerSqm(BigDecimal price, Double areaSqm, AgencyCurrency currency,
                                    Locale locale) {
        if (price == null || price.signum() <= 0 || areaSqm == null || areaSqm <= 0) {
            return "";
        }
        BigDecimal perSqm = price.divide(BigDecimal.valueOf(areaSqm), 0, RoundingMode.HALF_UP);
        return formatPrice(perSqm, currency, locale);
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
