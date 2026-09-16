package com.crm.realestate.integration;

import com.crm.realestate.dto.request.AddMemberRequest;
import com.crm.realestate.dto.request.TeamNameRequest;
import com.crm.realestate.dto.response.AddMemberResponse;
import com.crm.realestate.dto.response.JoinRequestResponse;
import com.crm.realestate.dto.response.TeamResponse;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.JoinRequestStatus;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.TeamJoinRequestRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.service.EmailService;
import com.crm.realestate.service.TeamMembershipService;
import jakarta.persistence.EntityManager;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Getting into an agency, and out of it again.
 *
 * <p>The rule these tests are really about: a manager cannot help themselves to an existing
 * account. Joining a team exposes that agent's clients and deals to the manager, so it takes the
 * agent's yes — and when they go, the work stays behind.
 */
@SpringBootTest
@AutoConfigureMockMvc(addFilters = false)
@Transactional
class TeamMembershipTest {

    @Autowired private TeamMembershipService membership;
    @Autowired private UserRepository userRepository;
    @Autowired private TeamRepository teamRepository;
    @Autowired private TeamJoinRequestRepository requestRepository;
    @Autowired private ClientRepository clientRepository;
    @Autowired private DealRepository dealRepository;
    @Autowired private EntityManager entityManager;
    @Autowired private MockMvc mockMvc;

    @MockBean private EmailService emailService;

    private User manager;
    private User agent;

    @BeforeEach
    void setUp() {
        SecurityContextHolder.clearContext();
        dealRepository.deleteAll();
        clientRepository.deleteAll();
        requestRepository.deleteAll();
        userRepository.deleteAll();
        teamRepository.deleteAll();

        manager = user("manager@almaty.kz", Role.MANAGER, DataScope.OWN, null);
        agent = user("agent@almaty.kz", Role.AGENT, DataScope.OWN, null);
    }

    // Starting an agency ---------------------------------------------------------------

    @Test
    @DisplayName("a manager opens their agency and it becomes theirs to see")
    void createsTheirOwnTeam() {
        Client before = client("Timur", manager);

        TeamResponse team = membership.createMyTeam(manager, teamName("Almaty Realty"));

        assertThat(team.getName()).isEqualTo("Almaty Realty");
        assertThat(team.getManagerId()).isEqualTo(manager.getId());
        User stored = userRepository.findById(manager.getId()).orElseThrow();
        assertThat(stored.getTeam().getId()).isEqualTo(team.getId());
        assertThat(stored.getDataScope())
                .as("a manager who could only see their own records cannot run an agency")
                .isEqualTo(DataScope.TEAM);
        entityManager.flush();
        entityManager.clear();
        assertThat(clientRepository.findById(before.getId()).orElseThrow().getTeam().getId())
                .as("what the manager already had comes into the agency with them")
                .isEqualTo(team.getId());
    }

    @Test
    @DisplayName("one agency per manager")
    void refusesASecondTeam() {
        membership.createMyTeam(manager, teamName("Almaty Realty"));

        assertThatThrownBy(() -> membership.createMyTeam(manager, teamName("Another")))
                .isInstanceOf(BusinessException.class)
                .extracting(e -> ((BusinessException) e).getCode())
                .isEqualTo("ALREADY_HAS_TEAM");
    }

    @Test
    @DisplayName("without an agency there is no CRM to open")
    void crmIsShutWithoutATeam() throws Exception {
        signIn(agent);

        mockMvc.perform(get("/clients"))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.code").value("TEAM_REQUIRED"));
    }

    // Adding people --------------------------------------------------------------------

    @Test
    @DisplayName("adding an agent who has an account asks them first")
    void addingAnExistingAgentSendsARequest() {
        Team team = createTeam();

        AddMemberResponse response = membership.addMember(manager, addMember(agent.getEmail()));

        assertThat(response.getResult()).isEqualTo(AddMemberResponse.Result.REQUEST_SENT);
        assertThat(response.getRequest().getTeamName()).isEqualTo(team.getName());
        assertThat(userRepository.findById(agent.getId()).orElseThrow().getTeam())
                .as("nobody is moved into a team without agreeing to it")
                .isNull();
        assertThat(requestRepository.existsByTeamIdAndUserIdAndStatus(
                team.getId(), agent.getId(), JoinRequestStatus.PENDING)).isTrue();
    }

    @Test
    @DisplayName("asking twice is refused rather than sending two requests")
    void doubleRequestIsRefused() {
        createTeam();
        membership.addMember(manager, addMember(agent.getEmail()));

        assertThatThrownBy(() -> membership.addMember(manager, addMember(agent.getEmail())))
                .isInstanceOf(BusinessException.class)
                .extracting(e -> ((BusinessException) e).getCode())
                .isEqualTo("REQUEST_PENDING");
    }

    @Test
    @DisplayName("an address nobody has registered gets an invite instead")
    void addingAnUnknownAddressInvitesThem() {
        Team team = createTeam();

        AddMemberResponse response = membership.addMember(manager, addMember("newcomer@almaty.kz"));

        assertThat(response.getResult()).isEqualTo(AddMemberResponse.Result.INVITE_SENT);
        User invited = userRepository.findFirstByEmailIgnoreCase("newcomer@almaty.kz").orElseThrow();
        assertThat(invited.getStatus()).isEqualTo(UserStatus.PENDING_INVITE);
        assertThat(invited.getTeam().getId()).isEqualTo(team.getId());
    }

    @Test
    @DisplayName("an agent who belongs to another agency cannot be taken")
    void anotherAgencysAgentIsRefused() {
        createTeam();
        Team elsewhere = teamRepository.save(Team.builder().name("Astana Homes").build());
        agent.setTeam(elsewhere);
        userRepository.save(agent);

        assertThatThrownBy(() -> membership.addMember(manager, addMember(agent.getEmail())))
                .isInstanceOf(BusinessException.class)
                .extracting(e -> ((BusinessException) e).getCode())
                .isEqualTo("ALREADY_IN_TEAM");
    }

    @Test
    @DisplayName("only agent accounts can be added")
    void managersCannotBeAdded() {
        createTeam();
        User otherManager = user("other@astana.kz", Role.MANAGER, DataScope.TEAM, null);

        assertThatThrownBy(() -> membership.addMember(manager, addMember(otherManager.getEmail())))
                .isInstanceOf(BusinessException.class)
                .extracting(e -> ((BusinessException) e).getCode())
                .isEqualTo("NOT_AN_AGENT");
    }

    // Answering ------------------------------------------------------------------------

    @Test
    @DisplayName("accepting joins the team and brings the agent's own records in")
    void acceptingJoinsTheTeam() {
        Team team = createTeam();
        Client mine = client("Aigerim", agent);
        Long requestId = membership.addMember(manager, addMember(agent.getEmail())).getRequest().getId();
        Team other = teamRepository.save(Team.builder().name("Astana Homes").build());
        requestRepository.save(com.crm.realestate.entity.TeamJoinRequest.builder()
                .team(other).user(agent).status(JoinRequestStatus.PENDING).build());

        membership.acceptRequest(agent, requestId);
        entityManager.flush();
        entityManager.clear();

        assertThat(userRepository.findById(agent.getId()).orElseThrow().getTeam().getId())
                .isEqualTo(team.getId());
        assertThat(clientRepository.findById(mine.getId()).orElseThrow().getTeam().getId())
                .isEqualTo(team.getId());
        assertThat(requestRepository.findByUserIdAndStatusOrderByCreatedAtDesc(
                agent.getId(), JoinRequestStatus.PENDING))
                .as("joining one agency makes every other invitation moot")
                .isEmpty();
    }

    @Test
    @DisplayName("declining leaves the agent where they were")
    void decliningKeepsThemOut() {
        createTeam();
        Long requestId = membership.addMember(manager, addMember(agent.getEmail())).getRequest().getId();

        membership.declineRequest(agent, requestId);

        assertThat(userRepository.findById(agent.getId()).orElseThrow().getTeam()).isNull();
        assertThat(requestRepository.findById(requestId).orElseThrow().getStatus())
                .isEqualTo(JoinRequestStatus.DECLINED);
    }

    @Test
    @DisplayName("somebody else's request is not yours to answer")
    void cannotAnswerSomeoneElsesRequest() {
        createTeam();
        User bystander = user("bystander@almaty.kz", Role.AGENT, DataScope.OWN, null);
        Long requestId = membership.addMember(manager, addMember(agent.getEmail())).getRequest().getId();

        assertThatThrownBy(() -> membership.acceptRequest(bystander, requestId))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    @DisplayName("a manager can withdraw a request while it is unanswered")
    void requestsCanBeWithdrawn() {
        createTeam();
        Long requestId = membership.addMember(manager, addMember(agent.getEmail())).getRequest().getId();

        assertThat(membership.getOutgoingRequests(manager)).extracting(JoinRequestResponse::getId)
                .containsExactly(requestId);
        membership.cancelRequest(manager, requestId);

        assertThat(membership.getOutgoingRequests(manager)).isEmpty();
        assertThatThrownBy(() -> membership.acceptRequest(agent, requestId))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    // Leaving --------------------------------------------------------------------------

    @Test
    @DisplayName("an agent taken off the team leaves the work behind")
    void removingAnAgentKeepsTheirWorkInTheTeam() {
        Team team = joinedTeam();
        Client theirClient = client("Aigerim", agent);
        Deal theirDeal = deal(theirClient, agent);

        membership.removeMember(manager, agent.getId(), null);
        entityManager.flush();
        entityManager.clear();

        User removed = userRepository.findById(agent.getId()).orElseThrow();
        assertThat(removed.getTeam()).isNull();
        assertThat(removed.getDataScope()).isEqualTo(DataScope.OWN);
        Client client = clientRepository.findById(theirClient.getId()).orElseThrow();
        assertThat(client.getTeam().getId()).as("the records belong to the agency").isEqualTo(team.getId());
        assertThat(client.getAgent().getId()).isEqualTo(manager.getId());
        assertThat(dealRepository.findById(theirDeal.getId()).orElseThrow().getAgent().getId())
                .isEqualTo(manager.getId());
    }

    @Test
    @DisplayName("the work can be handed to a chosen colleague instead of the manager")
    void removalCanNominateASuccessor() {
        Team team = joinedTeam();
        User colleague = user("colleague@almaty.kz", Role.AGENT, DataScope.OWN, team);
        Client theirClient = client("Aigerim", agent);

        membership.removeMember(manager, agent.getId(), colleague.getId());
        entityManager.flush();
        entityManager.clear();

        assertThat(clientRepository.findById(theirClient.getId()).orElseThrow().getAgent().getId())
                .isEqualTo(colleague.getId());
    }

    @Test
    @DisplayName("the successor has to work in the same agency")
    void successorFromAnotherAgencyIsRefused() {
        joinedTeam();
        Team elsewhere = teamRepository.save(Team.builder().name("Astana Homes").build());
        User stranger = user("stranger@astana.kz", Role.AGENT, DataScope.OWN, elsewhere);
        client("Aigerim", agent);

        assertThatThrownBy(() -> membership.removeMember(manager, agent.getId(), stranger.getId()))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    @DisplayName("revoking an invite nobody used simply removes it")
    void removingAPendingInviteDeletesIt() {
        createTeam();
        membership.addMember(manager, addMember("newcomer@almaty.kz"));
        Long invitedId = userRepository.findFirstByEmailIgnoreCase("newcomer@almaty.kz").orElseThrow().getId();

        membership.removeMember(manager, invitedId, null);

        assertThat(userRepository.findById(invitedId)).isEmpty();
    }

    @Test
    @DisplayName("a manager cannot remove themselves from the agency they run")
    void managerCannotRemoveThemselves() {
        createTeam();

        assertThatThrownBy(() -> membership.removeMember(manager, manager.getId(), null))
                .isInstanceOf(BusinessException.class)
                .extracting(e -> ((BusinessException) e).getCode())
                .isEqualTo("CANNOT_REMOVE_SELF");
    }

    @Test
    @DisplayName("an agent who leaves hands their work to the manager")
    void leavingHandsTheWorkOver() {
        Team team = joinedTeam();
        Client theirClient = client("Aigerim", agent);

        membership.leaveTeam(agent);
        entityManager.flush();
        entityManager.clear();

        assertThat(userRepository.findById(agent.getId()).orElseThrow().getTeam()).isNull();
        Client client = clientRepository.findById(theirClient.getId()).orElseThrow();
        assertThat(client.getTeam().getId()).isEqualTo(team.getId());
        assertThat(client.getAgent().getId()).isEqualTo(manager.getId());
    }

    @Test
    @DisplayName("a manager cannot walk out of their own agency")
    void managerCannotLeaveTheirOwnTeam() {
        createTeam();

        assertThatThrownBy(() -> membership.leaveTeam(manager))
                .isInstanceOf(BusinessException.class)
                .extracting(e -> ((BusinessException) e).getCode())
                .isEqualTo("NOT_AN_AGENT");
    }

    @Test
    @DisplayName("the team lists its people, the manager first")
    void listsTheTeam() {
        joinedTeam();

        assertThat(membership.getMembers(manager))
                .extracting(m -> m.getEmail())
                .containsExactly(manager.getEmail(), agent.getEmail());
        assertThat(membership.getMembers(manager).get(0).isTeamManager()).isTrue();
    }

    // Fixtures -------------------------------------------------------------------------

    private void signIn(User who) {
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(who.getEmail(), null, List.of()));
    }

    private Team createTeam() {
        TeamResponse response = membership.createMyTeam(manager, teamName("Almaty Realty"));
        return teamRepository.findById(response.getId()).orElseThrow();
    }

    /** The agency with the agent already in it, the way accepting a request leaves things. */
    private Team joinedTeam() {
        Team team = createTeam();
        Long requestId = membership.addMember(manager, addMember(agent.getEmail())).getRequest().getId();
        membership.acceptRequest(agent, requestId);
        return team;
    }

    private TeamNameRequest teamName(String name) {
        TeamNameRequest request = new TeamNameRequest();
        request.setName(name);
        return request;
    }

    private AddMemberRequest addMember(String email) {
        AddMemberRequest request = new AddMemberRequest();
        request.setEmail(email);
        request.setFullName("Aigerim Serikbaykyzy");
        return request;
    }

    private User user(String email, Role role, DataScope scope, Team team) {
        return userRepository.save(User.builder()
                .email(email).password("x").fullName(email)
                .role(role).dataScope(scope).team(team)
                .status(UserStatus.ACTIVE).isActive(true)
                .build());
    }

    private Client client(String name, User owner) {
        return clientRepository.save(Client.builder()
                .fullName(name).type(ClientType.BUYER)
                .agent(owner).team(owner.getTeam())
                .build());
    }

    private Deal deal(Client client, User owner) {
        return dealRepository.save(Deal.builder()
                .title("Deal for " + client.getFullName()).status(DealStatus.LEAD)
                .client(client).agent(owner).team(client.getTeam())
                .build());
    }
}
