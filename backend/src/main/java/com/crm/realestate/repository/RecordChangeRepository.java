package com.crm.realestate.repository;

import com.crm.realestate.entity.RecordChange;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ChangeEntityType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface RecordChangeRepository
        extends JpaRepository<RecordChange, Long>, JpaSpecificationExecutor<RecordChange> {

    /** One record's history, newest first; the order is the caller's {@code Pageable}. */
    @EntityGraph(attributePaths = {"actor"})
    Page<RecordChange> findByEntityTypeAndEntityId(ChangeEntityType entityType, Long entityId,
                                                   Pageable pageable);

    @EntityGraph(attributePaths = {"actor"})
    List<RecordChange> findByEntityTypeAndEntityIdOrderByIdAsc(ChangeEntityType entityType, Long entityId);

    // What a handover is about to move, read before the bulk update so each record can say so.

    @Query("SELECT c.id, c.fullName FROM Client c WHERE c.agent = :from AND c.team = :team")
    List<Object[]> clientsHeldInTeam(@Param("from") User from, @Param("team") Team team);

    @Query("SELECT p.id, p.title FROM Property p WHERE p.agent = :from AND p.team = :team")
    List<Object[]> propertiesHeldInTeam(@Param("from") User from, @Param("team") Team team);

    @Query("SELECT d.id, d.title FROM Deal d WHERE d.agent = :from AND d.team = :team")
    List<Object[]> dealsHeldInTeam(@Param("from") User from, @Param("team") Team team);
}
