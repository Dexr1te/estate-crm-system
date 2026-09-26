package com.crm.realestate.service;

import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.ClientActivity;
import com.crm.realestate.entity.ClientActivityProperty;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.PropertyShareLink;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ActivityType;
import com.crm.realestate.enums.ClientSource;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.repository.ClientActivityPropertyRepository;
import com.crm.realestate.repository.ClientActivityRepository;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.PropertyShareLinkRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.Optional;

/**
 * "I'm interested" from a listing's public page: a stranger leaves a name and a number, and the
 * listing's agent gets a client, a line in that client's history pointing at the listing, and a
 * notification.
 *
 * <p>A number the agency already knows is the same person: the existing card is reused as it is —
 * a stranger must not be able to rename, re-type or re-assign somebody else's client by typing
 * their phone — and only the history entry and the notification are added.
 *
 * <p>Everything here is reachable without an account, so every limit is enforced here and not in
 * the page: field lengths, the consent box, a phone that normalises to something, and the rate
 * limit in {@link LeadRateLimiter}. The honeypot is the controller's to catch before this runs.
 */
@Service
@RequiredArgsConstructor
public class ListingLeadService {

    public static final int MAX_NAME = 120;
    public static final int MAX_PHONE = 40;
    public static final int MAX_MESSAGE = 1000;

    private final PropertyShareLinkRepository linkRepository;
    private final ClientRepository clientRepository;
    private final ClientActivityRepository activityRepository;
    private final ClientActivityPropertyRepository activityPropertyRepository;
    private final NotificationEvents notificationEvents;
    private final LeadRateLimiter rateLimiter;

    /** What the buyer typed, trimmed; nulls for fields that were not sent. */
    public record LeadForm(String name, String phone, String message, boolean consent) {
        public LeadForm {
            name = strip(name);
            phone = strip(phone);
            message = strip(message);
        }
    }

    /** How a submission ended; the controller turns each into a page. */
    public sealed interface Outcome permits NotFound, Invalid, TooMany, Accepted {
    }

    public record NotFound() implements Outcome {
    }

    /** Field names ({@code name}, {@code phone}, {@code message}, {@code consent}) that failed. */
    public record Invalid(String title, List<String> errors) implements Outcome {
    }

    public record TooMany(String title) implements Outcome {
    }

    public record Accepted(Long clientId, boolean existingClient) implements Outcome {
    }

    /** The title of the listing behind a working token, for the page that shows the form again. */
    @Transactional(readOnly = true)
    public Optional<String> titleOf(String token) {
        return findLink(token).map(link -> link.getProperty().getTitle());
    }

    @Transactional
    public Outcome submit(String token, LeadForm form, String address) {
        Optional<PropertyShareLink> found = findLink(token);
        if (found.isEmpty()) {
            return new NotFound();
        }
        PropertyShareLink link = found.get();
        Property listing = link.getProperty();

        List<String> errors = validate(form);
        if (!errors.isEmpty()) {
            return new Invalid(listing.getTitle(), errors);
        }
        if (!rateLimiter.tryAcquire(link.getToken(), address)) {
            return new TooMany(listing.getTitle());
        }

        Team team = listing.getTeam();
        String title = listing.getTitle();
        Long listingId = listing.getId();
        User owner = ownerOf(listing, link);
        String phone = ContactNormalizer.phone(form.phone());
        Optional<Client> existing = clientRepository.findDuplicates(
                team != null ? team.getId() : null,
                owner != null ? owner.getId() : null,
                phone, null, null, PageRequest.of(0, 1)).stream().findFirst();

        Client client = existing.orElseGet(() -> clientRepository.save(Client.builder()
                .fullName(form.name())
                .phone(form.phone())
                .type(ClientType.BUYER)
                .source(ClientSource.PUBLIC_LINK)
                .notes(notesFor(listing, form))
                .agent(owner)
                .team(team)
                .build()));

        ClientActivity activity = activityRepository.save(ClientActivity.builder()
                .client(client)
                .team(client.getTeam())
                .authorName(form.name())
                .type(ActivityType.MESSAGE)
                .note(form.message())
                .build());
        activityPropertyRepository.save(ClientActivityProperty.of(activity, listing));
        Long clientId = client.getId();
        linkRepository.recordLead(link.getId());

        // The agent to tell is the listing's; a reused card may belong to a colleague, who is
        // not the one this buyer asked. Last, so nothing after it can fail on its account.
        // Read before the counter's update cleared the persistence context, and passed as values.
        notificationEvents.listingLead(owner, team, clientId, listingId, title, form.name(),
                form.phone());
        return new Accepted(clientId, existing.isPresent());
    }

    static List<String> validate(LeadForm form) {
        List<String> errors = new ArrayList<>();
        if (form.name() == null || form.name().length() > MAX_NAME) {
            errors.add("name");
        }
        if (form.phone() == null || form.phone().length() > MAX_PHONE
                || ContactNormalizer.phone(form.phone()) == null
                || !form.phone().matches("[0-9+()\\-.\\s]+")) {
            errors.add("phone");
        }
        if (form.message() != null && form.message().length() > MAX_MESSAGE) {
            errors.add("message");
        }
        if (!form.consent()) {
            errors.add("consent");
        }
        return errors;
    }

    /**
     * Whoever should hear about it: the listing's agent while they still work in its agency, else
     * whoever made the link, else the agency's manager.
     */
    private static User ownerOf(Property listing, PropertyShareLink link) {
        Team team = listing.getTeam();
        if (isActiveIn(listing.getAgent(), team)) {
            return listing.getAgent();
        }
        if (isActiveIn(link.getCreatedBy(), team)) {
            return link.getCreatedBy();
        }
        return team != null && isActiveIn(team.getManager(), team) ? team.getManager() : null;
    }

    private static boolean isActiveIn(User user, Team team) {
        if (user == null || user.getStatus() != UserStatus.ACTIVE) {
            return false;
        }
        return team == null || (user.getTeam() != null
                && Objects.equals(user.getTeam().getId(), team.getId()));
    }

    private static String notesFor(Property listing, LeadForm form) {
        String from = "From the public page of " + listing.getTitle();
        return form.message() == null ? from : from + "\n\n" + form.message();
    }

    private Optional<PropertyShareLink> findLink(String token) {
        if (token == null || token.isBlank() || token.length() > 64) {
            return Optional.empty();
        }
        return linkRepository.findByTokenAndRevokedAtIsNull(token);
    }

    private static String strip(String value) {
        if (value == null) {
            return null;
        }
        String stripped = value.strip();
        return stripped.isEmpty() ? null : stripped;
    }
}
