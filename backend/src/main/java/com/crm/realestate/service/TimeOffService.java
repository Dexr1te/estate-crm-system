package com.crm.realestate.service;

import com.crm.realestate.dto.request.TimeOffRequest;
import com.crm.realestate.dto.response.TimeOffResponse;
import com.crm.realestate.entity.Meeting;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.TimeOff;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.MeetingRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.TimeOffRepository;
import com.crm.realestate.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * Agents' time off, and the colleague who covers while they are away.
 *
 * <p><b>What it changes.</b> Nothing changes hands: what the absent person holds stays theirs, and
 * moving it is the handover's business ({@link WorkHandoverService}). What changes is who hears
 * about it — while somebody is away every notification meant for them reaches their cover too,
 * marked as covering for them ({@link NotificationService}). And the agency can see who is out.
 *
 * <p><b>Who sees what.</b> The agency's absences are the agency's: everybody in it sees who is out,
 * whatever their data scope, and another agency is told an absence does not exist. The meetings an
 * absence clashes with are records, though, and those follow the data scope: an agent on their own
 * records is told how many a colleague has on their days off, not what they are.
 *
 * <p><b>Who writes what.</b> Anybody writes down their own time off; a manager, or an admin naming
 * the agency, writes down anybody's in it. The absent person, whoever wrote it down, the agency's
 * manager and an admin may change or cancel it. Whose it is never changes.
 *
 * <p><b>The rules.</b> The last day is not before the first (END_BEFORE_START), and an absence is
 * at most a year (TIME_OFF_TOO_LONG). One person's absences do not share a day (409
 * TIME_OFF_OVERLAPS). The cover is an active member of the same agency and not the absent person
 * (COVER_IS_ABSENT_PERSON); anybody else reads as not found. A meeting on a day off is a warning on
 * the absence, never a refusal.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class TimeOffService {

    /** The longest absence, and the widest window the team list may ask for. */
    static final int MAX_DAYS = 366;

    /** How far ahead the team list looks when it is not told. */
    static final int DEFAULT_WINDOW_DAYS = 90;

    private final TimeOffRepository timeOffRepository;
    private final UserRepository userRepository;
    private final TeamRepository teamRepository;
    private final MeetingRepository meetingRepository;
    private final ScopeService scopeService;
    private final NotificationEvents notificationEvents;
    private final AgencyCalendar calendar;

    // Reading -----------------------------------------------------------------------------

    /**
     * The agency's absences taking in any day of {@code [from, to]}, soonest first: from today and
     * {@value #DEFAULT_WINDOW_DAYS} days on unless told, narrowed to one person with {@code userId}.
     */
    public List<TimeOffResponse> list(User actor, Long teamId, LocalDate from, LocalDate to, Long userId) {
        Team team = teamOf(actor, teamId);
        LocalDate start = from != null ? from : calendar.today();
        LocalDate end = to != null ? to : start.plusDays(DEFAULT_WINDOW_DAYS);
        if (end.isBefore(start)) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "RANGE_REQUIRED",
                    "Give a window: from, and a to that is not before it");
        }
        if (ChronoUnit.DAYS.between(start, end) > MAX_DAYS) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "RANGE_TOO_WIDE",
                    "Ask for at most a year at a time");
        }
        if (userId != null) {
            member(team, userId);
        }
        return toResponses(timeOffRepository.findInTeam(team.getId(), start, end, userId), actor);
    }

    public TimeOffResponse get(User actor, Long id) {
        return toResponses(List.of(requireVisible(actor, id)), actor).get(0);
    }

    // Writing -----------------------------------------------------------------------------

    @Transactional
    public TimeOffResponse create(User actor, Long teamId, TimeOffRequest request) {
        Team team = teamOf(actor, teamId);
        User who = request.getUserId() == null || request.getUserId().equals(actor.getId())
                ? actor
                : member(team, request.getUserId());
        if (who == actor) {
            if (actor.getRole() == Role.ADMIN || actor.getTeam() == null
                    || !team.getId().equals(actor.getTeam().getId())) {
                throw new BusinessException(HttpStatus.BAD_REQUEST, "USER_REQUIRED",
                        "Say whose time off it is");
            }
        } else if (actor.getRole() == Role.AGENT) {
            throw new BusinessException(HttpStatus.FORBIDDEN, "MANAGER_ONLY",
                    "Only the agency's manager writes down a colleague's time off");
        }
        User cover = validate(team, who, request, null);
        TimeOff saved = timeOffRepository.save(TimeOff.builder()
                .team(team)
                .user(who)
                .cover(cover)
                .kind(request.getKind())
                .startDate(request.getStartDate())
                .endDate(request.getEndDate())
                .note(strip(request.getNote()))
                .createdBy(actor)
                .build());
        if (cover != null) {
            notificationEvents.coverAsked(saved, actor);
        }
        return toResponses(List.of(saved), actor).get(0);
    }

    @Transactional
    public TimeOffResponse update(User actor, Long id, TimeOffRequest request) {
        TimeOff timeOff = requireEditable(actor, id);
        Long coverBefore = timeOff.getCover() == null ? null : timeOff.getCover().getId();
        User cover = validate(timeOff.getTeam(), timeOff.getUser(), request, timeOff.getId());
        timeOff.setKind(request.getKind());
        timeOff.setStartDate(request.getStartDate());
        timeOff.setEndDate(request.getEndDate());
        timeOff.setCover(cover);
        timeOff.setNote(strip(request.getNote()));
        TimeOff saved = timeOffRepository.save(timeOff);
        if (cover != null && !cover.getId().equals(coverBefore)) {
            notificationEvents.coverAsked(saved, actor);
        }
        return toResponses(List.of(saved), actor).get(0);
    }

    @Transactional
    public void delete(User actor, Long id) {
        timeOffRepository.delete(requireEditable(actor, id));
    }

    // People leaving ----------------------------------------------------------------------

    /**
     * {@code leaver} leaves {@code team} and {@code successor} takes their work: the leaver's
     * absences there go, and whatever they were covering there is covered by the successor — unless
     * the successor is the one away, when nobody covers it.
     */
    @Transactional
    public void leftTeam(User leaver, User successor, Team team) {
        timeOffRepository.deleteForUserInTeam(leaver, team);
        handCoverOn(timeOffRepository.findByCoverIdAndTeamId(leaver.getId(), team.getId()), successor);
    }

    /**
     * {@code target}'s account is closed: their absences go with it, and what they were covering
     * passes to {@code replacement} where that is somebody in the same agency, or to nobody.
     */
    @Transactional
    public void accountClosed(User target, User replacement) {
        timeOffRepository.deleteForUser(target);
        handCoverOn(timeOffRepository.findByCoverId(target.getId()), replacement);
    }

    private void handCoverOn(List<TimeOff> covered, User successor) {
        for (TimeOff t : covered) {
            boolean fits = successor != null
                    && !successor.getId().equals(t.getUser().getId())
                    && successor.getTeam() != null
                    && successor.getTeam().getId().equals(t.getTeam().getId());
            t.setCover(fits ? successor : null);
        }
        timeOffRepository.saveAll(covered);
    }

    // Who is away, for the pickers --------------------------------------------------------

    /**
     * The absences of these people in an agency that have not ended yet, soonest first, by person —
     * so a picker can say who is away and a form can warn about a day.
     */
    public Map<Long, List<TimeOff>> notOverByPerson(Long teamId, Collection<Long> userIds) {
        if (teamId == null || userIds.isEmpty()) {
            return Map.of();
        }
        return timeOffRepository.findNotOverFor(teamId, userIds, calendar.today()).stream()
                .collect(Collectors.groupingBy(t -> t.getUser().getId(), LinkedHashMap::new, Collectors.toList()));
    }

    public LocalDate today() {
        return calendar.today();
    }

    // Rules -------------------------------------------------------------------------------

    /** Checks the request against the rules; the cover it names, or null. */
    private User validate(Team team, User who, TimeOffRequest request, Long exceptId) {
        LocalDate start = request.getStartDate();
        LocalDate end = request.getEndDate();
        if (end.isBefore(start)) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "END_BEFORE_START",
                    "The last day cannot be before the first");
        }
        if (ChronoUnit.DAYS.between(start, end) + 1 > MAX_DAYS) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "TIME_OFF_TOO_LONG",
                    "Time off lasts at most a year");
        }
        User cover = null;
        if (request.getCoverId() != null) {
            if (request.getCoverId().equals(who.getId())) {
                throw new BusinessException(HttpStatus.BAD_REQUEST, "COVER_IS_ABSENT_PERSON",
                        "Somebody else has to cover");
            }
            cover = member(team, request.getCoverId());
        }
        if (!timeOffRepository.findOverlapping(who.getId(), team.getId(), start, end, exceptId).isEmpty()) {
            throw new BusinessException(HttpStatus.CONFLICT, "TIME_OFF_OVERLAPS",
                    "This person already has time off on some of these days");
        }
        return cover;
    }

    private Team teamOf(User actor, Long teamId) {
        if (actor.getRole() == Role.ADMIN && teamId != null) {
            return teamRepository.findById(teamId)
                    .orElseThrow(() -> new ResourceNotFoundException("Team not found with id: " + teamId));
        }
        if (actor.getTeam() == null) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "TEAM_REQUIRED",
                    "Say which agency's time off this is");
        }
        return actor.getTeam();
    }

    /** An active member of this agency; anybody else reads as not found. */
    private User member(Team team, Long userId) {
        return userRepository.findById(userId)
                .filter(u -> u.getTeam() != null && u.getTeam().getId().equals(team.getId()))
                .filter(User::isActive)
                .filter(u -> u.getStatus() == UserStatus.ACTIVE)
                .filter(u -> u.getRole() != Role.ADMIN)
                .orElseThrow(() -> new ResourceNotFoundException("Agent not found with id: " + userId));
    }

    /** In the caller's agency (any, for an admin); another agency's reads as not found. */
    private TimeOff requireVisible(User actor, Long id) {
        return timeOffRepository.findById(id)
                .filter(t -> scopeService.isAdmin(actor)
                        || (actor.getTeam() != null && actor.getTeam().getId().equals(t.getTeam().getId())))
                .orElseThrow(() -> new ResourceNotFoundException("Time off not found with id: " + id));
    }

    private TimeOff requireEditable(User actor, Long id) {
        TimeOff timeOff = requireVisible(actor, id);
        if (!canEdit(actor, timeOff)) {
            throw new BusinessException(HttpStatus.FORBIDDEN, "NOT_YOUR_TIME_OFF",
                    "Only the person away, whoever wrote it down or a manager can change this");
        }
        return timeOff;
    }

    private boolean canEdit(User actor, TimeOff t) {
        if (scopeService.isAdmin(actor)) {
            return true;
        }
        if (scopeService.isManager(actor)) {
            return true;
        }
        return same(actor, t.getUser()) || same(actor, t.getCreatedBy());
    }

    // Mapping -----------------------------------------------------------------------------

    private List<TimeOffResponse> toResponses(List<TimeOff> rows, User actor) {
        if (rows.isEmpty()) {
            return List.of();
        }
        LocalDate today = calendar.today();
        LocalDateTime now = LocalDateTime.now();
        Map<Long, List<Meeting>> meetingsByTeam = new LinkedHashMap<>();
        rows.stream().collect(Collectors.groupingBy(t -> t.getTeam().getId(), LinkedHashMap::new, Collectors.toList()))
                .forEach((teamId, inTeam) -> {
                    Set<Long> people = inTeam.stream().map(t -> t.getUser().getId()).collect(Collectors.toSet());
                    LocalDate first = inTeam.stream().map(TimeOff::getStartDate).min(LocalDate::compareTo).orElseThrow();
                    LocalDate last = inTeam.stream().map(TimeOff::getEndDate).max(LocalDate::compareTo).orElseThrow();
                    LocalDateTime from = later(first.atStartOfDay(), now);
                    LocalDateTime to = last.plusDays(1).atStartOfDay();
                    meetingsByTeam.put(teamId, from.isBefore(to)
                            ? meetingRepository.findOpenForAgentsBetween(teamId, people, from, to)
                            : List.of());
                });
        return rows.stream().map(t -> {
            List<Meeting> clashes = meetingsByTeam.getOrDefault(t.getTeam().getId(), List.of()).stream()
                    .filter(m -> m.getAgent().getId().equals(t.getUser().getId()))
                    .filter(m -> t.covers(m.getScheduledAt().toLocalDate()))
                    .toList();
            boolean seesThem = scopeService.canSee(actor, t.getTeam(), t.getUser());
            return TimeOffResponse.builder()
                    .id(t.getId())
                    .userId(t.getUser().getId())
                    .userName(t.getUser().getFullName())
                    .kind(t.getKind())
                    .startDate(t.getStartDate())
                    .endDate(t.getEndDate())
                    .days(ChronoUnit.DAYS.between(t.getStartDate(), t.getEndDate()) + 1)
                    .note(t.getNote())
                    .coverId(t.getCover() == null ? null : t.getCover().getId())
                    .coverName(t.getCover() == null ? null : t.getCover().getFullName())
                    .createdById(t.getCreatedBy() == null ? null : t.getCreatedBy().getId())
                    .createdByName(t.getCreatedBy() == null ? null : t.getCreatedBy().getFullName())
                    .current(t.covers(today))
                    .canEdit(canEdit(actor, t))
                    .conflictCount(clashes.size())
                    .conflicts(seesThem ? clashes.stream().map(TimeOffService::conflict).toList() : List.of())
                    .build();
        }).toList();
    }

    private static TimeOffResponse.Conflict conflict(Meeting m) {
        return TimeOffResponse.Conflict.builder()
                .meetingId(m.getId())
                .title(m.getTitle())
                .scheduledAt(m.getScheduledAt())
                .clientName(m.getClient() == null ? null : m.getClient().getFullName())
                .propertyTitle(m.getProperty() == null ? null : m.getProperty().getTitle())
                .build();
    }

    private static LocalDateTime later(LocalDateTime a, LocalDateTime b) {
        return a.isAfter(b) ? a : b;
    }

    private static boolean same(User a, User b) {
        return a != null && b != null && Objects.equals(a.getId(), b.getId());
    }

    private static String strip(String value) {
        if (value == null) {
            return null;
        }
        String stripped = value.strip();
        return stripped.isEmpty() ? null : stripped;
    }
}
