package com.crm.realestate.service;

import com.crm.realestate.dto.request.TaskRepeatRequest;
import com.crm.realestate.dto.request.TaskRequest;
import com.crm.realestate.dto.response.TaskRepeatResponse;
import com.crm.realestate.dto.response.TaskResponse;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Task;
import com.crm.realestate.entity.TaskSeries;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.RepeatFrequency;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.TaskRepository;
import com.crm.realestate.repository.TaskSeriesRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.security.SecurityUtils;
import jakarta.persistence.criteria.Predicate;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.EnumSet;
import java.util.List;
import java.util.Locale;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;

/**
 * Follow-ups with a due time: "call Irina back on Friday".
 *
 * <p>A task sits behind the same walls as a meeting, with its assignee in the agent's place: an
 * agent on their own records sees the tasks they have to do, a team sees the agency's, and another
 * agency's task answers not found. Linking one to a client or a deal the caller cannot read is
 * refused the same way, so the refusal does not confirm the record exists.
 *
 * <p>A repeating task is a series of ordinary tasks with one open at a time: completing an
 * occurrence writes the next, due where {@link RepeatSchedule} puts it, for whoever held the one
 * completed, in its agency, about the same client and deal. Each occurrence writes at most one
 * next, so reopening and completing it again adds nothing. The rule is changed or stopped through
 * any occurrence the caller may see, and a change counts for the occurrences still to be written.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class TaskService {

    /** The name of a task's holder, for {@link ScopeService#visibleTo(User, String)}. */
    public static final String HOLDER = "assignee";

    private final TaskRepository   taskRepository;
    private final TaskSeriesRepository seriesRepository;
    private final ClientRepository clientRepository;
    private final DealRepository   dealRepository;
    private final UserRepository   userRepository;
    private final SecurityUtils    securityUtils;
    private final ScopeService     scopeService;
    private final NotificationEvents notificationEvents;

    /**
     * Open tasks soonest first, so the overdue ones lead; finished ones most recently done first.
     */
    public List<TaskResponse> list(String status, Long clientId, Long dealId, Long assigneeId) {
        return list(status, clientId, dealId, assigneeId, null, null);
    }

    /**
     * As above, optionally narrowed to tasks due in {@code [from, to)} for a calendar page. The
     * status {@code all} returns open and done together, soonest due first.
     */
    public List<TaskResponse> list(String status, Long clientId, Long dealId, Long assigneeId,
                                   LocalDateTime from, LocalDateTime to) {
        return list(status, clientId, dealId, assigneeId, from, to, null);
    }

    /** As above, optionally only the occurrences of one repeating series. */
    public List<TaskResponse> list(String status, Long clientId, Long dealId, Long assigneeId,
                                   LocalDateTime from, LocalDateTime to, Long seriesId) {
        Boolean doneFilter = parseDone(status);
        boolean done = Boolean.TRUE.equals(doneFilter);
        Specification<Task> filter = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();
            if (doneFilter != null) {
                predicates.add(done ? cb.isNotNull(root.get("completedAt")) : cb.isNull(root.get("completedAt")));
            }
            if (from != null) {
                predicates.add(cb.greaterThanOrEqualTo(root.get("dueAt"), from));
            }
            if (to != null) {
                predicates.add(cb.lessThan(root.get("dueAt"), to));
            }
            if (clientId != null) {
                predicates.add(cb.equal(root.get("client").get("id"), clientId));
            }
            if (dealId != null) {
                predicates.add(cb.equal(root.get("deal").get("id"), dealId));
            }
            if (assigneeId != null) {
                predicates.add(cb.equal(root.get(HOLDER).get("id"), assigneeId));
            }
            if (seriesId != null) {
                predicates.add(cb.equal(root.get("series").get("id"), seriesId));
            }
            return cb.and(predicates.toArray(new Predicate[0]));
        };
        Sort order = done
                ? Sort.by(Sort.Order.desc("completedAt"), Sort.Order.desc("id"))
                : Sort.by(Sort.Order.asc("dueAt"), Sort.Order.asc("id"));
        User currentUser = securityUtils.getCurrentUser();
        return taskRepository.findAll(filter.and(scopeService.visibleTo(currentUser, HOLDER)), order)
                .stream().map(TaskService::toResponse).toList();
    }

    public TaskResponse get(Long id) {
        return toResponse(findVisibleById(id, securityUtils.getCurrentUser()));
    }

    @Transactional
    public TaskResponse create(TaskRequest request) {
        User currentUser = securityUtils.getCurrentUser();
        Task task = new Task();
        task.setCreatedBy(currentUser);
        apply(request, task, currentUser);
        Rule rule = request.getRepeat() == null ? null : parseRepeat(request.getRepeat(), task.getDueAt());
        if (rule != null) {
            startSeries(task, rule);
        }
        Task saved = taskRepository.save(task);
        notificationEvents.taskAssigned(saved, currentUser);
        return toResponse(saved);
    }

    /** Handing the task to somebody else tells them; editing it where it stands does not. */
    @Transactional
    public TaskResponse update(Long id, TaskRequest request) {
        User currentUser = securityUtils.getCurrentUser();
        Task task = findVisibleById(id, currentUser);
        Long previousAssigneeId = task.getAssignee().getId();
        LocalDateTime previousDue = task.getDueAt();
        apply(request, task, currentUser);
        if (request.getRepeat() != null) {
            changeRepeat(task, parseRepeat(request.getRepeat(), task.getDueAt()),
                    !previousDue.equals(task.getDueAt()));
        }
        Task saved = taskRepository.save(task);
        if (!previousAssigneeId.equals(saved.getAssignee().getId())) {
            notificationEvents.taskAssigned(saved, currentUser);
        }
        return toResponse(saved);
    }

    /**
     * Completing a finished task again keeps the time it was first done. Completing an occurrence
     * of a repeating task writes the next one, once.
     */
    @Transactional
    public TaskResponse complete(Long id) {
        Task task = findVisibleById(id, securityUtils.getCurrentUser());
        if (task.getCompletedAt() == null) {
            LocalDateTime now = LocalDateTime.now();
            task.setCompletedAt(now);
            writeNext(task, now);
        }
        return toResponse(taskRepository.save(task));
    }

    /**
     * "Stop repeating": the series writes nothing more. Every occurrence stays as it is, the open
     * one included, as a task that no longer repeats. Stopping a task that does not repeat is no
     * change.
     */
    @Transactional
    public TaskResponse stopRepeating(Long id) {
        Task task = findVisibleById(id, securityUtils.getCurrentUser());
        TaskSeries series = task.getSeries();
        if (series != null && series.isActive()) {
            series.setStoppedAt(LocalDateTime.now());
            seriesRepository.save(series);
        }
        return toResponse(task);
    }

    /**
     * The occurrence after {@code done}, for the same person on the same client and deal in the
     * same agency, unless the series is stopped, has ended, or {@code done} already wrote it.
     */
    private void writeNext(Task done, LocalDateTime now) {
        TaskSeries series = done.getSeries();
        if (series == null || !series.isActive() || done.isNextCreated() || done.getOccurrence() == null) {
            return;
        }
        int next = done.getOccurrence() + 1;
        if (taskRepository.existsBySeriesIdAndOccurrence(series.getId(), next)) {
            done.setNextCreated(true);
            return;
        }
        Optional<LocalDateTime> due = RepeatSchedule.nextDue(series, done.getDueAt(), done.getOccurrence(), now);
        if (due.isEmpty()) {
            return;
        }
        taskRepository.save(Task.builder()
                .team(done.getTeam())
                .assignee(done.getAssignee())
                .createdBy(done.getCreatedBy())
                .title(done.getTitle())
                .note(done.getNote())
                .client(done.getClient())
                .deal(done.getDeal())
                .dueAt(due.get())
                .series(series)
                .occurrence(next)
                .build());
        done.setNextCreated(true);
    }

    /** A rule as asked for, checked; null stands for NONE. */
    private record Rule(RepeatFrequency frequency, Set<DayOfWeek> weekdays, LocalDate until, Integer count) {

        Integer weekdayMask() {
            return frequency == RepeatFrequency.WEEKLY ? RepeatSchedule.mask(weekdays) : null;
        }
    }

    private static Rule parseRepeat(TaskRepeatRequest repeat, LocalDateTime due) {
        RepeatFrequency frequency;
        try {
            frequency = RepeatFrequency.valueOf(repeat.getFrequency().trim().toUpperCase(Locale.ROOT));
        } catch (NullPointerException | IllegalArgumentException e) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "INVALID_REPEAT_FREQUENCY",
                    "Repeat must be NONE, DAILY, WEEKLY, MONTHLY, QUARTERLY or YEARLY");
        }
        if (frequency == RepeatFrequency.NONE) {
            return null;
        }
        // Weekdays mean something to a weekly rule only; whatever else carries them is dropped.
        Set<DayOfWeek> weekdays = EnumSet.noneOf(DayOfWeek.class);
        if (frequency == RepeatFrequency.WEEKLY) {
            if (repeat.getWeekdays() != null) {
                for (String day : repeat.getWeekdays()) {
                    try {
                        weekdays.add(DayOfWeek.valueOf(day.trim().toUpperCase(Locale.ROOT)));
                    } catch (NullPointerException | IllegalArgumentException e) {
                        throw new BusinessException(HttpStatus.BAD_REQUEST, "INVALID_WEEKDAY",
                                "Weekdays must be MONDAY ... SUNDAY");
                    }
                }
            }
            if (weekdays.isEmpty()) {
                weekdays.add(due.getDayOfWeek());
            }
        }
        if (repeat.getUntil() != null && repeat.getCount() != null) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "REPEAT_ENDS_TWICE",
                    "A repeat ends on a day or after a number of times, not both");
        }
        if (repeat.getCount() != null && (repeat.getCount() < 1 || repeat.getCount() > 999)) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "INVALID_REPEAT_COUNT",
                    "A repeat ends after 1 to 999 times");
        }
        if (repeat.getUntil() != null && repeat.getUntil().isBefore(due.toLocalDate())) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "REPEAT_UNTIL_BEFORE_DUE",
                    "A repeat cannot end before the task is due");
        }
        return new Rule(frequency, weekdays, repeat.getUntil(), repeat.getCount());
    }

    /** {@code task} becomes the first occurrence of a new series following {@code rule}. */
    private void startSeries(Task task, Rule rule) {
        TaskSeries series = seriesRepository.save(TaskSeries.builder()
                .frequency(rule.frequency())
                .weekdays(rule.weekdayMask())
                .anchorAt(task.getDueAt())
                .countFrom(1)
                .untilDate(rule.until())
                .maxOccurrences(rule.count())
                .build());
        task.setSeries(series);
        task.setOccurrence(1);
        task.setNextCreated(false);
    }

    /**
     * Saving a task with a repeat. NONE stops its series. A rule on a task that does not repeat,
     * or whose series was stopped, starts a new series from it. Otherwise the series takes the
     * rule for the occurrences still to be written: a new pattern, or a new due time on this
     * occurrence, counts the pattern from this occurrence's due time, and a new pattern or end
     * counts "after N times" from this occurrence. The same rule sent back with the same due time
     * changes nothing, so editing the title of an occurrence that a month clamped to the 30th
     * does not move the series off the 31st.
     */
    private void changeRepeat(Task task, Rule rule, boolean dueChanged) {
        TaskSeries series = task.getSeries();
        boolean active = series != null && series.isActive();
        if (rule == null) {
            if (active) {
                series.setStoppedAt(LocalDateTime.now());
                seriesRepository.save(series);
            }
            return;
        }
        if (!active) {
            startSeries(task, rule);
            return;
        }
        boolean pattern = series.getFrequency() != rule.frequency()
                || !Objects.equals(series.getWeekdays(), rule.weekdayMask());
        boolean end = !Objects.equals(series.getUntilDate(), rule.until())
                || !Objects.equals(series.getMaxOccurrences(), rule.count());
        if (pattern || dueChanged) {
            series.setAnchorAt(task.getDueAt());
        }
        if (pattern || end) {
            series.setCountFrom(task.getOccurrence());
        }
        series.setFrequency(rule.frequency());
        series.setWeekdays(rule.weekdayMask());
        series.setUntilDate(rule.until());
        series.setMaxOccurrences(rule.count());
        seriesRepository.save(series);
    }

    @Transactional
    public TaskResponse reopen(Long id) {
        Task task = findVisibleById(id, securityUtils.getCurrentUser());
        task.setCompletedAt(null);
        return toResponse(taskRepository.save(task));
    }

    @Transactional
    public void delete(Long id) {
        taskRepository.delete(findVisibleById(id, securityUtils.getCurrentUser()));
    }

    /** {@code null} means both: the calendar shows done tasks alongside open ones. */
    private static Boolean parseDone(String status) {
        String value = status == null ? "open" : status.trim().toLowerCase(Locale.ROOT);
        return switch (value) {
            case "open" -> false;
            case "done" -> true;
            case "all" -> null;
            default -> throw new BusinessException(HttpStatus.BAD_REQUEST, "INVALID_TASK_STATUS",
                    "Status must be open, done or all");
        };
    }

    /** Someone else's task reads as missing, so its existence is not confirmed either. */
    private Task findVisibleById(Long id, User currentUser) {
        Task task = taskRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Task not found with id: " + id));
        if (!scopeService.canSee(currentUser, task.getTeam(), task.getAssignee())) {
            throw new ResourceNotFoundException("Task not found with id: " + id);
        }
        return task;
    }

    /**
     * A task lives in the agency of what it is about — its client or deal — and otherwise in its
     * assignee's. Whoever it goes to has to work there.
     */
    private void apply(TaskRequest request, Task task, User currentUser) {
        task.setTitle(request.getTitle().trim());
        task.setNote(request.getNote() == null || request.getNote().isBlank() ? null : request.getNote().trim());
        task.setDueAt(request.getDueAt());

        Client client = request.getClientId() == null ? null : visibleClient(request.getClientId(), currentUser);
        Deal deal = request.getDealId() == null ? null : visibleDeal(request.getDealId(), currentUser);
        if (client != null && deal != null) {
            scopeService.requireSameTeam(client.getTeam(), deal.getTeam(), "Deal");
        }
        task.setClient(client);
        task.setDeal(deal);

        User assignee = assigneeFor(request.getAssigneeId(), task, currentUser);
        Team team;
        if (client != null) {
            team = client.getTeam();
        } else if (deal != null) {
            team = deal.getTeam();
        } else {
            team = assignee.getTeam();
        }
        // An admin works across agencies and may keep a reminder about any of them for themselves.
        if (!scopeService.isAdmin(assignee)) {
            scopeService.requireSameTeam(team, assignee.getTeam(), "User");
        }
        task.setAssignee(assignee);
        task.setTeam(team);
    }

    /**
     * Nobody named: the writer on a new task, whoever already holds it otherwise. Taking it
     * yourself, or leaving it where it is, needs no rank; handing it to somebody else takes a
     * manager inside their own agency, or an admin.
     */
    private User assigneeFor(Long assigneeId, Task task, User currentUser) {
        User holder = task.getAssignee();
        if (assigneeId == null) {
            return holder != null ? holder : currentUser;
        }
        if (assigneeId.equals(currentUser.getId())) {
            return currentUser;
        }
        if (holder != null && assigneeId.equals(holder.getId())) {
            return holder;
        }
        if (scopeService.isAdmin(currentUser)) {
            return userRepository.findById(assigneeId)
                    .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + assigneeId));
        }
        if (!scopeService.isManager(currentUser)) {
            throw new AccessDeniedException("Only a manager can give a task to someone else");
        }
        User assignee = userRepository.findById(assigneeId)
                .filter(u -> u.getTeam() != null
                        && Objects.equals(u.getTeam().getId(), scopeService.teamIdOf(currentUser)))
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + assigneeId));
        return assignee;
    }

    private Client visibleClient(Long id, User currentUser) {
        Client client = clientRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Client not found with id: " + id));
        if (!scopeService.canSee(currentUser, client.getTeam(), client.getAgent())) {
            throw new ResourceNotFoundException("Client not found with id: " + id);
        }
        return client;
    }

    private Deal visibleDeal(Long id, User currentUser) {
        Deal deal = dealRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Deal not found with id: " + id));
        if (!scopeService.canSee(currentUser, deal.getTeam(), deal.getAgent())) {
            throw new ResourceNotFoundException("Deal not found with id: " + id);
        }
        return deal;
    }

    static TaskResponse toResponse(Task task) {
        User createdBy = task.getCreatedBy();
        return TaskResponse.builder()
                .id(task.getId())
                .title(task.getTitle())
                .note(task.getNote())
                .dueAt(task.getDueAt())
                .completedAt(task.getCompletedAt())
                .assigneeId(task.getAssignee().getId())
                .assigneeName(task.getAssignee().getFullName())
                .createdById(createdBy == null ? null : createdBy.getId())
                .createdByName(createdBy == null ? null : createdBy.getFullName())
                .clientId(task.getClient() == null ? null : task.getClient().getId())
                .clientName(task.getClient() == null ? null : task.getClient().getFullName())
                .dealId(task.getDeal() == null ? null : task.getDeal().getId())
                .dealTitle(task.getDeal() == null ? null : task.getDeal().getTitle())
                .seriesId(task.getSeries() == null ? null : task.getSeries().getId())
                .occurrence(task.getSeries() == null ? null : task.getOccurrence())
                .repeat(repeatOf(task.getSeries()))
                .createdAt(task.getCreatedAt())
                .updatedAt(task.getUpdatedAt())
                .build();
    }

    private static TaskRepeatResponse repeatOf(TaskSeries series) {
        if (series == null || !series.isActive()) {
            return null;
        }
        return TaskRepeatResponse.builder()
                .frequency(series.getFrequency())
                .weekdays(List.copyOf(RepeatSchedule.weekdays(series.getWeekdays())))
                .until(series.getUntilDate())
                .count(series.getMaxOccurrences())
                .anchorAt(series.getAnchorAt())
                .build();
    }
}
