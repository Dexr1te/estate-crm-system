package com.crm.realestate.service;

import com.crm.realestate.enums.StarType;
import com.crm.realestate.repository.StarRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;

/**
 * What deleting a record has to do about the stars on it (V57), kept apart from the stars' own
 * API so the services that delete clients, listings and deals can lean on it without a cycle —
 * {@link StarService} reads those records through them.
 *
 * <p>A star names its record by type and id, with no foreign key to take it along, so whatever
 * deletes a record calls in here in the same transaction. The list of stars also keeps to the
 * records the person may still see, so a star this misses is never shown; it is only left behind.
 */
@Component
@RequiredArgsConstructor
public class StarStore {

    private final StarRepository repository;

    /** The record is being deleted: everybody's star on it goes with it. */
    public void recordDeleted(StarType type, Long id) {
        repository.deleteForRecords(type, List.of(id));
    }

    /**
     * {@code sourceId} is merged into {@code targetId} and deleted: whoever starred the card that
     * goes has the one that stays starred instead, once.
     */
    public void clientMerged(Long sourceId, Long targetId) {
        repository.moveToRecord(StarType.CLIENT, sourceId, targetId);
        repository.deleteForRecords(StarType.CLIENT, List.of(sourceId));
    }
}
