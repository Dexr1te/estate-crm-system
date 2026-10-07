package com.crm.realestate.integration;

import com.crm.realestate.dto.request.DealCommentRequest;
import com.crm.realestate.dto.response.DealCommentPage;
import com.crm.realestate.dto.response.DealCommentResponse;
import com.crm.realestate.dto.response.DealResponse;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.DealComment;
import com.crm.realestate.entity.Notification;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.NotificationType;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealCommentMentionRepository;
import com.crm.realestate.repository.DealCommentRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.NotificationRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.service.AccountRemovalService;
import com.crm.realestate.service.DealCommentService;
import com.crm.realestate.service.DealService;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import org.hibernate.SessionFactory;
import org.hibernate.stat.Statistics;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.stream.IntStream;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * The discussion on a deal — comments, @mentions, and who hears about them.
 *
 * <p>The discussion sits behind exactly the deal's walls: another agency's deal answers not found,
 * and an agent on their own deals cannot read a colleague's. A mention can only bring in somebody
 * who could open the deal. It goes with the deal, and stays when the person who wrote it leaves.
 */
@SpringBootTest
@AutoConfigureMockMvc(addFilters = false)
@Transactional
class DealCommentTest {

    @Autowired private MockMvc mockMvc;
    @Autowired private DealCommentService commentService;
    @Autowired private DealService dealService;
    @Autowired private AccountRemovalService accountRemovalService;
    @Autowired private ObjectMapper objectMapper;

    @Autowired private DealCommentRepository commentRepository;
    @Autowired private DealCommentMentionRepository mentionRepository;
    @Autowired private NotificationRepository notificationRepository;
    @Autowired private DealRepository dealRepository;
    @Autowired private ClientRepository clientRepository;
    @Autowired private UserRepository userRepository;
    @Autowired private TeamRepository teamRepository;
    @Autowired private EntityManager entityManager;
    @Autowired private EntityManagerFactory entityManagerFactory;

    private Team almaty;
    private User manager;
    private User agent;
    private User colleague;
    private User ownOnly;
    private User stranger;
    private Deal flat;
    private Deal strangersDeal;

    @BeforeEach
    void setUp() {
        SecurityContextHolder.clearContext();
        notificationRepository.deleteAll();
        commentRepository.deleteAll();
        dealRepository.deleteAll();
        clientRepository.deleteAll();
        userRepository.deleteAll();
        teamRepository.deleteAll();
        ReflectionTestUtils.setField(accountRemovalService, "primaryAdminEmail", "owner@estatecrm.app");

        almaty = teamRepository.save(Team.builder().name("Almaty Realty").build());
        Team astana = teamRepository.save(Team.builder().name("Astana Homes").build());

        manager = user("manager@almaty.kz", "Asel Nurlanovna", Role.MANAGER, DataScope.TEAM, almaty);
        agent = user("agent@almaty.kz", "Aigul Bekova", Role.AGENT, DataScope.OWN, almaty);
        colleague = user("colleague@almaty.kz", "Timur Aliev", Role.AGENT, DataScope.TEAM, almaty);
        ownOnly = user("own@almaty.kz", "Dana Seitova", Role.AGENT, DataScope.OWN, almaty);
        stranger = user("manager@astana.kz", "Yerlan Sadykov", Role.MANAGER, DataScope.TEAM, astana);

        flat = deal("Dostyk 5, flat 12", agent, almaty);
        strangersDeal = deal("Left bank tower", stranger, astana);
    }

    // Writing and reading --------------------------------------------------------------

    @Test
    @DisplayName("over HTTP: created is 201, read back oldest first, edited by its author, deleted is 204")
    void endpoints() throws Exception {
        signIn(agent);
        mockMvc.perform(post("/deals/" + flat.getId() + "/comments")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"body\":\"  Owner agreed to 5% off  \"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.body").value("Owner agreed to 5% off"))
                .andExpect(jsonPath("$.authorName").value("Aigul Bekova"))
                .andExpect(jsonPath("$.editedAt").doesNotExist());
        signIn(manager);
        mockMvc.perform(post("/deals/" + flat.getId() + "/comments")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"body\":\"Good, get it in writing\"}"))
                .andExpect(status().isCreated());

        mockMvc.perform(get("/deals/" + flat.getId() + "/comments"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.hasEarlier").value(false))
                .andExpect(jsonPath("$.comments.length()").value(2))
                .andExpect(jsonPath("$.comments[0].body").value("Owner agreed to 5% off"))
                .andExpect(jsonPath("$.comments[1].body").value("Good, get it in writing"));

        Long first = commentRepository.findAll().stream()
                .filter(c -> c.getBody().startsWith("Owner")).findFirst().orElseThrow().getId();
        signIn(agent);
        mockMvc.perform(put("/deals/" + flat.getId() + "/comments/" + first)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"body\":\"Owner agreed to 4% off\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.body").value("Owner agreed to 4% off"))
                .andExpect(jsonPath("$.editedAt").exists());

        mockMvc.perform(delete("/deals/" + flat.getId() + "/comments/" + first))
                .andExpect(status().isNoContent());
        assertThat(commentRepository.findById(first)).isEmpty();
    }

    @Test
    @DisplayName("a comment needs text, and no more than 4000 characters of it")
    void validatesTheBody() throws Exception {
        signIn(agent);
        mockMvc.perform(post("/deals/" + flat.getId() + "/comments")
                        .contentType(MediaType.APPLICATION_JSON).content("{\"body\":\"   \"}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("COMMENT_BODY_REQUIRED"));
        assertThatThrownBy(() -> commentService.create(flat.getId(), request("x".repeat(4001))))
                .isInstanceOf(BusinessException.class);
        assertThat(commentService.create(flat.getId(), request("x".repeat(4000))).getBody()).hasSize(4000);
    }

    @Test
    @DisplayName("a long discussion comes in pages: the latest first, then what came before")
    void pages() {
        signIn(agent);
        IntStream.rangeClosed(1, 5).forEach(i -> commentService.create(flat.getId(), request("Note " + i)));

        DealCommentPage latest = commentService.list(flat.getId(), null, 2);
        assertThat(latest.getComments()).extracting(DealCommentResponse::getBody)
                .containsExactly("Note 4", "Note 5");
        assertThat(latest.isHasEarlier()).isTrue();

        DealCommentPage earlier = commentService.list(flat.getId(), latest.getComments().get(0).getId(), 2);
        assertThat(earlier.getComments()).extracting(DealCommentResponse::getBody)
                .containsExactly("Note 2", "Note 3");
        assertThat(earlier.isHasEarlier()).isTrue();

        DealCommentPage rest = commentService.list(flat.getId(), earlier.getComments().get(0).getId(), 2);
        assertThat(rest.getComments()).extracting(DealCommentResponse::getBody).containsExactly("Note 1");
        assertThat(rest.isHasEarlier()).isFalse();
    }

    // Rights --------------------------------------------------------------------------

    @Test
    @DisplayName("only the author edits; the author, a manager or an admin deletes")
    void editAndDeleteRights() throws Exception {
        signIn(agent);
        Long mine = commentService.create(flat.getId(), request("Viewing moved to Friday")).getId();

        signIn(manager);
        assertThatThrownBy(() -> commentService.update(flat.getId(), mine, request("Rewritten")))
                .as("a manager may take a comment down but not put words in the author's mouth")
                .isInstanceOf(AccessDeniedException.class);

        signIn(colleague);
        mockMvc.perform(put("/deals/" + flat.getId() + "/comments/" + mine)
                        .contentType(MediaType.APPLICATION_JSON).content("{\"body\":\"Mine now\"}"))
                .andExpect(status().isForbidden());
        mockMvc.perform(delete("/deals/" + flat.getId() + "/comments/" + mine))
                .andExpect(status().isForbidden());

        signIn(manager);
        mockMvc.perform(delete("/deals/" + flat.getId() + "/comments/" + mine))
                .andExpect(status().isNoContent());
        assertThat(commentRepository.findById(mine)).isEmpty();
    }

    // Walls ---------------------------------------------------------------------------

    @Test
    @DisplayName("another agency's deal, or a colleague's deal to an agent on their own, reads as not found")
    void discussionHasTheDealsWalls() throws Exception {
        signIn(stranger);
        Long theirs = commentService.create(strangersDeal.getId(), request("Ours")).getId();

        signIn(agent);
        mockMvc.perform(get("/deals/" + strangersDeal.getId() + "/comments")).andExpect(status().isNotFound());
        mockMvc.perform(post("/deals/" + strangersDeal.getId() + "/comments")
                        .contentType(MediaType.APPLICATION_JSON).content("{\"body\":\"Hi\"}"))
                .andExpect(status().isNotFound());
        mockMvc.perform(delete("/deals/" + strangersDeal.getId() + "/comments/" + theirs))
                .andExpect(status().isNotFound());
        // A comment is reached only through its own deal.
        mockMvc.perform(delete("/deals/" + flat.getId() + "/comments/" + theirs))
                .andExpect(status().isNotFound());

        signIn(ownOnly);
        mockMvc.perform(get("/deals/" + flat.getId() + "/comments")).andExpect(status().isNotFound());
        assertThat(commentRepository.findById(theirs)).isPresent();
    }

    // Mentions ------------------------------------------------------------------------

    @Test
    @DisplayName("a mention of a colleague who can see the deal is kept and returned with their name")
    void mentionsAColleague() throws Exception {
        signIn(agent);
        mockMvc.perform(post("/deals/" + flat.getId() + "/comments")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"body\":\"@Timur Aliev can you cover the viewing?\",\"mentionedUserIds\":["
                                + colleague.getId() + "," + manager.getId() + "," + colleague.getId() + "]}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.mentions.length()").value(2));

        DealCommentResponse read = commentService.list(flat.getId(), null, null).getComments().get(0);
        assertThat(read.getMentions()).extracting(DealCommentResponse.MentionRef::getFullName)
                .containsExactlyInAnyOrder("Timur Aliev", "Asel Nurlanovna");
    }

    @Test
    @DisplayName("mentioning someone who could not open the deal is refused with 400, and nothing is saved")
    void refusesMentionsOfPeopleWhoCannotSeeTheDeal() throws Exception {
        signIn(agent);
        for (Long who : List.of(stranger.getId(), ownOnly.getId(), 999_999L)) {
            mockMvc.perform(post("/deals/" + flat.getId() + "/comments")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content("{\"body\":\"Look at this\",\"mentionedUserIds\":[" + who + "]}"))
                    .andExpect(status().isBadRequest())
                    .andExpect(jsonPath("$.code").value("MENTION_NOT_ALLOWED"));
        }
        User gone = user("gone@almaty.kz", "Former Agent", Role.AGENT, DataScope.TEAM, almaty);
        gone.setStatus(UserStatus.DEACTIVATED);
        userRepository.save(gone);
        assertThatThrownBy(() -> commentService.create(flat.getId(),
                request("Hi", gone.getId()))).isInstanceOf(BusinessException.class);

        assertThat(commentRepository.findAll()).isEmpty();
        assertThat(notificationRepository.findAll()).isEmpty();
    }

    @Test
    @DisplayName("the people offered for a mention are exactly those who could open the deal")
    void mentionable() throws Exception {
        signIn(agent);
        mockMvc.perform(get("/deals/" + flat.getId() + "/comments/mentionable"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(3))
                .andExpect(jsonPath("$[0].fullName").value("Aigul Bekova"))
                .andExpect(jsonPath("$[1].fullName").value("Asel Nurlanovna"))
                .andExpect(jsonPath("$[2].fullName").value("Timur Aliev"));
        signIn(stranger);
        mockMvc.perform(get("/deals/" + flat.getId() + "/comments/mentionable"))
                .andExpect(status().isNotFound());
    }

    // Notifications -------------------------------------------------------------------

    @Test
    @DisplayName("the mentioned hear they were mentioned, the deal's agent hears of the comment, the author hears nothing")
    void notifiesMentionedAndAgent() {
        signIn(manager);
        String body = "@Timur Aliev please cover the Saturday viewing, " + "the owner is flexible ".repeat(10);
        commentService.create(flat.getId(), request(body, colleague.getId()));

        List<Notification> timur = feed(colleague);
        assertThat(timur).hasSize(1);
        assertThat(timur.get(0).getType()).isEqualTo(NotificationType.DEAL_MENTION);
        assertThat(timur.get(0).getTargetId()).isEqualTo(flat.getId());
        Map<String, Object> params = params(timur.get(0));
        assertThat(params).containsEntry("dealTitle", "Dostyk 5, flat 12")
                .containsEntry("authorName", "Asel Nurlanovna");
        String snippet = (String) params.get("snippet");
        assertThat(snippet).hasSizeLessThanOrEqualTo(120).startsWith("@Timur Aliev please cover").endsWith("…");

        List<Notification> aigul = feed(agent);
        assertThat(aigul).extracting(Notification::getType).containsExactly(NotificationType.DEAL_COMMENT);
        assertThat(feed(manager)).as("never the author").isEmpty();
    }

    @Test
    @DisplayName("an agent who is mentioned on their own deal hears it once, as a mention")
    void noDoubleNotification() {
        signIn(manager);
        commentService.create(flat.getId(), request("@Aigul Bekova call the owner", agent.getId(), agent.getId()));
        assertThat(feed(agent)).extracting(Notification::getType).containsExactly(NotificationType.DEAL_MENTION);
    }

    @Test
    @DisplayName("the agent commenting on their own deal tells nobody, and mentioning yourself tells nobody")
    void authorIsNeverTold() {
        signIn(agent);
        commentService.create(flat.getId(), request("Note to self @Aigul Bekova", agent.getId()));
        entityManager.flush();
        assertThat(notificationRepository.findAll()).isEmpty();
    }

    @Test
    @DisplayName("an edit that adds a mention tells only the person just added")
    void editTellsOnlyNewMentions() {
        signIn(agent);
        Long id = commentService.create(flat.getId(), request("@Timur Aliev FYI", colleague.getId())).getId();
        commentService.update(flat.getId(), id, request("@Timur Aliev @Asel Nurlanovna FYI",
                colleague.getId(), manager.getId()));

        assertThat(feed(colleague)).hasSize(1);
        assertThat(feed(manager)).extracting(Notification::getType).containsExactly(NotificationType.DEAL_MENTION);
        DealCommentResponse read = commentService.list(flat.getId(), null, null).getComments().get(0);
        assertThat(read.getMentions()).hasSize(2);
        assertThat(read.getEditedAt()).isNotNull();
    }

    // The deal list --------------------------------------------------------------------

    @Test
    @DisplayName("the deal list carries each deal's comment count at a cost that does not grow with the list")
    void commentCountOnTheList() {
        signIn(manager);
        seedDealsWithComments(2);
        long few = countStatementsListingDeals();
        seedDealsWithComments(10);
        long many = countStatementsListingDeals();
        assertThat(many).isEqualTo(few);

        commentService.create(flat.getId(), request("One"));
        commentService.create(flat.getId(), request("Two"));
        entityManager.flush();
        DealResponse listed = dealService.getAll().stream()
                .filter(d -> d.getId().equals(flat.getId())).findFirst().orElseThrow();
        assertThat(listed.getCommentCount()).isEqualTo(2);
        assertThat(dealService.getById(flat.getId()).getCommentCount()).isEqualTo(2);
    }

    // Lifecycle -----------------------------------------------------------------------

    @Test
    @DisplayName("deleting a deal takes its discussion and mentions with it")
    void goesWithTheDeal() {
        signIn(agent);
        Long id = commentService.create(flat.getId(), request("@Timur Aliev hi", colleague.getId())).getId();
        entityManager.flush();
        entityManager.clear();

        dealRepository.deleteById(flat.getId());
        entityManager.flush();
        entityManager.clear();

        assertThat(commentRepository.findById(id)).isEmpty();
        assertThat(mentionRepository.findAll()).isEmpty();
    }

    @Test
    @DisplayName("when the author's account is closed the comment stays, under the name it was written with")
    void outlivesItsAuthor() {
        signIn(colleague);
        Long id = commentService.create(flat.getId(), request("Covered the viewing, they liked it")).getId();
        entityManager.flush();
        entityManager.clear();

        accountRemovalService.removeOwnAccount(userRepository.findById(colleague.getId()).orElseThrow(), null);
        entityManager.flush();
        entityManager.clear();

        DealComment kept = commentRepository.findById(id).orElseThrow();
        assertThat(kept.getAuthor()).isNull();

        signIn(manager);
        DealCommentResponse read = commentService.list(flat.getId(), null, null).getComments().get(0);
        assertThat(read.getAuthorId()).isNull();
        assertThat(read.getAuthorName()).isEqualTo("Timur Aliev");
        assertThat(read.getBody()).isEqualTo("Covered the viewing, they liked it");
    }

    private void seedDealsWithComments(int count) {
        IntStream.range(0, count).forEach(i -> {
            Deal d = deal("Deal " + i, agent, almaty);
            commentRepository.save(DealComment.builder().deal(d).team(almaty).author(agent)
                    .authorName("Aigul Bekova").body("Comment on " + i).build());
        });
        entityManager.flush();
        entityManager.clear();
    }

    private long countStatementsListingDeals() {
        Statistics stats = entityManagerFactory.unwrap(SessionFactory.class).getStatistics();
        entityManager.clear();
        stats.clear();
        dealService.getAll();
        return stats.getPrepareStatementCount();
    }

    private List<Notification> feed(User who) {
        entityManager.flush();
        return notificationRepository.findByRecipientId(who.getId());
    }

    @SuppressWarnings("unchecked")
    private Map<String, Object> params(Notification n) {
        try {
            return objectMapper.readValue(n.getPayload(), Map.class);
        } catch (Exception e) {
            throw new IllegalStateException(e);
        }
    }

    private static DealCommentRequest request(String body, Long... mentioned) {
        DealCommentRequest request = new DealCommentRequest();
        request.setBody(body);
        request.setMentionedUserIds(List.of(mentioned));
        return request;
    }

    private Deal deal(String title, User holder, Team team) {
        Client client = clientRepository.save(Client.builder()
                .fullName("Buyer of " + title).type(ClientType.BUYER).agent(holder).team(team).build());
        return dealRepository.save(Deal.builder()
                .title(title).status(DealStatus.LEAD).client(client).agent(holder).team(team).build());
    }

    private User user(String email, String name, Role role, DataScope scope, Team team) {
        return userRepository.save(User.builder()
                .email(email).password("x").fullName(name)
                .role(role).dataScope(scope).team(team)
                .status(UserStatus.ACTIVE).isActive(true)
                .build());
    }

    private void signIn(User who) {
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(who.getEmail(), null, List.of()));
    }
}
