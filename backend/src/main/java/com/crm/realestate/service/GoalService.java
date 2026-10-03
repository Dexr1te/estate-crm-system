package com.crm.realestate.service;

import com.crm.realestate.dto.request.GoalRequest;
import com.crm.realestate.dto.response.GoalProgressResponse;
import com.crm.realestate.dto.response.TeamGoalsResponse;
import com.crm.realestate.entity.MonthlyGoal;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.GoalSource;
import com.crm.realestate.enums.Role;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.MonthlyGoalRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import jakarta.persistence.EntityManager;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.DateTimeParseException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;

/**
 * Monthly targets and how far each one has got.
 *
 * <p>A target is commission in the agency's currency, deals won, or both, for one calendar month.
 * The manager sets one per member and one for the whole agency; a member may set their own. When
 * both exist the manager's counts, and the member's own comes back if the manager takes theirs
 * off. Progress is never stored: it is counted from the deals won that month, exactly as the
 * dashboard's commissionThisMonth is (closedAt in the month, price × rate).
 *
 * <p>The tenant wall is the agency. Everything here is read and written inside the caller's own
 * team (an admin names one), a member who belongs to another agency reads as not found, and an
 * agent only ever reaches their own target: there is no way to name somebody else's.
 */
@Service
@RequiredArgsConstructor
public class GoalService {

    private static final BigDecimal HUNDRED = BigDecimal.valueOf(100);

    private final MonthlyGoalRepository goalRepository;
    private final TeamRepository teamRepository;
    private final UserRepository userRepository;
    private final AuditLogService auditLogService;
    private final EntityManager entityManager;

    // The member's own month --------------------------------------------------------------------

    @Transactional(readOnly = true)
    public GoalProgressResponse mine(User me, String month) {
        YearMonth ym = parseMonth(month);
        Team team = ownTeam(me);
        return personProgress(team, me, ym, tallies(team.getId(), ym));
    }

    @Transactional
    public GoalProgressResponse setMine(User me, String month, GoalRequest request) {
        YearMonth ym = writableMonth(month);
        Team team = ownTeam(me);
        requireNoManagerTarget(team, me, ym);
        upsert(team, me, ym, GoalSource.PERSONAL, request);
        return personProgress(team, me, ym, tallies(team.getId(), ym));
    }

    @Transactional
    public GoalProgressResponse clearMine(User me, String month) {
        YearMonth ym = writableMonth(month);
        Team team = ownTeam(me);
        requireNoManagerTarget(team, me, ym);
        goalRepository.findByTeamIdAndAgentIdAndMonthStartAndSource(
                        team.getId(), me.getId(), ym.atDay(1), GoalSource.PERSONAL)
                .ifPresent(goalRepository::delete);
        goalRepository.flush();
        return personProgress(team, me, ym, tallies(team.getId(), ym));
    }

    // The manager's view ------------------------------------------------------------------------

    @Transactional(readOnly = true)
    public TeamGoalsResponse team(User actor, Long teamId, String month) {
        requireManager(actor);
        return teamGoals(teamOf(actor, teamId), parseMonth(month), null);
    }

    @Transactional
    public TeamGoalsResponse setForMember(User actor, Long teamId, Long memberId, String month,
                                          GoalRequest request) {
        requireManager(actor);
        YearMonth ym = writableMonth(month);
        Team team = teamOf(actor, teamId);
        User member = member(team, memberId);
        MonthlyGoal saved = upsert(team, member, ym, GoalSource.MANAGER, request);
        auditLogService.record(actor, "SET_GOAL", "MonthlyGoal", saved.getId(),
                "team=" + team.getId() + " agent=" + member.getId() + " month=" + ym);
        return teamGoals(team, ym, null);
    }

    @Transactional
    public TeamGoalsResponse clearForMember(User actor, Long teamId, Long memberId, String month) {
        requireManager(actor);
        YearMonth ym = writableMonth(month);
        Team team = teamOf(actor, teamId);
        User member = member(team, memberId);
        goalRepository.findByTeamIdAndAgentIdAndMonthStartAndSource(
                        team.getId(), member.getId(), ym.atDay(1), GoalSource.MANAGER)
                .ifPresent(goal -> {
                    goalRepository.delete(goal);
                    auditLogService.record(actor, "CLEAR_GOAL", "MonthlyGoal", goal.getId(),
                            "team=" + team.getId() + " agent=" + member.getId() + " month=" + ym);
                });
        goalRepository.flush();
        return teamGoals(team, ym, null);
    }

    @Transactional
    public TeamGoalsResponse setForAgency(User actor, Long teamId, String month, GoalRequest request) {
        requireManager(actor);
        YearMonth ym = writableMonth(month);
        Team team = teamOf(actor, teamId);
        MonthlyGoal saved = upsert(team, null, ym, GoalSource.MANAGER, request);
        auditLogService.record(actor, "SET_GOAL", "MonthlyGoal", saved.getId(),
                "team=" + team.getId() + " agency month=" + ym);
        return teamGoals(team, ym, null);
    }

    @Transactional
    public TeamGoalsResponse clearForAgency(User actor, Long teamId, String month) {
        requireManager(actor);
        YearMonth ym = writableMonth(month);
        Team team = teamOf(actor, teamId);
        goalRepository.findAgencyGoal(team.getId(), ym.atDay(1)).ifPresent(goal -> {
            goalRepository.delete(goal);
            auditLogService.record(actor, "CLEAR_GOAL", "MonthlyGoal", goal.getId(),
                    "team=" + team.getId() + " agency month=" + ym);
        });
        goalRepository.flush();
        return teamGoals(team, ym, null);
    }

    /**
     * Brings the manager's targets from the month before into this one: the agency's and those of
     * members still in the agency. A target already set this month is left as it is, so copying
     * twice changes nothing. Members' own targets are theirs to set again.
     */
    @Transactional
    public TeamGoalsResponse copyPrevious(User actor, Long teamId, String month) {
        requireManager(actor);
        YearMonth ym = writableMonth(month);
        Team team = teamOf(actor, teamId);
        LocalDate start = ym.atDay(1);

        List<MonthlyGoal> current = goalRepository.findByTeamIdAndMonthStart(team.getId(), start);
        List<Long> members = members(team).stream().map(User::getId).toList();
        int copied = 0;
        for (MonthlyGoal previous : goalRepository.findByTeamIdAndMonthStart(team.getId(), start.minusMonths(1))) {
            if (previous.getSource() != GoalSource.MANAGER) {
                continue;
            }
            Long agentId = agentIdOf(previous);
            if (agentId != null && !members.contains(agentId)) {
                continue;
            }
            boolean alreadySet = current.stream().anyMatch(goal -> goal.getSource() == GoalSource.MANAGER
                    && Objects.equals(agentIdOf(goal), agentId));
            if (alreadySet) {
                continue;
            }
            goalRepository.save(MonthlyGoal.builder()
                    .team(team).agent(previous.getAgent()).monthStart(start).source(GoalSource.MANAGER)
                    .commissionTarget(previous.getCommissionTarget())
                    .dealsTarget(previous.getDealsTarget())
                    .build());
            copied++;
        }
        goalRepository.flush();
        auditLogService.record(actor, "COPY_GOALS", "Team", team.getId(),
                "month=" + ym + " copied=" + copied);
        return teamGoals(team, ym, copied);
    }

    // Counting ----------------------------------------------------------------------------------

    /** What one member's deals won in the month came to: how many, and the commission on them. */
    record Tally(long won, BigDecimal commission) {
        static final Tally NONE = new Tally(0, BigDecimal.ZERO.setScale(2));

        Tally plus(Tally other) {
            return new Tally(won + other.won, commission.add(other.commission));
        }
    }

    /**
     * Deals won in the month in this agency, per agent, in one grouped query. SUM skips deals
     * missing a price or a rate; summing price × percent and dividing once keeps the total exact.
     * The key is null for deals nobody holds; they still count for the agency.
     */
    Map<Long, Tally> tallies(Long teamId, YearMonth month) {
        List<Object[]> rows = entityManager.createQuery(
                        "SELECT a.id, COUNT(d), SUM(" + DealMoney.JPQL_COMMISSION_BASE + " * d.commissionPercent) FROM Deal d "
                                + "LEFT JOIN d.agent a "
                                + "WHERE d.team.id = :teamId AND d.status = :won "
                                + "AND d.closedAt >= :from AND d.closedAt < :to "
                                + "GROUP BY a.id", Object[].class)
                .setParameter("teamId", teamId)
                .setParameter("won", DealStatus.CLOSED_WON)
                .setParameter("from", month.atDay(1).atStartOfDay())
                .setParameter("to", month.plusMonths(1).atDay(1).atStartOfDay())
                .getResultList();
        Map<Long, Tally> tallies = new HashMap<>();
        for (Object[] row : rows) {
            BigDecimal sum = (BigDecimal) row[2];
            BigDecimal commission = sum == null
                    ? BigDecimal.ZERO.setScale(2)
                    : sum.divide(HUNDRED, 2, RoundingMode.HALF_UP);
            tallies.put((Long) row[0], new Tally(((Number) row[1]).longValue(), commission));
        }
        return tallies;
    }

    private TeamGoalsResponse teamGoals(Team team, YearMonth month, Integer copied) {
        LocalDate start = month.atDay(1);
        List<MonthlyGoal> goals = goalRepository.findByTeamIdAndMonthStart(team.getId(), start);
        Map<Long, Tally> tallies = tallies(team.getId(), month);

        Tally agencyTally = tallies.values().stream().reduce(Tally.NONE, Tally::plus);
        MonthlyGoal agencyGoal = goals.stream().filter(g -> g.getAgent() == null).findFirst().orElse(null);
        GoalProgressResponse agency = progress(team, null, month, agencyGoal, null, agencyTally);

        List<GoalProgressResponse> agents = members(team).stream()
                .map(member -> progress(team, member, month,
                        find(goals, member.getId(), GoalSource.MANAGER),
                        find(goals, member.getId(), GoalSource.PERSONAL),
                        tallies.getOrDefault(member.getId(), Tally.NONE)))
                .toList();

        return TeamGoalsResponse.builder()
                .month(month.toString())
                .currency(team.getCurrency().name())
                .daysLeft(daysLeft(month, LocalDate.now()))
                .agency(agency)
                .agents(agents)
                .copied(copied)
                .build();
    }

    private GoalProgressResponse personProgress(Team team, User person, YearMonth month, Map<Long, Tally> tallies) {
        List<MonthlyGoal> goals = goalRepository.findByTeamIdAndAgentIdAndMonthStart(
                team.getId(), person.getId(), month.atDay(1));
        return progress(team, person, month,
                find(goals, person.getId(), GoalSource.MANAGER),
                find(goals, person.getId(), GoalSource.PERSONAL),
                tallies.getOrDefault(person.getId(), Tally.NONE));
    }

    private static MonthlyGoal find(List<MonthlyGoal> goals, Long agentId, GoalSource source) {
        return goals.stream()
                .filter(g -> g.getSource() == source && Objects.equals(agentIdOf(g), agentId))
                .findFirst().orElse(null);
    }

    /** The manager's target wins; the member's own counts only while the manager has set none. */
    static GoalProgressResponse progress(Team team, User person, YearMonth month,
                                         MonthlyGoal managers, MonthlyGoal personal, Tally tally) {
        MonthlyGoal counting = managers != null ? managers : personal;
        BigDecimal commissionTarget = counting == null ? null : counting.getCommissionTarget();
        Integer dealsTarget = counting == null ? null : counting.getDealsTarget();
        int daysLeft = daysLeft(month, LocalDate.now());

        Integer commissionPercent = null;
        BigDecimal commissionPerDay = null;
        if (commissionTarget != null) {
            commissionPercent = tally.commission().multiply(HUNDRED)
                    .divide(commissionTarget, 0, RoundingMode.FLOOR).intValue();
            BigDecimal remaining = commissionTarget.subtract(tally.commission());
            if (remaining.signum() > 0 && daysLeft > 0) {
                commissionPerDay = remaining.divide(BigDecimal.valueOf(daysLeft), 0, RoundingMode.CEILING);
            }
        }
        Integer dealsPercent = null;
        BigDecimal dealsPerDay = null;
        if (dealsTarget != null) {
            dealsPercent = (int) (tally.won() * 100 / dealsTarget);
            long remaining = dealsTarget - tally.won();
            if (remaining > 0 && daysLeft > 0) {
                dealsPerDay = BigDecimal.valueOf(remaining)
                        .divide(BigDecimal.valueOf(daysLeft), 2, RoundingMode.CEILING);
            }
        }

        boolean overridden = managers != null && personal != null;
        return GoalProgressResponse.builder()
                .month(month.toString())
                .currency(team.getCurrency().name())
                .agentId(person == null ? null : person.getId())
                .agentName(person == null ? null : person.getFullName())
                .source(counting == null ? null : counting.getSource().name())
                .commissionTarget(commissionTarget)
                .dealsTarget(dealsTarget)
                .personalCommissionTarget(overridden ? personal.getCommissionTarget() : null)
                .personalDealsTarget(overridden ? personal.getDealsTarget() : null)
                .commissionAchieved(tally.commission())
                .dealsWon(tally.won())
                .commissionPercent(commissionPercent)
                .dealsPercent(dealsPercent)
                .daysLeft(daysLeft)
                .commissionPerDay(commissionPerDay)
                .dealsPerDay(dealsPerDay)
                .personalEditable(person != null && managers == null
                        && !month.isBefore(YearMonth.from(LocalDate.now())))
                .build();
    }

    /** Days still to come in the month, today included: all of a month ahead, none of one gone. */
    static int daysLeft(YearMonth month, LocalDate today) {
        YearMonth now = YearMonth.from(today);
        if (month.isBefore(now)) {
            return 0;
        }
        if (month.isAfter(now)) {
            return month.lengthOfMonth();
        }
        return month.lengthOfMonth() - today.getDayOfMonth() + 1;
    }

    // Writing -----------------------------------------------------------------------------------

    private MonthlyGoal upsert(Team team, User person, YearMonth month, GoalSource source, GoalRequest request) {
        if (request.getCommissionTarget() == null && request.getDealsTarget() == null) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "GOAL_TARGET_REQUIRED",
                    "Set a commission target, a deals target, or both");
        }
        LocalDate start = month.atDay(1);
        Optional<MonthlyGoal> existing = person == null
                ? goalRepository.findAgencyGoal(team.getId(), start)
                : goalRepository.findByTeamIdAndAgentIdAndMonthStartAndSource(team.getId(), person.getId(), start, source);
        MonthlyGoal goal = existing.orElseGet(() -> MonthlyGoal.builder()
                .team(team).agent(person).monthStart(start).source(source).build());
        goal.setCommissionTarget(request.getCommissionTarget() == null
                ? null : request.getCommissionTarget().setScale(2, RoundingMode.UNNECESSARY));
        goal.setDealsTarget(request.getDealsTarget());
        return goalRepository.saveAndFlush(goal);
    }

    private void requireNoManagerTarget(Team team, User me, YearMonth month) {
        if (goalRepository.findByTeamIdAndAgentIdAndMonthStartAndSource(
                team.getId(), me.getId(), month.atDay(1), GoalSource.MANAGER).isPresent()) {
            throw new BusinessException(HttpStatus.CONFLICT, "GOAL_SET_BY_MANAGER",
                    "Your manager has set this month's target");
        }
    }

    // Who and when ------------------------------------------------------------------------------

    /** "2026-10"; absent means this month. */
    static YearMonth parseMonth(String month) {
        if (month == null || month.isBlank()) {
            return YearMonth.now();
        }
        try {
            return YearMonth.parse(month.strip());
        } catch (DateTimeParseException e) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "BAD_MONTH",
                    "A month is written as 2026-10");
        }
    }

    /** A month gone is history: its targets stay as they were. */
    private static YearMonth writableMonth(String month) {
        YearMonth ym = parseMonth(month);
        if (ym.isBefore(YearMonth.now())) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "GOAL_MONTH_PAST",
                    "A month that is over keeps the targets it had");
        }
        return ym;
    }

    private static Team ownTeam(User me) {
        if (me.getTeam() == null) {
            throw new BusinessException(HttpStatus.FORBIDDEN, "TEAM_REQUIRED",
                    "Targets belong to an agency");
        }
        return me.getTeam();
    }

    private static void requireManager(User actor) {
        if (actor.getRole() == Role.AGENT) {
            throw new BusinessException(HttpStatus.FORBIDDEN, "MANAGER_ONLY",
                    "Only the agency's manager sets its targets");
        }
    }

    /** The caller's own agency; an admin, who runs none, names one. */
    private Team teamOf(User user, Long teamId) {
        if (user.getRole() == Role.ADMIN && teamId != null) {
            return teamRepository.findById(teamId)
                    .orElseThrow(() -> new ResourceNotFoundException("Team not found with id: " + teamId));
        }
        if (user.getTeam() == null) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "TEAM_REQUIRED",
                    "Say which agency's targets these are");
        }
        return user.getTeam();
    }

    /** The agency's people a target can be set for, by name. */
    private List<User> members(Team team) {
        return userRepository.findByTeamIdAndIsActiveTrueOrderByFullNameAsc(team.getId()).stream()
                .filter(u -> u.getRole() != Role.ADMIN)
                .toList();
    }

    /** One of this agency's people; anybody else reads as not found. */
    private User member(Team team, Long memberId) {
        return members(team).stream()
                .filter(u -> u.getId().equals(memberId))
                .findFirst()
                .orElseThrow(() -> new ResourceNotFoundException("Agent not found with id: " + memberId));
    }

    private static Long agentIdOf(MonthlyGoal goal) {
        return goal.getAgent() == null ? null : goal.getAgent().getId();
    }
}
