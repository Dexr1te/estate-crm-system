package com.crm.realestate.service;

import com.crm.realestate.dto.request.TaskRequest;
import com.crm.realestate.dto.response.TaskResponse;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Task;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.TaskRepository;
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

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Objects;

/**
 * Follow-ups with a due time: "call Irina back on Friday".
 *
 * <p>A task sits behind the same walls as a meeting, with its assignee in the agent's place: an
 * agent on their own records sees the tasks they have to do, a team sees the agency's, and another
 * agency's task answers not found. Linking one to a client or a deal the caller cannot read is
 * refused the same way, so the refusal does not confirm the record exists.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class TaskService {

    /** The name of a task's holder, for {@link ScopeService#visibleTo(User, String)}. */
    public static final String HOLDER = "assignee";

    private final TaskRepository   taskRepository;
    private final ClientRepository clientRepository;
    private final DealRepository   dealRepository;
    private final UserRepository   userRepository;
    private final SecurityUtils    securityUtils;
    private final ScopeService     scopeService;

    /**
     * Open tasks soonest first, so the overdue ones lead; finished ones most recently done first.
     */
    public List<TaskResponse> list(String status, Long clientId, Long dealId, Long assigneeId) {
        boolean done = parseDone(status);
        Specification<Task> filter = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();
            predicates.add(done ? cb.isNotNull(root.get("completedAt")) : cb.isNull(root.get("completedAt")));
            if (clientId != null) {
                predicates.add(cb.equal(root.get("client").get("id"), clientId));
            }
            if (dealId != null) {
                predicates.add(cb.equal(root.get("deal").get("id"), dealId));
            }
            if (assigneeId != null) {
                predicates.add(cb.equal(root.get(HOLDER).get("id"), assigneeId));
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
        return toResponse(taskRepository.save(task));
    }

    @Transactional
    public TaskResponse update(Long id, TaskRequest request) {
        User currentUser = securityUtils.getCurrentUser();
        Task task = findVisibleById(id, currentUser);
        apply(request, task, currentUser);
        return toResponse(taskRepository.save(task));
    }

    /** Completing a finished task again keeps the time it was first done. */
    @Transactional
    public TaskResponse complete(Long id) {
        Task task = findVisibleById(id, securityUtils.getCurrentUser());
        if (task.getCompletedAt() == null) {
            task.setCompletedAt(LocalDateTime.now());
        }
        return toResponse(taskRepository.save(task));
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

    private static boolean parseDone(String status) {
        String value = status == null ? "open" : status.trim().toLowerCase(Locale.ROOT);
        return switch (value) {
            case "open" -> false;
            case "done" -> true;
            default -> throw new BusinessException(HttpStatus.BAD_REQUEST, "INVALID_TASK_STATUS",
                    "Status must be open or done");
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
                .createdAt(task.getCreatedAt())
                .updatedAt(task.getUpdatedAt())
                .build();
    }
}
