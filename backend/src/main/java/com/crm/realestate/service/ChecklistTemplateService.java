package com.crm.realestate.service;

import com.crm.realestate.dto.request.ChecklistTemplateRequest;
import com.crm.realestate.dto.response.ChecklistItemResponse;
import com.crm.realestate.entity.ChecklistTemplateItem;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ChecklistStage;
import com.crm.realestate.enums.Role;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.ChecklistTemplateItemRepository;
import com.crm.realestate.repository.TeamRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;

/**
 * An agency's deal checklist template: what a deal should collect at each stage.
 *
 * <p>Everybody in the agency reads it; its manager (or an admin) rewrites it. Agencies get the
 * {@link DefaultChecklist} the first time anybody needs the template — when the manager creates
 * the agency, and for agencies older than the feature, on first read. Rewriting it changes what
 * new deals start with; deals already under way keep the copy they were given.
 */
@Service
@RequiredArgsConstructor
public class ChecklistTemplateService {

    static final Comparator<ChecklistTemplateItem> ORDER = Comparator
            .comparing(ChecklistTemplateItem::getStage)
            .thenComparing(ChecklistTemplateItem::getPosition)
            .thenComparing(ChecklistTemplateItem::getId);

    private final ChecklistTemplateItemRepository templateRepository;
    private final TeamRepository teamRepository;
    private final AuditLogService auditLogService;

    @Transactional
    public List<ChecklistItemResponse> get(User reader, Long teamId) {
        Team team = teamOf(reader, teamId);
        return items(team, reader).stream().map(ChecklistTemplateService::toResponse).toList();
    }

    /** Replaces the whole template, in the order given within each stage. Audited. */
    @Transactional
    public List<ChecklistItemResponse> replace(User actor, Long teamId, ChecklistTemplateRequest request) {
        if (actor.getRole() == Role.AGENT) {
            throw new BusinessException(HttpStatus.FORBIDDEN, "MANAGER_ONLY",
                    "Only the agency's manager can change the checklist");
        }
        Team team = teamOf(actor, teamId);
        List<ChecklistTemplateItem> next = new ArrayList<>();
        Map<ChecklistStage, Integer> positions = new EnumMap<>(ChecklistStage.class);
        for (ChecklistTemplateRequest.Item item : request.getItems()) {
            String title = item.getTitle() == null ? "" : item.getTitle().strip();
            if (title.isEmpty()) {
                throw new BusinessException(HttpStatus.BAD_REQUEST, "CHECKLIST_TITLE_REQUIRED",
                        "Every checklist item needs a title");
            }
            int position = positions.merge(item.getStage(), 1, Integer::sum) - 1;
            next.add(ChecklistTemplateItem.builder().team(team).stage(item.getStage())
                    .title(title).position(position).required(item.isRequired()).build());
        }
        // Mark first: a template the manager wrote — even an empty one — is never replaced by the default.
        templateRepository.markSeeded(team.getId());
        templateRepository.deleteByTeam(team.getId());
        List<ChecklistTemplateItem> saved = templateRepository.saveAll(next);
        auditLogService.record(actor, "UPDATE_CHECKLIST_TEMPLATE", "Team", team.getId(),
                "items=" + saved.size() + ", required="
                        + saved.stream().filter(ChecklistTemplateItem::isRequired).count());
        return saved.stream().sorted(ORDER).map(ChecklistTemplateService::toResponse).toList();
    }

    /** The template in order, written from the default first if this agency has never had one. */
    @Transactional
    public List<ChecklistTemplateItem> items(Team team, User reader) {
        seedIfNeeded(team, reader);
        return templateRepository.findByTeamId(team.getId()).stream().sorted(ORDER).toList();
    }

    /**
     * Writes the default template unless the agency already has had one. {@code reader} decides
     * the language: an agency's own manager gets theirs, anybody else the fallback.
     */
    @Transactional
    public void seedIfNeeded(Team team, User reader) {
        if (team.isChecklistTemplateSeeded() || templateRepository.markSeeded(team.getId()) == 0) {
            return;
        }
        String language = languageFor(team, reader);
        Map<ChecklistStage, Integer> positions = new EnumMap<>(ChecklistStage.class);
        templateRepository.saveAll(DefaultChecklist.LINES.stream()
                .map(line -> ChecklistTemplateItem.builder()
                        .team(team)
                        .stage(line.stage())
                        .title(line.title(language))
                        .position(positions.merge(line.stage(), 1, Integer::sum) - 1)
                        .required(line.required())
                        .build())
                .toList());
    }

    /** The language defaults are written in: see {@link DefaultChecklist}. Message templates share it. */
    static String languageFor(Team team, User reader) {
        boolean ownManager = reader != null && reader.getRole() == Role.MANAGER
                && reader.getTeam() != null && reader.getTeam().getId().equals(team.getId());
        String language = ownManager ? DefaultChecklist.supported(acceptLanguage()) : null;
        return language != null ? language : DefaultChecklist.FALLBACK_LANGUAGE;
    }

    private static String acceptLanguage() {
        if (RequestContextHolder.getRequestAttributes() instanceof ServletRequestAttributes attributes) {
            return attributes.getRequest().getHeader("Accept-Language");
        }
        return null;
    }

    /** The reader's own agency; an admin, who runs none, names one. */
    private Team teamOf(User user, Long teamId) {
        if (user.getRole() == Role.ADMIN && teamId != null) {
            return teamRepository.findById(teamId)
                    .orElseThrow(() -> new ResourceNotFoundException("Team not found with id: " + teamId));
        }
        if (user.getTeam() == null) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "TEAM_REQUIRED",
                    "Say which agency's checklist this is");
        }
        return user.getTeam();
    }

    static ChecklistItemResponse toResponse(ChecklistTemplateItem item) {
        return ChecklistItemResponse.builder()
                .id(item.getId())
                .stage(item.getStage())
                .title(item.getTitle())
                .position(item.getPosition())
                .required(item.isRequired())
                .build();
    }
}
