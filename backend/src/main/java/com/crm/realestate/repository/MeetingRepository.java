package com.crm.realestate.repository;

import com.crm.realestate.entity.Meeting;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface MeetingRepository extends JpaRepository<Meeting, Long> {

    List<Meeting> findByAgentId(Long agentId);

    List<Meeting> findByClientId(Long clientId);

    List<Meeting> findByDealId(Long dealId);

    List<Meeting> findByAgentIdAndCompleted(Long agentId, boolean completed);

    @Query("SELECT m FROM Meeting m WHERE m.agent.id = :agentId " +
           "AND m.scheduledAt BETWEEN :from AND :to ORDER BY m.scheduledAt ASC")
    List<Meeting> findUpcomingByAgent(
            @Param("agentId") Long agentId,
            @Param("from")    LocalDateTime from,
            @Param("to")      LocalDateTime to
    );

    @Query("SELECT m FROM Meeting m WHERE m.completed = false " +
           "AND m.scheduledAt > :now ORDER BY m.scheduledAt ASC")
    List<Meeting> findAllUpcoming(@Param("now") LocalDateTime now);
}