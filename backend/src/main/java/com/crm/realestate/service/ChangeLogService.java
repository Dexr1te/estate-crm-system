package com.crm.realestate.service;

import com.crm.realestate.entity.RecordChange;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ChangeAction;
import com.crm.realestate.enums.ChangeEntityType;
import com.crm.realestate.repository.RecordChangeRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Objects;

/**
 * Writes the change log of listings, deals and clients (V49).
 *
 * <p>Called by name from each place that creates, edits or deletes one of them, in the same
 * transaction, so a change that is rolled back leaves no line and a line is never missing for a
 * change that stuck. Reading the log is {@link ChangeHistoryService}'s.
 */
@Service
@RequiredArgsConstructor
@Transactional
public class ChangeLogService {

    /** Long notes are cut here; the log says what a description became, not every word of it. */
    static final int VALUE_MAX = 1000;
    static final int LABEL_MAX = 255;

    private final RecordChangeRepository repository;

    public void created(ChangeSnapshot.Target target, User actor) {
        repository.save(line(target, actor, nameOf(actor), ChangeAction.CREATED, null, null, null,
                LocalDateTime.now()));
    }

    public void deleted(ChangeSnapshot.Target target, User actor) {
        repository.save(line(target, actor, nameOf(actor), ChangeAction.DELETED, null, null, null,
                LocalDateTime.now()));
    }

    /**
     * A line for every field whose value differs between the two snapshots, all with one time so
     * the app can show one save as one entry. Nothing is written when nothing moved.
     *
     * @return how many lines were written
     */
    public int changed(ChangeSnapshot.Target target, User actor,
                       Map<String, String> before, Map<String, String> after) {
        LocalDateTime now = LocalDateTime.now();
        List<RecordChange> lines = new ArrayList<>();
        for (Map.Entry<String, String> field : after.entrySet()) {
            String old = before.get(field.getKey());
            if (!Objects.equals(old, field.getValue())) {
                lines.add(line(target, actor, nameOf(actor), actionFor(target.type(), field.getKey()),
                        field.getKey(), old, field.getValue(), now));
            }
        }
        repository.saveAll(lines);
        return lines.size();
    }

    /** One field, when the caller already knows what moved — a listing a deal reserved, say. */
    public void fieldChanged(ChangeSnapshot.Target target, User actor, String field,
                             String oldValue, String newValue) {
        if (Objects.equals(oldValue, newValue)) {
            return;
        }
        repository.save(line(target, actor, nameOf(actor), actionFor(target.type(), field), field,
                oldValue, newValue, LocalDateTime.now()));
    }

    /**
     * The record went from one agent to another. {@code actorName} is given separately because
     * the person handing over may be the account that is about to be deleted: no reference is
     * kept to it then, only the name.
     */
    public void agentChanged(ChangeSnapshot.Target target, User actor, String actorName,
                             User from, User to) {
        repository.save(line(target, actor, actorName, ChangeAction.AGENT_CHANGED, "agent",
                ChangeSnapshot.person(from), ChangeSnapshot.person(to), LocalDateTime.now()));
    }

    /**
     * Everything {@code from} holds in {@code team} is about to go to {@code to} in one bulk
     * update; this writes the line each of those clients, listings and deals gets for it. Read
     * before the update, since afterwards nothing tells them apart from what {@code to} already had.
     */
    public void handingOver(User from, User to, Team team, User actor) {
        LocalDateTime now = LocalDateTime.now();
        String fromName = ChangeSnapshot.person(from);
        String toName = ChangeSnapshot.person(to);
        List<RecordChange> lines = new ArrayList<>();
        addHandover(lines, ChangeEntityType.CLIENT, repository.clientsHeldInTeam(from, team),
                team, actor, fromName, toName, now);
        addHandover(lines, ChangeEntityType.PROPERTY, repository.propertiesHeldInTeam(from, team),
                team, actor, fromName, toName, now);
        addHandover(lines, ChangeEntityType.DEAL, repository.dealsHeldInTeam(from, team),
                team, actor, fromName, toName, now);
        repository.saveAll(lines);
    }

    private void addHandover(List<RecordChange> lines, ChangeEntityType type, List<Object[]> rows,
                             Team team, User actor, String fromName, String toName, LocalDateTime now) {
        for (Object[] row : rows) {
            ChangeSnapshot.Target target = new ChangeSnapshot.Target(type, (Long) row[0], team, (String) row[1]);
            lines.add(line(target, actor, nameOf(actor), ChangeAction.AGENT_CHANGED, "agent",
                    fromName, toName, now));
        }
    }

    /** Which kind of edit a field's move is; the field itself is kept either way. */
    static ChangeAction actionFor(ChangeEntityType type, String field) {
        return switch (field) {
            case "status" -> ChangeAction.STATUS_CHANGED;
            case "agent" -> ChangeAction.AGENT_CHANGED;
            case "price" -> type == ChangeEntityType.PROPERTY ? ChangeAction.PRICE_CHANGED : ChangeAction.UPDATED;
            case "dealPrice", "monthlyRent" ->
                    type == ChangeEntityType.DEAL ? ChangeAction.PRICE_CHANGED : ChangeAction.UPDATED;
            default -> ChangeAction.UPDATED;
        };
    }

    private static RecordChange line(ChangeSnapshot.Target target, User actor, String actorName,
                                     ChangeAction action, String field, String oldValue,
                                     String newValue, LocalDateTime at) {
        return RecordChange.builder()
                .team(target.team())
                .entityType(target.type())
                .entityId(target.id())
                .entityLabel(cut(target.label(), LABEL_MAX))
                .actor(actor)
                .actorName(cut(actorName, LABEL_MAX))
                .action(action)
                .field(field)
                .oldValue(cut(oldValue, VALUE_MAX))
                .newValue(cut(newValue, VALUE_MAX))
                .changedAt(at)
                .build();
    }

    private static String nameOf(User actor) {
        return ChangeSnapshot.person(actor);
    }

    private static String cut(String value, int max) {
        return value == null || value.length() <= max ? value : value.substring(0, max - 1) + "…";
    }
}
