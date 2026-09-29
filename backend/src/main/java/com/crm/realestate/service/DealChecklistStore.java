package com.crm.realestate.service;

import com.crm.realestate.entity.ChecklistTemplateItem;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.DealChecklistItem;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ChecklistStage;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.repository.ChecklistTemplateItemRepository;
import com.crm.realestate.repository.DealChecklistItemRepository;
import jakarta.persistence.EntityManager;
import jakarta.persistence.LockModeType;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.EnumMap;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * A deal's copy of its agency's checklist: made when the deal is, made on first read for deals
 * older than the feature, and counted for the deal list without a query per deal.
 *
 * <p>A deal "has its copy" once it has any line. A deal of an agency whose template is empty has
 * none, and picks one up on its next read after the template gains lines — the same thing an old
 * deal does.
 */
@Component
@RequiredArgsConstructor
public class DealChecklistStore {

    /** Done and total for the current stage and the ones before it; open required lines per stage. */
    public record Summary(long done, long total, long openRequired, Map<ChecklistStage, Long> openRequiredByStage) {
        static final Summary EMPTY = new Summary(0, 0, 0, Map.of());
    }

    private final DealChecklistItemRepository itemRepository;
    private final ChecklistTemplateItemRepository templateRepository;
    private final ChecklistTemplateService templateService;
    private final EntityManager entityManager;

    /** Gives a new deal its agency's checklist. */
    @Transactional
    public void copyTemplate(Deal deal, User reader) {
        if (deal.getTeam() == null) {
            return;
        }
        List<ChecklistTemplateItem> template = templateService.items(deal.getTeam(), reader);
        itemRepository.saveAll(template.stream()
                .map(t -> DealChecklistItem.builder()
                        .deal(deal)
                        .team(deal.getTeam())
                        .stage(t.getStage())
                        .title(t.getTitle())
                        .position(t.getPosition())
                        .required(t.isRequired())
                        .build())
                .toList());
    }

    /**
     * Copies the template onto a deal that has no checklist yet. The deal's row is locked first so
     * two first reads at once cannot both copy it.
     */
    @Transactional
    public void ensureCopied(Deal deal, User reader) {
        if (deal.getTeam() == null || itemRepository.existsByDealId(deal.getId())) {
            return;
        }
        entityManager.lock(deal, LockModeType.PESSIMISTIC_WRITE);
        if (!itemRepository.existsByDealId(deal.getId())) {
            copyTemplate(deal, reader);
        }
    }

    /**
     * The checklist progress of every deal given, in at most three queries however many there are.
     * A deal without its copy yet is counted from its agency's template — exactly what its first
     * read will give it — so the list does not write.
     */
    @Transactional(readOnly = true)
    public Map<Long, Summary> summarize(List<Deal> deals) {
        if (deals.isEmpty()) {
            return Map.of();
        }
        // dealId → stage → {total, done, requiredTotal, requiredDone}
        Map<Long, Map<ChecklistStage, long[]>> byDeal = new HashMap<>();
        for (Object[] row : itemRepository.statsByDeals(deals.stream().map(Deal::getId).toList())) {
            long[] cell = byDeal.computeIfAbsent((Long) row[0], k -> new EnumMap<>(ChecklistStage.class))
                    .computeIfAbsent((ChecklistStage) row[1], k -> new long[4]);
            long total = ((Number) row[3]).longValue();
            long done = ((Number) row[4]).longValue();
            cell[0] += total;
            cell[1] += done;
            if (Boolean.TRUE.equals(row[2])) {
                cell[2] += total;
                cell[3] += done;
            }
        }
        Map<Long, Map<ChecklistStage, long[]>> byTeam = templateStats(deals, byDeal.keySet());

        Map<Long, Summary> summaries = new HashMap<>();
        for (Deal deal : deals) {
            Map<ChecklistStage, long[]> stats = byDeal.get(deal.getId());
            if (stats == null && deal.getTeam() != null) {
                stats = byTeam.get(deal.getTeam().getId());
            }
            summaries.put(deal.getId(), stats == null ? Summary.EMPTY : summaryOf(deal.getStatus(), stats));
        }
        return summaries;
    }

    /** For the deals without a copy yet: their agencies' templates, as stage → {total, 0, required, 0}. */
    private Map<Long, Map<ChecklistStage, long[]>> templateStats(List<Deal> deals, Set<Long> copied) {
        Set<Long> teamIds = new HashSet<>();
        for (Deal deal : deals) {
            if (!copied.contains(deal.getId()) && deal.getTeam() != null) {
                teamIds.add(deal.getTeam().getId());
            }
        }
        Map<Long, Map<ChecklistStage, long[]>> byTeam = new HashMap<>();
        if (teamIds.isEmpty()) {
            return byTeam;
        }
        Set<Long> seeded = new HashSet<>(templateRepository.seededAmong(teamIds));
        for (Long teamId : teamIds) {
            Map<ChecklistStage, long[]> stats = new EnumMap<>(ChecklistStage.class);
            if (!seeded.contains(teamId)) {
                DefaultChecklist.STATS.forEach((stage, c) -> stats.put(stage, new long[] {c[0], 0, c[1], 0}));
            }
            byTeam.put(teamId, stats);
        }
        if (!seeded.isEmpty()) {
            for (Object[] row : templateRepository.statsByTeams(seeded)) {
                long[] cell = byTeam.get((Long) row[0])
                        .computeIfAbsent((ChecklistStage) row[1], k -> new long[4]);
                long count = ((Number) row[3]).longValue();
                cell[0] += count;
                if (Boolean.TRUE.equals(row[2])) {
                    cell[2] += count;
                }
            }
        }
        return byTeam;
    }

    private static Summary summaryOf(DealStatus status, Map<ChecklistStage, long[]> stats) {
        ChecklistStage reached = ChecklistStage.reachedBy(status);
        long done = 0;
        long total = 0;
        long openRequired = 0;
        Map<ChecklistStage, Long> openByStage = new EnumMap<>(ChecklistStage.class);
        for (ChecklistStage stage : ChecklistStage.values()) {
            long[] cell = stats.getOrDefault(stage, new long[4]);
            openByStage.put(stage, cell[2] - cell[3]);
            if (stage.compareTo(reached) <= 0) {
                done += cell[1];
                total += cell[0];
            }
            if (stage.compareTo(reached) < 0 && status != DealStatus.CLOSED_LOST) {
                openRequired += cell[2] - cell[3];
            }
        }
        return new Summary(done, total, openRequired, openByStage);
    }
}
