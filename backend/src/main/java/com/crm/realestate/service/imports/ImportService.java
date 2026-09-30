package com.crm.realestate.service.imports;

import com.crm.realestate.dto.response.ClientDuplicate.MatchedOn;
import com.crm.realestate.dto.response.ImportPreviewResponse;
import com.crm.realestate.dto.response.ImportPreviewResponse.Duplicate;
import com.crm.realestate.dto.response.ImportPreviewResponse.DuplicateSource;
import com.crm.realestate.dto.response.ImportPreviewResponse.RowStatus;
import com.crm.realestate.dto.response.ImportResultResponse;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.ClientTag;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ClientSource;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.security.SecurityUtils;
import com.crm.realestate.service.AuditLogService;
import com.crm.realestate.service.ClientDuplicateService;
import com.crm.realestate.service.ClientDuplicateService.ContactIndex;
import com.crm.realestate.service.ClientDuplicateService.KnownClient;
import com.crm.realestate.service.ClientTagService;
import com.crm.realestate.service.ClientTags;
import com.crm.realestate.service.ContactNormalizer;
import com.crm.realestate.service.ScopeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

/**
 * An agency's book brought in from a spreadsheet: read and checked first, then written.
 *
 * <p>Both steps take the file itself, so nothing is kept on the server between them — no upload
 * to expire, clean up or leak across agencies. At {@value #MAX_BYTES} bytes and
 * {@value #MAX_ROWS} rows, reading it twice costs less than holding it.
 *
 * <p><b>What is written.</b> Valid rows only, never part of a row, in one transaction: either every
 * valid row is saved or, if the database refuses one, none is. A few bad rows in a sheet of
 * hundreds should not hold the rest back; they are listed in the preview, fixed in the sheet and
 * imported again — and as duplicates of the first run they are then left out by default.
 *
 * <p><b>Who and where.</b> A manager or an admin, into their own agency. Rows go to the caller or
 * to an active member of the same agency. An admin outside any agency has nowhere to import to.
 *
 * <p>No match notifications go out for imported listings: a hundred "new listing" pushes the
 * moment a sheet lands helps nobody.
 */
@Service
@RequiredArgsConstructor
public class ImportService {

    public static final int MAX_BYTES = 5 * 1024 * 1024;
    public static final int MAX_ROWS = 5000;

    private final ClientRepository clientRepository;
    private final PropertyRepository propertyRepository;
    private final UserRepository userRepository;
    private final ClientDuplicateService duplicateService;
    private final ScopeService scopeService;
    private final SecurityUtils securityUtils;
    private final AuditLogService auditLogService;
    private final ClientTagService tagService;

    @Transactional(readOnly = true)
    public ImportPreviewResponse preview(ImportKind kind, MultipartFile file, List<String> mapping) {
        User importer = requireImporter();
        Analysis analysis = analyse(kind, file, mapping, importer.getTeam().getId());
        return analysis.toPreview();
    }

    @Transactional
    public ImportResultResponse commit(ImportKind kind, MultipartFile file, List<String> mapping,
                                       boolean skipDuplicates, Long assignToId) {
        User importer = requireImporter();
        Team team = importer.getTeam();
        User assignee = assignee(importer, assignToId);
        Analysis analysis = analyse(kind, file, mapping, team.getId());

        int created = 0;
        int skipped = 0;
        int invalid = 0;
        List<Client> clients = new ArrayList<>();
        List<Property> properties = new ArrayList<>();
        Map<Client, List<String>> typedTags = new java.util.IdentityHashMap<>();
        for (Checked checked : analysis.rows) {
            if (!checked.row.valid()) {
                invalid++;
                continue;
            }
            if (checked.duplicate != null && (skipDuplicates || clashesOnEmail(checked.duplicate))) {
                // One email address per agency is a database rule, not a preference.
                skipped++;
                continue;
            }
            if (kind == ImportKind.CLIENTS) {
                Client client = toClient(checked.row, assignee, team);
                clients.add(client);
                List<String> tags = checked.row.get(ImportField.CLIENT_TAGS);
                if (tags != null) {
                    typedTags.put(client, tags);
                }
            } else {
                properties.add(toProperty(checked.row, assignee, team));
            }
            created++;
        }
        tagAll(typedTags, team);
        clientRepository.saveAll(clients);
        propertyRepository.saveAll(properties);

        // Journalled against the agency the rows went into: there is no single record to name.
        auditLogService.record(importer, "IMPORT_" + kind.name(), "Team", team.getId(),
                "file=" + Objects.toString(file.getOriginalFilename(), "")
                        + " rows=" + analysis.rows.size() + " created=" + created
                        + " skippedDuplicates=" + skipped + " invalid=" + invalid
                        + " assignedTo=" + assignee.getId());

        return ImportResultResponse.builder()
                .kind(kind.path())
                .totalRows(analysis.rows.size())
                .created(created)
                .skippedDuplicates(skipped)
                .invalid(invalid)
                .assignedToId(assignee.getId())
                .assignedToName(assignee.getFullName())
                .build();
    }

    private static boolean clashesOnEmail(Duplicate duplicate) {
        return duplicate.getMatchedOn() != MatchedOn.PHONE;
    }

    // Reading -----------------------------------------------------------------------------------

    private record Checked(ImportRow row, Duplicate duplicate) {
    }

    private record Analysis(ImportKind kind, CsvTable table, List<ImportField> mapping, List<Checked> rows) {

        ImportPreviewResponse toPreview() {
            List<ImportPreviewResponse.Row> problems = new ArrayList<>();
            List<ImportPreviewResponse.Row> sample = new ArrayList<>();
            int valid = 0;
            int invalid = 0;
            int duplicates = 0;
            boolean truncated = false;
            for (Checked checked : rows) {
                RowStatus status = !checked.row.valid() ? RowStatus.INVALID
                        : checked.duplicate != null ? RowStatus.DUPLICATE : RowStatus.VALID;
                switch (status) {
                    case VALID -> valid++;
                    case INVALID -> invalid++;
                    case DUPLICATE -> duplicates++;
                }
                if (status == RowStatus.VALID) {
                    if (sample.size() < ImportPreviewResponse.SAMPLE_SIZE) sample.add(toRow(checked, status));
                } else if (problems.size() < ImportPreviewResponse.MAX_PROBLEMS) {
                    problems.add(toRow(checked, status));
                } else {
                    truncated = true;
                }
            }
            return ImportPreviewResponse.builder()
                    .kind(kind.path())
                    .delimiter(String.valueOf(table.delimiter()))
                    .encoding(table.encoding().name())
                    .headers(table.headers())
                    .mapping(mapping.stream().map(f -> f == null ? null : f.key()).toList())
                    .targets(ImportField.of(kind).stream()
                            .map(f -> new ImportPreviewResponse.Target(f.key(), f.required())).toList())
                    .totalRows(rows.size())
                    .validRows(valid)
                    .invalidRows(invalid)
                    .duplicateRows(duplicates)
                    .problems(problems)
                    .problemsTruncated(truncated)
                    .sample(sample)
                    .build();
        }

        private static ImportPreviewResponse.Row toRow(Checked checked, RowStatus status) {
            Map<String, String> values = new LinkedHashMap<>();
            checked.row.values().forEach((key, value) -> values.put(key,
                    value instanceof BigDecimal d ? d.toPlainString()
                            : value instanceof List<?> list ? list.stream().map(String::valueOf)
                                    .collect(java.util.stream.Collectors.joining(", "))
                            : String.valueOf(value)));
            return ImportPreviewResponse.Row.builder()
                    .row(checked.row.number())
                    .status(status)
                    .errors(checked.row.errors())
                    .values(values)
                    .duplicate(checked.duplicate)
                    .build();
        }
    }

    private Analysis analyse(ImportKind kind, MultipartFile file, List<String> mapping, Long teamId) {
        CsvTable table = read(file);
        List<ImportField> fields = resolveMapping(kind, table.headers(), mapping);
        List<Checked> rows = new ArrayList<>(table.rows().size());
        if (kind == ImportKind.CLIENTS) {
            ContactIndex agency = duplicateService.index(teamId);
            Map<String, Integer> phonesInFile = new HashMap<>();
            Map<String, Integer> emailsInFile = new HashMap<>();
            for (CsvTable.Row raw : table.rows()) {
                ImportRow row = ImportRow.read(kind, raw, fields);
                Duplicate duplicate = null;
                if (row.valid()) {
                    String phone = ContactNormalizer.phone(row.get(ImportField.CLIENT_PHONE));
                    String email = ContactNormalizer.email(row.get(ImportField.CLIENT_EMAIL));
                    duplicate = inAgency(agency, phone, email);
                    if (duplicate == null) {
                        duplicate = inFile(phonesInFile, emailsInFile, phone, email);
                    }
                    if (phone != null) phonesInFile.putIfAbsent(phone, row.number());
                    if (email != null) emailsInFile.putIfAbsent(email, row.number());
                }
                rows.add(new Checked(row, duplicate));
            }
        } else {
            for (CsvTable.Row raw : table.rows()) {
                rows.add(new Checked(ImportRow.read(kind, raw, fields), null));
            }
        }
        return new Analysis(kind, table, fields, rows);
    }

    private static Duplicate inAgency(ContactIndex agency, String phone, String email) {
        KnownClient byPhone = phone == null ? null : agency.byPhone().get(phone);
        KnownClient byEmail = email == null ? null : agency.byEmail().get(email);
        KnownClient known = byPhone != null ? byPhone : byEmail;
        if (known == null) {
            return null;
        }
        return Duplicate.builder()
                .source(DuplicateSource.AGENCY)
                .matchedOn(matchedOn(byPhone != null, byEmail != null))
                .clientId(known.id())
                .clientName(known.fullName())
                .build();
    }

    private static Duplicate inFile(Map<String, Integer> phones, Map<String, Integer> emails,
                                    String phone, String email) {
        Integer byPhone = phone == null ? null : phones.get(phone);
        Integer byEmail = email == null ? null : emails.get(email);
        Integer row = byPhone != null ? byPhone : byEmail;
        if (row == null) {
            return null;
        }
        return Duplicate.builder()
                .source(DuplicateSource.FILE)
                .matchedOn(matchedOn(byPhone != null, byEmail != null))
                .row(row)
                .build();
    }

    private static MatchedOn matchedOn(boolean phone, boolean email) {
        return phone && email ? MatchedOn.PHONE_AND_EMAIL : phone ? MatchedOn.PHONE : MatchedOn.EMAIL;
    }

    private static CsvTable read(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "IMPORT_EMPTY_FILE", "The file is empty");
        }
        if (file.getSize() > MAX_BYTES) {
            throw new BusinessException(HttpStatus.PAYLOAD_TOO_LARGE, "IMPORT_FILE_TOO_LARGE",
                    "A spreadsheet can be at most 5 MB");
        }
        CsvTable table;
        try {
            table = CsvTable.parse(file.getBytes(), MAX_ROWS);
        } catch (CsvTable.TooManyRowsException e) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "IMPORT_TOO_MANY_ROWS",
                    "A spreadsheet can have at most " + MAX_ROWS + " rows");
        } catch (IOException e) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "IMPORT_UNREADABLE", "The file could not be read");
        }
        if (table.headers().isEmpty()) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "IMPORT_EMPTY_FILE", "The file is empty");
        }
        return table;
    }

    /** The mapping the person confirmed, or the suggested one when none is given. */
    private static List<ImportField> resolveMapping(ImportKind kind, List<String> headers, List<String> keys) {
        if (keys == null) {
            return ImportField.suggest(kind, headers);
        }
        if (keys.size() != headers.size()) {
            throw badMapping("The mapping has " + keys.size() + " columns, the file " + headers.size());
        }
        List<ImportField> fields = new ArrayList<>();
        Set<ImportField> seen = new HashSet<>();
        for (String key : keys) {
            if (key == null || key.isBlank()) {
                fields.add(null);
                continue;
            }
            ImportField field = ImportField.byKey(kind, key)
                    .orElseThrow(() -> badMapping("Unknown field: " + key));
            if (!seen.add(field)) {
                throw badMapping("Two columns are mapped to " + key);
            }
            fields.add(field);
        }
        return fields;
    }

    private static BusinessException badMapping(String message) {
        return new BusinessException(HttpStatus.BAD_REQUEST, "IMPORT_BAD_MAPPING", message);
    }

    // Template ----------------------------------------------------------------------------------

    /** Column headings of the template, per field: English, Russian, Kazakh. */
    private static final Map<String, String[]> HEADINGS = Map.ofEntries(
            Map.entry("fullName", new String[]{"Full name", "ФИО", "Аты-жөні"}),
            Map.entry("phone", new String[]{"Phone", "Телефон", "Телефон"}),
            Map.entry("email", new String[]{"Email", "Email", "Email"}),
            Map.entry("type", new String[]{"Type", "Тип", "Түрі"}),
            Map.entry("notes", new String[]{"Notes", "Примечание", "Ескертпе"}),
            Map.entry("wantedCity", new String[]{"City", "Город", "Қала"}),
            Map.entry("wantedType", new String[]{"Property type", "Тип недвижимости", "Мүлік түрі"}),
            Map.entry("budgetMin", new String[]{"Budget from", "Бюджет от", "Бюджет бастап"}),
            Map.entry("budgetMax", new String[]{"Budget to", "Бюджет до", "Бюджет дейін"}),
            Map.entry("minRooms", new String[]{"Rooms", "Комнаты", "Бөлме саны"}),
            Map.entry("minAreaSqm", new String[]{"Area", "Площадь", "Аудан"}),
            Map.entry("tags", new String[]{"Tags", "Теги", "Тегтер"}),
            Map.entry("title", new String[]{"Title", "Название", "Атауы"}),
            Map.entry("address", new String[]{"Address", "Адрес", "Мекенжай"}),
            Map.entry("city", new String[]{"City", "Город", "Қала"}),
            Map.entry("status", new String[]{"Status", "Статус", "Мәртебе"}),
            Map.entry("price", new String[]{"Price", "Цена", "Баға"}),
            Map.entry("areaSqm", new String[]{"Area", "Площадь", "Аудан"}),
            Map.entry("rooms", new String[]{"Rooms", "Комнаты", "Бөлме саны"}),
            Map.entry("floor", new String[]{"Floor", "Этаж", "Қабат"}),
            Map.entry("totalFloors", new String[]{"Total floors", "Этажность", "Қабат саны"}),
            Map.entry("description", new String[]{"Description", "Описание", "Сипаттама"}));

    /**
     * The heading the template gives this field in a language — 0 English, 1 Russian, 2 Kazakh.
     * An export writes the same words, so what it writes an import reads back.
     */
    public static String heading(String key, int language) {
        return HEADINGS.get(key)[language];
    }

    /**
     * An empty sheet with one heading per field, in UTF-8 with a byte-order mark so Excel shows
     * Cyrillic headings as letters. Russian and Kazakh use semicolons, which is what Excel in
     * those locales splits on when the file is opened with a double-click.
     */
    public byte[] template(ImportKind kind, String lang) {
        User user = securityUtils.getCurrentUser();
        if (!scopeService.isManager(user) && !scopeService.isAdmin(user)) {
            throw new AccessDeniedException("Only a manager or an admin can import");
        }
        int column = "ru".equals(lang) ? 1 : "kk".equals(lang) ? 2 : 0;
        String delimiter = column == 0 ? "," : ";";
        String header = String.join(delimiter, ImportField.of(kind).stream()
                .map(f -> HEADINGS.get(f.key())[column]).toList());
        byte[] body = (header + "\r\n").getBytes(java.nio.charset.StandardCharsets.UTF_8);
        byte[] bytes = new byte[body.length + 3];
        bytes[0] = (byte) 0xEF;
        bytes[1] = (byte) 0xBB;
        bytes[2] = (byte) 0xBF;
        System.arraycopy(body, 0, bytes, 3, body.length);
        return bytes;
    }

    // Writing -----------------------------------------------------------------------------------

    /**
     * Puts the tags read from each row on its client, from the agency's vocabulary: the whole
     * file's tags are resolved at once, so a sheet of five thousand rows is one lookup.
     */
    private void tagAll(Map<Client, List<String>> typed, Team team) {
        if (typed.isEmpty()) {
            return;
        }
        Map<String, ClientTag> byKey = tagService.resolve(team,
                typed.values().stream().flatMap(List::stream).toList());
        typed.forEach((client, names) -> names.forEach(name ->
                client.getTags().add(byKey.get(ClientTags.key(name)))));
    }

    private static Client toClient(ImportRow row, User agent, Team team) {
        return Client.builder()
                .fullName(row.get(ImportField.CLIENT_FULL_NAME))
                .phone(row.get(ImportField.CLIENT_PHONE))
                .email(row.get(ImportField.CLIENT_EMAIL))
                .type(Objects.requireNonNullElse(row.get(ImportField.CLIENT_TYPE), ClientType.BUYER))
                .notes(row.get(ImportField.CLIENT_NOTES))
                .wantedCity(row.get(ImportField.CLIENT_WANTED_CITY))
                .wantedType(row.get(ImportField.CLIENT_WANTED_TYPE))
                .budgetMin(row.get(ImportField.CLIENT_BUDGET_MIN))
                .budgetMax(row.get(ImportField.CLIENT_BUDGET_MAX))
                .minRooms(row.get(ImportField.CLIENT_MIN_ROOMS))
                .minAreaSqm(row.get(ImportField.CLIENT_MIN_AREA))
                .source(ClientSource.IMPORT)
                .agent(agent)
                .team(team)
                .build();
    }

    private static Property toProperty(ImportRow row, User agent, Team team) {
        return Property.builder()
                .title(row.get(ImportField.PROPERTY_TITLE))
                .address(row.get(ImportField.PROPERTY_ADDRESS))
                .city(row.get(ImportField.PROPERTY_CITY))
                .type(row.get(ImportField.PROPERTY_TYPE))
                .status(Objects.requireNonNullElse(row.get(ImportField.PROPERTY_STATUS), PropertyStatus.AVAILABLE))
                .price(row.get(ImportField.PROPERTY_PRICE))
                .areaSqm(row.get(ImportField.PROPERTY_AREA))
                .rooms(row.get(ImportField.PROPERTY_ROOMS))
                .floor(row.get(ImportField.PROPERTY_FLOOR))
                .totalFloors(row.get(ImportField.PROPERTY_TOTAL_FLOORS))
                .description(row.get(ImportField.PROPERTY_DESCRIPTION))
                .agent(agent)
                .team(team)
                .build();
    }

    // Who ---------------------------------------------------------------------------------------

    private User requireImporter() {
        User user = securityUtils.getCurrentUser();
        if (!scopeService.isManager(user) && !scopeService.isAdmin(user)) {
            throw new AccessDeniedException("Only a manager or an admin can import");
        }
        if (user.getTeam() == null) {
            throw new BusinessException(HttpStatus.FORBIDDEN, "TEAM_REQUIRED",
                    "Records are imported into your agency, and you are not in one");
        }
        return user;
    }

    /** The caller, or an active member of the caller's agency; anyone else reads as missing. */
    private User assignee(User importer, Long assignToId) {
        if (assignToId == null || assignToId.equals(importer.getId())) {
            return importer;
        }
        return userRepository.findById(assignToId)
                .filter(User::isActive)
                .filter(u -> u.getTeam() != null && u.getTeam().getId().equals(importer.getTeam().getId()))
                .orElseThrow(() -> new ResourceNotFoundException("Agent not found with id: " + assignToId));
    }
}
