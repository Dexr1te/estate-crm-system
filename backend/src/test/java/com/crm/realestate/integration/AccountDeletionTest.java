package com.crm.realestate.integration;

import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.service.AccountRemovalService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.transaction.annotation.Transactional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

/**
 * Closing your own account — required by App Store Review Guideline 5.1.1(v).
 *
 * <p>What matters is that the account goes and the agency's records do not: deals, meetings and
 * documents belong to the business, so they change hands rather than disappearing with the leaver.
 */
@SpringBootTest
@Transactional
public class AccountDeletionTest {

    private static final String PRIMARY_ADMIN = "owner@example.com";

    @Autowired
    private AccountRemovalService accountRemovalService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ClientRepository clientRepository;

    @Autowired
    private DealRepository dealRepository;

    private User leaver;
    private User successor;

    @BeforeEach
    public void setUp() {
        dealRepository.deleteAll();
        clientRepository.deleteAll();
        userRepository.deleteAll();
        ReflectionTestUtils.setField(accountRemovalService, "primaryAdminEmail", PRIMARY_ADMIN);

        leaver = save("leaver@example.com", Role.AGENT);
        successor = save("successor@example.com", Role.AGENT);
    }

    private User save(String email, Role role) {
        return userRepository.save(User.builder()
                .email(email)
                .password("secret")
                .fullName(email)
                .role(role)
                .dataScope(DataScope.OWN)
                .status(UserStatus.ACTIVE)
                .isActive(true)
                .build());
    }

    private Deal dealFor(User agent) {
        Client client = clientRepository.save(Client.builder()
                .fullName("Client of " + agent.getEmail())
                .type(ClientType.BUYER)
                .agent(agent)
                .build());
        return dealRepository.save(Deal.builder()
                .title("Deal of " + agent.getEmail())
                .client(client)
                .agent(agent)
                .status(DealStatus.LEAD)
                .build());
    }

    @Test
    @DisplayName("an account with nothing attached can simply be closed")
    public void deletesAnEmptyAccount() {
        accountRemovalService.removeOwnAccount(leaver, null);

        assertThat(userRepository.findByEmail(leaver.getEmail())).isEmpty();
    }

    @Test
    @DisplayName("the agency keeps the work, the successor inherits it")
    public void handsRecordsToTheSuccessor() {
        Long dealId = dealFor(leaver).getId();

        accountRemovalService.removeOwnAccount(leaver, successor.getId());

        assertThat(userRepository.findByEmail(leaver.getEmail())).isEmpty();
        assertThat(dealRepository.findById(dealId))
                .as("a departing agent must not take the agency's deals with them")
                .isPresent()
                .get()
                .extracting(d -> d.getAgent().getId())
                .isEqualTo(successor.getId());
    }

    @Test
    @DisplayName("leaving records behind with nobody to hold them is refused")
    public void refusesToOrphanRecords() {
        dealFor(leaver);

        assertThatThrownBy(() -> accountRemovalService.removeOwnAccount(leaver, null))
                .hasMessageContaining("Choose someone to take them over");

        assertThat(userRepository.findByEmail(leaver.getEmail())).isPresent();
    }

    @Test
    @DisplayName("the primary admin cannot delete the account the deployment hangs on")
    public void refusesThePrimaryAdmin() {
        User owner = save(PRIMARY_ADMIN, Role.ADMIN);

        assertThatThrownBy(() -> accountRemovalService.removeOwnAccount(owner, null))
                .isInstanceOf(AccessDeniedException.class)
                .hasMessageContaining("Contact support");

        assertThat(userRepository.findByEmail(PRIMARY_ADMIN)).isPresent();
    }

    @Test
    @DisplayName("the last active admin cannot lock everyone else out on the way out")
    public void refusesTheLastAdmin() {
        User onlyAdmin = save("admin@example.com", Role.ADMIN);

        assertThatThrownBy(() -> accountRemovalService.removeOwnAccount(onlyAdmin, null))
                .isInstanceOf(AccessDeniedException.class)
                .hasMessageContaining("last active admin");

        assertThat(userRepository.findByEmail("admin@example.com")).isPresent();
    }

    @Test
    @DisplayName("handing your records to yourself is not a handover")
    public void refusesSelfAsSuccessor() {
        dealFor(leaver);

        assertThatThrownBy(
                () -> accountRemovalService.removeOwnAccount(leaver, leaver.getId()))
                .hasMessageContaining("Pick a different user");
    }
}
