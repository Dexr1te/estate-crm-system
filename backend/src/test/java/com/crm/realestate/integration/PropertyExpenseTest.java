package com.crm.realestate.integration;

import com.crm.realestate.dto.request.PropertyExpenseRequest;
import com.crm.realestate.dto.response.ExpenseCategoryTotal;
import com.crm.realestate.dto.response.ExpenseSummaryResponse;
import com.crm.realestate.dto.response.PropertyExpenseResponse;
import com.crm.realestate.dto.response.PropertyExpensesResponse;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.PropertyExpense;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.ExpenseCategory;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.PropertyExpenseRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.security.JwtService;
import com.crm.realestate.service.PropertyExpenseService;
import jakarta.persistence.EntityManager;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.test.context.TestSecurityContextHolder;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.groups.Tuple.tuple;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Money spent on listings: recorded on a listing the caller can see, summed per listing and over a
 * period, deleted by who recorded it or a manager, and everything inside the agency.
 */
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class PropertyExpenseTest {

    @Autowired private MockMvc mockMvc;
    @Autowired private JwtService jwtService;
    @Autowired private PropertyExpenseService expenseService;
    @Autowired private PropertyExpenseRepository expenseRepository;
    @Autowired private PropertyRepository propertyRepository;
    @Autowired private UserRepository userRepository;
    @Autowired private TeamRepository teamRepository;
    @Autowired private EntityManager entityManager;

    private Team almaty;
    private User agent;
    private User colleague;
    private User manager;
    private User stranger;
    private Property flat;
    private Property colleaguesFlat;
    private LocalDate today;

    @BeforeEach
    void setUp() {
        SecurityContextHolder.clearContext();
        almaty = teamRepository.save(Team.builder().name("Almaty Realty").build());
        Team astana = teamRepository.save(Team.builder().name("Astana Homes").build());
        agent = user("ex-agent@almaty.kz", "Aigul Bekova", Role.AGENT, DataScope.OWN, almaty);
        colleague = user("ex-colleague@almaty.kz", "Timur Aliev", Role.AGENT, DataScope.OWN, almaty);
        manager = user("ex-manager@almaty.kz", "Marat Manager", Role.MANAGER, DataScope.TEAM, almaty);
        stranger = user("ex-stranger@astana.kz", "Erlan Other", Role.MANAGER, DataScope.TEAM, astana);
        flat = listing("Severny Residence, apt 84", agent);
        colleaguesFlat = listing("Esentai City, apt 12", colleague);
        today = LocalDate.now();
        signIn(agent);
    }

    // One listing -----------------------------------------------------------------------

    @Test
    @DisplayName("an expense is recorded on a listing and the listing reads its items, total and categories")
    void recordAndRead() throws Exception {
        record(flat, agent, "PHOTO", "45000", today.minusDays(3), " Photographer, 40 shots ")
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.category").value("PHOTO"))
                .andExpect(jsonPath("$.amount").value(45000))
                .andExpect(jsonPath("$.note").value("Photographer, 40 shots"))
                .andExpect(jsonPath("$.createdByName").value("Aigul Bekova"))
                .andExpect(jsonPath("$.canDelete").value(true));
        record(flat, agent, "ADVERTISING", "30000", today, null).andExpect(status().isCreated());
        record(flat, agent, "ADVERTISING", "25000.50", today.minusDays(10), null).andExpect(status().isCreated());

        mockMvc.perform(get("/properties/{id}/expenses", flat.getId())
                        .header(HttpHeaders.AUTHORIZATION, bearer(agent)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.items.length()").value(3))
                .andExpect(jsonPath("$.items[0].spentOn").value(today.toString()))
                .andExpect(jsonPath("$.items[2].spentOn").value(today.minusDays(10).toString()))
                .andExpect(jsonPath("$.total").value(100000.50))
                .andExpect(jsonPath("$.byCategory[0].category").value("ADVERTISING"))
                .andExpect(jsonPath("$.byCategory[0].total").value(55000.50))
                .andExpect(jsonPath("$.byCategory[1].category").value("PHOTO"));

        signIn(agent);
        PropertyExpensesResponse read = expenseService.forProperty(flat.getId());
        assertThat(read.getItems()).extracting(PropertyExpenseResponse::getSpentOn)
                .containsExactly(today, today.minusDays(3), today.minusDays(10));
        assertThat(read.getTotal()).isEqualByComparingTo("100000.50");
        assertThat(read.getByCategory()).extracting(ExpenseCategoryTotal::getCategory, t -> t.getTotal().toPlainString())
                .containsExactly(tuple(ExpenseCategory.ADVERTISING, "55000.50"), tuple(ExpenseCategory.PHOTO, "45000.00"));
        assertThat(expenseRepository.findAll()).allSatisfy(e -> {
            assertThat(e.getTeam().getId()).as("the listing's agency").isEqualTo(almaty.getId());
            assertThat(e.getCreatedBy().getId()).isEqualTo(agent.getId());
        });
    }

    @Test
    @DisplayName("a listing with nothing spent reads as zero, not as missing")
    void nothingSpent() {
        PropertyExpensesResponse read = expenseService.forProperty(flat.getId());
        assertThat(read.getItems()).isEmpty();
        assertThat(read.getByCategory()).isEmpty();
        assertThat(read.getTotal()).isEqualByComparingTo("0");
    }

    @Test
    @DisplayName("the whole agency sees what a listing cost, whatever its data scope")
    void colleagueSeesTheListingsExpenses() {
        expenseService.create(flat.getId(), request(ExpenseCategory.STAGING, "120000", today, null));

        signIn(colleague);
        PropertyExpensesResponse read = expenseService.forProperty(flat.getId());
        assertThat(read.getTotal()).isEqualByComparingTo("120000");
        assertThat(read.getItems()).singleElement()
                .satisfies(e -> assertThat(e.isCanDelete()).as("not theirs").isFalse());
    }

    // Validation ------------------------------------------------------------------------

    @Test
    @DisplayName("the API refuses no amount, zero, a negative, a day after today, no category and a long note")
    void validation() throws Exception {
        record(flat, agent, "PHOTO", "0", today, null).andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.validationErrors.amount").exists());
        record(flat, agent, "PHOTO", "-10", today, null).andExpect(status().isBadRequest());
        record(flat, agent, "PHOTO", "1.234", today, null).andExpect(status().isBadRequest());
        record(flat, agent, "PHOTO", "100", today.plusDays(1), null)
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("EXPENSE_DATE_IN_FUTURE"));
        record(flat, agent, "PHOTO", "100", today, "x".repeat(501)).andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.validationErrors.note").exists());
        mockMvc.perform(post("/properties/{id}/expenses", flat.getId())
                        .header(HttpHeaders.AUTHORIZATION, bearer(agent))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"amount\":100,\"spentOn\":\"" + today + "\"}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.validationErrors.category").exists());
        mockMvc.perform(post("/properties/{id}/expenses", flat.getId())
                        .header(HttpHeaders.AUTHORIZATION, bearer(agent))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"category\":\"PHOTO\",\"spentOn\":\"" + today + "\"}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.validationErrors.amount").exists());
        assertThat(expenseRepository.count()).isZero();

        record(flat, agent, "OTHER", "0.01", today, "x".repeat(500)).andExpect(status().isCreated());
    }

    // Deleting --------------------------------------------------------------------------

    @Test
    @DisplayName("who recorded it deletes it; a colleague is refused; a manager may")
    void deletePermissions() throws Exception {
        Long mine = expenseService.create(flat.getId(), request(ExpenseCategory.PHOTO, "1000", today, null)).getId();
        Long another = expenseService.create(flat.getId(), request(ExpenseCategory.LEGAL, "2000", today, null)).getId();

        mockMvc.perform(delete("/properties/{p}/expenses/{e}", flat.getId(), mine)
                        .header(HttpHeaders.AUTHORIZATION, bearer(colleague)))
                .andExpect(status().isForbidden());
        signIn(colleague);
        assertThatThrownBy(() -> expenseService.delete(flat.getId(), mine))
                .isInstanceOf(AccessDeniedException.class);

        mockMvc.perform(delete("/properties/{p}/expenses/{e}", flat.getId(), mine)
                        .header(HttpHeaders.AUTHORIZATION, bearer(agent)))
                .andExpect(status().isNoContent());
        mockMvc.perform(delete("/properties/{p}/expenses/{e}", flat.getId(), another)
                        .header(HttpHeaders.AUTHORIZATION, bearer(manager)))
                .andExpect(status().isNoContent());
        assertThat(expenseRepository.count()).isZero();
    }

    @Test
    @DisplayName("an expense is deleted only through its own listing")
    void deleteThroughItsListing() throws Exception {
        Long id = expenseService.create(flat.getId(), request(ExpenseCategory.PHOTO, "1000", today, null)).getId();

        mockMvc.perform(delete("/properties/{p}/expenses/{e}", colleaguesFlat.getId(), id)
                        .header(HttpHeaders.AUTHORIZATION, bearer(manager)))
                .andExpect(status().isNotFound());
        assertThat(expenseRepository.existsById(id)).isTrue();
    }

    // Another agency --------------------------------------------------------------------

    @Test
    @DisplayName("another agency is told the listing and its expenses do not exist")
    void anotherAgencySeesNothing() throws Exception {
        Long id = expenseService.create(flat.getId(), request(ExpenseCategory.PHOTO, "1000", today, null)).getId();

        mockMvc.perform(get("/properties/{id}/expenses", flat.getId())
                        .header(HttpHeaders.AUTHORIZATION, bearer(stranger)))
                .andExpect(status().isNotFound());
        record(flat, stranger, "PHOTO", "100", today, null).andExpect(status().isNotFound());
        mockMvc.perform(delete("/properties/{p}/expenses/{e}", flat.getId(), id)
                        .header(HttpHeaders.AUTHORIZATION, bearer(stranger)))
                .andExpect(status().isNotFound());

        signIn(stranger);
        assertThatThrownBy(() -> expenseService.forProperty(flat.getId()))
                .isInstanceOf(ResourceNotFoundException.class);
        ExpenseSummaryResponse theirs = expenseService.summary(today.withDayOfMonth(1), today);
        assertThat(theirs.getTotal()).isEqualByComparingTo("0");
        assertThat(theirs.getTopListings()).isEmpty();
        assertThat(expenseRepository.count()).isEqualTo(1);
    }

    @Test
    @DisplayName("without a team the expenses are shut, like the rest of the CRM")
    void teamRequired() throws Exception {
        User loner = user("ex-loner@nowhere.kz", "Loner", Role.AGENT, DataScope.OWN, null);
        mockMvc.perform(get("/expenses/summary").header(HttpHeaders.AUTHORIZATION, bearer(loner)))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.code").value("TEAM_REQUIRED"));
    }

    // A period --------------------------------------------------------------------------

    @Test
    @DisplayName("the summary counts both ends of the period, per category and by listing, the most first")
    void summaryTotals() throws Exception {
        LocalDate from = LocalDate.of(2026, 3, 1);
        LocalDate to = LocalDate.of(2026, 3, 31);
        stored(flat, ExpenseCategory.PHOTO, "40000", from, agent);
        stored(flat, ExpenseCategory.ADVERTISING, "15000", to, agent);
        stored(colleaguesFlat, ExpenseCategory.ADVERTISING, "70000", LocalDate.of(2026, 3, 15), colleague);
        stored(flat, ExpenseCategory.PHOTO, "99999", from.minusDays(1), agent);
        stored(flat, ExpenseCategory.PHOTO, "99999", to.plusDays(1), agent);

        mockMvc.perform(get("/expenses/summary")
                        .param("from", from.toString()).param("to", to.toString())
                        .header(HttpHeaders.AUTHORIZATION, bearer(manager)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.total").value(125000))
                .andExpect(jsonPath("$.byCategory[0].category").value("ADVERTISING"))
                .andExpect(jsonPath("$.byCategory[0].total").value(85000))
                .andExpect(jsonPath("$.byCategory[1].category").value("PHOTO"))
                .andExpect(jsonPath("$.byCategory[1].total").value(40000))
                .andExpect(jsonPath("$.topListings[0].propertyId").value(colleaguesFlat.getId()))
                .andExpect(jsonPath("$.topListings[0].title").value("Esentai City, apt 12"))
                .andExpect(jsonPath("$.topListings[0].total").value(70000))
                .andExpect(jsonPath("$.topListings[1].propertyId").value(flat.getId()))
                .andExpect(jsonPath("$.topListings[1].total").value(55000));
    }

    @Test
    @DisplayName("an agent on their own records counts their own listings; the manager counts the agency's")
    void summaryFollowsTheDataScope() {
        LocalDate day = today.withDayOfMonth(1);
        stored(flat, ExpenseCategory.PHOTO, "1000", day, agent);
        stored(colleaguesFlat, ExpenseCategory.CLEANING, "5000", day, colleague);
        stored(colleaguesFlat, ExpenseCategory.CLEANING, "700", day, agent);

        ExpenseSummaryResponse own = expenseService.summary(null, null);
        assertThat(own.getFrom()).isEqualTo(day);
        assertThat(own.getTo()).isEqualTo(day.withDayOfMonth(day.lengthOfMonth()));
        assertThat(own.getTotal()).as("only the listing they hold").isEqualByComparingTo("1000");
        assertThat(own.getTopListings()).extracting(ExpenseSummaryResponse.Listing::getPropertyId)
                .containsExactly(flat.getId());

        User teamAgent = user("ex-team@almaty.kz", "Dana Team", Role.AGENT, DataScope.TEAM, almaty);
        signIn(teamAgent);
        assertThat(expenseService.summary(null, null).getTotal()).isEqualByComparingTo("6700");

        signIn(manager);
        ExpenseSummaryResponse agency = expenseService.summary(null, null);
        assertThat(agency.getTotal()).isEqualByComparingTo("6700");
        assertThat(agency.getByCategory()).extracting(ExpenseCategoryTotal::getCategory)
                .containsExactly(ExpenseCategory.CLEANING, ExpenseCategory.PHOTO);
    }

    @Test
    @DisplayName("the summary names at most five listings")
    void topFive() {
        for (int i = 1; i <= 7; i++) {
            Property p = listing("Flat " + i, agent);
            stored(p, ExpenseCategory.ADVERTISING, String.valueOf(i * 1000), today, agent);
        }
        signIn(manager);
        ExpenseSummaryResponse summary = expenseService.summary(today, today);
        assertThat(summary.getTopListings()).extracting(ExpenseSummaryResponse.Listing::getTitle)
                .containsExactly("Flat 7", "Flat 6", "Flat 5", "Flat 4", "Flat 3");
        assertThat(summary.getTotal()).as("the total still counts all of them").isEqualByComparingTo("28000");
    }

    @Test
    @DisplayName("a period that ends before it starts is refused")
    void invalidPeriod() throws Exception {
        mockMvc.perform(get("/expenses/summary")
                        .param("from", "2026-03-10").param("to", "2026-03-09")
                        .header(HttpHeaders.AUTHORIZATION, bearer(manager)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("INVALID_PERIOD"));
        signIn(manager);
        assertThatThrownBy(() -> expenseService.summary(LocalDate.of(2026, 3, 10), LocalDate.of(2026, 3, 9)))
                .isInstanceOf(BusinessException.class)
                .hasFieldOrPropertyWithValue("code", "INVALID_PERIOD");
        assertThat(expenseService.summary(LocalDate.of(2026, 3, 10), LocalDate.of(2026, 3, 10)).getTotal())
                .as("a single day is a period").isEqualByComparingTo("0");
    }

    // What happens to it later ----------------------------------------------------------

    @Test
    @DisplayName("deleting the listing takes its expenses; closing the author's account keeps them")
    void cascades() {
        User author = user("ex-author@almaty.kz", "Short Stay", Role.AGENT, DataScope.TEAM, almaty);
        signIn(author);
        Long kept = expenseService.create(colleaguesFlat.getId(),
                request(ExpenseCategory.LEGAL, "9000", today, null)).getId();
        signIn(agent);
        Long gone = expenseService.create(flat.getId(), request(ExpenseCategory.PHOTO, "1000", today, null)).getId();
        entityManager.flush();
        entityManager.clear();

        propertyRepository.deleteById(flat.getId());
        userRepository.deleteById(author.getId());
        entityManager.flush();
        entityManager.clear();

        assertThat(expenseRepository.findById(gone)).isEmpty();
        PropertyExpense left = expenseRepository.findById(kept).orElseThrow();
        assertThat(left.getCreatedBy()).isNull();
        signIn(manager);
        assertThat(expenseService.forProperty(colleaguesFlat.getId()).getItems()).singleElement()
                .satisfies(e -> {
                    assertThat(e.getCreatedByName()).isNull();
                    assertThat(e.isCanDelete()).isTrue();
                });
    }

    // Helpers ---------------------------------------------------------------------------

    private ResultActions record(Property property, User who, String category, String amount, LocalDate spentOn,
                                 String note) throws Exception {
        String body = "{\"category\":\"" + category + "\",\"amount\":" + amount
                + ",\"spentOn\":\"" + spentOn + "\""
                + (note == null ? "" : ",\"note\":\"" + note + "\"") + "}";
        return mockMvc.perform(post("/properties/{id}/expenses", property.getId())
                .header(HttpHeaders.AUTHORIZATION, bearer(who))
                .contentType(MediaType.APPLICATION_JSON)
                .content(body));
    }

    private static PropertyExpenseRequest request(ExpenseCategory category, String amount, LocalDate spentOn,
                                                  String note) {
        return new PropertyExpenseRequest(category, new BigDecimal(amount), spentOn, note);
    }

    /** Written straight to the table, for days the API would not take today. */
    private void stored(Property property, ExpenseCategory category, String amount, LocalDate spentOn, User by) {
        expenseRepository.save(PropertyExpense.builder()
                .team(property.getTeam()).property(property).category(category)
                .amount(new BigDecimal(amount)).spentOn(spentOn).createdBy(by).build());
    }

    private Property listing(String title, User holder) {
        return propertyRepository.save(Property.builder()
                .title(title).address("Dostyk 5").city("Almaty")
                .type(PropertyType.APARTMENT).status(PropertyStatus.AVAILABLE)
                .price(new BigDecimal("28000000")).rooms(3)
                .agent(holder).team(holder.getTeam()).build());
    }

    private User user(String email, String name, Role role, DataScope scope, Team team) {
        return userRepository.save(User.builder()
                .email(email).password("x").fullName(name)
                .role(role).dataScope(scope).team(team)
                .status(UserStatus.ACTIVE).isActive(true)
                .build());
    }

    /**
     * The token for a request as {@code who}. The JWT filter keeps an authentication that is
     * already there, and MockMvc carries over the one the test context last held, so both are
     * cleared and the token alone says who is asking. Service calls after it sign in again.
     */
    private String bearer(User who) {
        TestSecurityContextHolder.clearContext();
        return "Bearer " + jwtService.generateAccessToken(who);
    }

    private void signIn(User who) {
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(who.getEmail(), null, List.of()));
    }
}
