package com.crm.realestate.service;

import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.Task;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.TeamJoinRequest;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.NotificationType;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.ViewingOutcome;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.MeetingRepository;
import com.crm.realestate.specification.MatchSpecification;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * What each business event means for somebody's feed.
 *
 * <p>The services call in here at the moment something happens, inside their own transaction.
 * Every method is cheap, and none of them lets an exception out: the event already happened, and
 * failing to tell somebody about it must not take it back.
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class NotificationEvents {

    /** How many buyer names one match notification carries; the rest are only counted. */
    static final int MAX_BUYER_NAMES = 3;

    private final NotificationService notifications;
    private final ClientRepository    clientRepository;
    private final MeetingRepository   meetingRepository;

    /** {@code actor} gave {@code task} to its assignee, on creation or by handing it over. */
    public void taskAssigned(Task task, User actor) {
        guard("task assigned", () -> {
            Map<String, Object> params = new LinkedHashMap<>();
            params.put("taskTitle", task.getTitle());
            params.put("actorName", nameOf(actor));
            notifications.notify(task.getAssignee(), actor, task.getTeam(),
                    NotificationType.TASK_ASSIGNED, task.getId(), params);
        });
    }

    /** One line for the whole handover, however many records it moved. */
    public void recordsHandedOver(User from, User to, User actor, Team team,
                                  int clients, int properties, int deals, int meetings, int tasks) {
        if (clients + properties + deals + meetings + tasks == 0) {
            return;
        }
        guard("records handed over", () -> {
            Map<String, Object> params = new LinkedHashMap<>();
            params.put("fromName", nameOf(from));
            params.put("clients", clients);
            params.put("properties", properties);
            params.put("deals", deals);
            params.put("meetings", meetings);
            params.put("tasks", tasks);
            notifications.notify(to, actor, team, NotificationType.RECORDS_HANDED_OVER, null, params);
        });
    }

    /**
     * An agency asked someone to join it. They are not in a team yet, so the row has none either.
     */
    public void joinRequested(TeamJoinRequest request, User actor) {
        guard("join request", () -> {
            Map<String, Object> params = new LinkedHashMap<>();
            params.put("teamName", request.getTeam().getName());
            params.put("actorName", nameOf(actor));
            notifications.notify(request.getUser(), actor, null,
                    NotificationType.JOIN_REQUEST, request.getId(), params);
        });
    }

    /** The agent said yes; whoever asked them hears so, or the agency's manager if nobody did. */
    public void joinAccepted(TeamJoinRequest request, User agent) {
        guard("join accepted", () -> {
            User asker = request.getInvitedBy() != null ? request.getInvitedBy() : request.getTeam().getManager();
            Map<String, Object> params = new LinkedHashMap<>();
            params.put("agentName", nameOf(agent));
            params.put("teamName", request.getTeam().getName());
            notifications.notify(asker, agent, request.getTeam(),
                    NotificationType.JOIN_ACCEPTED, agent.getId(), params);
        });
    }

    /** Somebody other than the deal's agent moved it. */
    public void dealStatusChanged(Deal deal, DealStatus from, User actor) {
        if (from == null || from == deal.getStatus()) {
            return;
        }
        guard("deal status", () -> {
            Map<String, Object> params = new LinkedHashMap<>();
            params.put("dealTitle", deal.getTitle());
            params.put("fromStatus", from.name());
            params.put("toStatus", deal.getStatus().name());
            params.put("actorName", nameOf(actor));
            notifications.notify(deal.getAgent(), actor, deal.getTeam(),
                    NotificationType.DEAL_STATUS_CHANGED, deal.getId(), params);
        });
    }

    /**
     * A listing has just come on the market — added, or back to available. Each agent with buyers
     * it fits hears once per listing, whatever happens to it afterwards.
     */
    public void listingAvailable(Property listing, User actor) {
        if (listing.getStatus() != PropertyStatus.AVAILABLE) {
            return;
        }
        guard("new match", () -> matchingBuyersByAgent(listing).forEach((agent, buyers) -> {
            if (notifications.alreadyTold(agent, NotificationType.NEW_MATCH, listing.getId())) {
                return;
            }
            notifications.notify(agent, actor, listing.getTeam(), NotificationType.NEW_MATCH,
                    listing.getId(), matchParams(listing, buyers));
        }));
    }

    /** An available listing got cheaper. Its buyers' agents hear about every reduction. */
    public void priceDropped(Property listing, BigDecimal oldPrice, BigDecimal newPrice, User actor) {
        if (listing.getStatus() != PropertyStatus.AVAILABLE
                || oldPrice == null || newPrice == null || newPrice.compareTo(oldPrice) >= 0) {
            return;
        }
        guard("price drop", () -> matchingBuyersByAgent(listing).forEach((agent, buyers) -> {
            Map<String, Object> params = matchParams(listing, buyers);
            params.put("oldPrice", oldPrice.stripTrailingZeros().toPlainString());
            params.put("newPrice", newPrice.stripTrailingZeros().toPlainString());
            notifications.notify(agent, actor, listing.getTeam(), NotificationType.PRICE_DROP_MATCH,
                    listing.getId(), params);
        }));
    }

    /**
     * The listing's own agency's buyers it fits, minus those who have seen it and said no, grouped
     * by the agent who holds them. Another agency's buyers are never looked at.
     */
    private Map<User, List<Client>> matchingBuyersByAgent(Property listing) {
        if (listing.getTeam() == null || listing.getId() == null) {
            return Map.of();
        }
        Long teamId = listing.getTeam().getId();
        Specification<Client> inTeam = (root, query, cb) -> cb.equal(root.get("team").get("id"), teamId);
        Set<Long> turnedItDown = meetingRepository.findByPropertyId(listing.getId()).stream()
                .filter(m -> m.getOutcome() == ViewingOutcome.REJECTED)
                .map(m -> m.getClient().getId())
                .collect(Collectors.toSet());
        Map<Long, User> agents = new LinkedHashMap<>();
        Map<Long, List<Client>> byAgent = clientRepository
                .findAll(MatchSpecification.buyersFor(listing).and(inTeam)).stream()
                .filter(c -> c.getAgent() != null && !turnedItDown.contains(c.getId()))
                .peek(c -> agents.putIfAbsent(c.getAgent().getId(), c.getAgent()))
                .collect(Collectors.groupingBy(c -> c.getAgent().getId(), LinkedHashMap::new, Collectors.toList()));
        Map<User, List<Client>> result = new LinkedHashMap<>();
        byAgent.forEach((agentId, buyers) -> result.put(agents.get(agentId), buyers));
        return result;
    }

    private static Map<String, Object> matchParams(Property listing, List<Client> buyers) {
        List<Client> sorted = buyers.stream()
                .sorted(Comparator.comparing(Client::getFullName, Comparator.nullsLast(String.CASE_INSENSITIVE_ORDER)))
                .toList();
        Map<String, Object> params = new LinkedHashMap<>();
        params.put("propertyTitle", listing.getTitle());
        params.put("buyerCount", sorted.size());
        params.put("buyerNames", sorted.stream().limit(MAX_BUYER_NAMES).map(Client::getFullName).toList());
        if (sorted.size() == 1) {
            params.put("clientId", sorted.get(0).getId());
        }
        return params;
    }

    private static String nameOf(User user) {
        return user == null ? null : user.getFullName();
    }

    private static void guard(String event, Runnable body) {
        try {
            body.run();
        } catch (RuntimeException e) {
            log.warn("Could not raise the {} notification: {}", event, e.toString());
        }
    }
}
