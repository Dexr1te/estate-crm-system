package com.crm.realestate.service;

import com.crm.realestate.dto.response.ColdClient;
import com.crm.realestate.dto.response.ColdClient.NextStep;
import com.crm.realestate.dto.response.ColdClient.Reason;
import com.crm.realestate.dto.response.ColdClient.ReasonCode;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ClientSource;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.repository.ColdClientRepository;
import com.crm.realestate.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

/**
 * Who needs a call before they are gone.
 *
 * <p>A client is going cold when nobody has spoken to them — no logged contact, no meeting — for
 * at least {@code days}, and they are still worth the call: an open deal, a buyer with listings
 * that fit right now, or someone who came in through a listing's public page. A client with an
 * open task due later, or a meeting booked, is left out: somebody is already on it. An overdue
 * task does not count — that is exactly the client who slipped.
 *
 * <p>Silence is measured from the last contact, or from when the card was made if there never was
 * one, so a client added yesterday is not "silent for weeks".
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ColdClientService {

    public static final int DEFAULT_DAYS = 14;
    public static final int MIN_DAYS = 7;
    public static final int MAX_DAYS = 90;
    public static final int DEFAULT_LIMIT = 20;
    public static final int MAX_LIMIT = 100;
    private static final long NONE = -1L;

    private final ColdClientRepository repository;
    private final SecurityUtils securityUtils;
    private final ScopeService scopeService;

    public List<ColdClient> list(Integer days, Integer limit) {
        int threshold = checkedDays(days);
        int cap = limit == null ? DEFAULT_LIMIT : limit;
        if (cap < 1 || cap > MAX_LIMIT) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "INVALID_LIMIT",
                    "limit must be between 1 and " + MAX_LIMIT);
        }
        User me = securityUtils.getCurrentUser();
        LocalDateTime now = LocalDateTime.now();
        Long teamId = scopeService.teamIdOf(me);
        return repository.findCold(scopeService.isAdmin(me), teamId == null ? NONE : teamId, me.getId(),
                        scopeService.seesWholeTeam(me), NONE, NONE, now, now.minusDays(threshold), cap)
                .stream().map(row -> toColdClient(row, now)).toList();
    }

    /** How many are going cold at the default threshold, narrowed the way the dashboard narrows. */
    public long count(User me, Long agentId, Long narrowTeamId) {
        LocalDateTime now = LocalDateTime.now();
        Long teamId = scopeService.teamIdOf(me);
        return repository.countCold(scopeService.isAdmin(me), teamId == null ? NONE : teamId, me.getId(),
                scopeService.seesWholeTeam(me),
                agentId == null ? NONE : agentId, narrowTeamId == null ? NONE : narrowTeamId,
                now, now.minusDays(DEFAULT_DAYS));
    }

    private static int checkedDays(Integer days) {
        int value = days == null ? DEFAULT_DAYS : days;
        if (value < MIN_DAYS || value > MAX_DAYS) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "INVALID_DAYS",
                    "days must be between " + MIN_DAYS + " and " + MAX_DAYS);
        }
        return value;
    }

    private static ColdClient toColdClient(Object[] row, LocalDateTime now) {
        LocalDateTime createdAt = dateTime(row[7]);
        LocalDateTime lastContact = dateTime(row[8]);
        Integer dealRank = row[9] == null ? null : ((Number) row[9]).intValue();
        long matches = row[11] == null ? 0 : ((Number) row[11]).longValue();
        boolean lead = ClientSource.PUBLIC_LINK.name().equals(row[4]);

        List<Reason> reasons = new ArrayList<>();
        if (dealRank != null) {
            reasons.add(Reason.builder().code(ReasonCode.OPEN_DEAL).dealTitle((String) row[10])
                    .dealStatus(dealRank == 2 ? DealStatus.NEGOTIATION : DealStatus.LEAD).build());
        }
        if (matches > 0) {
            reasons.add(Reason.builder().code(ReasonCode.MATCHES).matchCount(matches).build());
        }
        if (lead) {
            reasons.add(Reason.builder().code(ReasonCode.NEW_LEAD).build());
        }

        LocalDateTime since = lastContact != null ? lastContact : createdAt;
        return ColdClient.builder()
                .id(((Number) row[0]).longValue())
                .fullName((String) row[1])
                .phone((String) row[2])
                .type(row[3] == null ? null : ClientType.valueOf((String) row[3]))
                .agentId(row[5] == null ? null : ((Number) row[5]).longValue())
                .agentName((String) row[6])
                .lastContactAt(lastContact)
                .silentDays(since == null ? 0 : Math.max(0, ChronoUnit.DAYS.between(since, now)))
                .reasons(reasons)
                .nextStep(nextStep(reasons.get(0).getCode(), lastContact == null))
                .build();
    }

    private static NextStep nextStep(ReasonCode first, boolean neverContacted) {
        if (neverContacted) {
            return NextStep.FIRST_CALL;
        }
        return switch (first) {
            case OPEN_DEAL -> NextStep.PUSH_DEAL;
            case MATCHES -> NextStep.SEND_MATCHES;
            case NEW_LEAD -> NextStep.CHECK_IN;
        };
    }

    /** Native queries hand timestamps back as whatever the driver prefers; GREATEST varies too. */
    private static LocalDateTime dateTime(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof java.sql.Timestamp timestamp) {
            return timestamp.toLocalDateTime();
        }
        if (value instanceof LocalDateTime local) {
            return local;
        }
        if (value instanceof java.time.OffsetDateTime offset) {
            return offset.toLocalDateTime();
        }
        throw new IllegalStateException("Unexpected timestamp type " + value.getClass());
    }
}
