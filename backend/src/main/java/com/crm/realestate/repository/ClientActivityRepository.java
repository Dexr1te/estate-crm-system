package com.crm.realestate.repository;

import com.crm.realestate.entity.ClientActivity;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ClientActivityRepository extends JpaRepository<ClientActivity, Long> {

    /** Newest first. The author is read off every row, so it is joined rather than fetched per row. */
    @Query("SELECT a FROM ClientActivity a LEFT JOIN FETCH a.author "
            + "WHERE a.client.id = :clientId ORDER BY a.occurredAt DESC, a.id DESC")
    List<ClientActivity> findByClientNewestFirst(@Param("clientId") Long clientId);

    /**
     * Brings the history of clients that have just joined a team along with them — see
     * RecordHandoverService. Run after the clients themselves have moved.
     */
    @Modifying(flushAutomatically = true)
    @Query("UPDATE ClientActivity a SET a.team = :team WHERE a.team IS NULL AND a.client.id IN "
            + "(SELECT c.id FROM Client c WHERE c.team = :team AND c.agent = :agent)")
    int adoptTeamless(@Param("agent") User agent, @Param("team") Team team);
}
