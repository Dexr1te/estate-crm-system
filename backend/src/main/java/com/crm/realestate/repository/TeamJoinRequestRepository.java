package com.crm.realestate.repository;

import com.crm.realestate.entity.TeamJoinRequest;
import com.crm.realestate.enums.JoinRequestStatus;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface TeamJoinRequestRepository extends JpaRepository<TeamJoinRequest, Long> {

    @EntityGraph(attributePaths = {"team", "team.manager", "user", "invitedBy"})
    List<TeamJoinRequest> findByUserIdAndStatusOrderByCreatedAtDesc(Long userId, JoinRequestStatus status);

    @EntityGraph(attributePaths = {"team", "team.manager", "user", "invitedBy"})
    List<TeamJoinRequest> findByTeamIdAndStatusOrderByCreatedAtDesc(Long teamId, JoinRequestStatus status);

    boolean existsByTeamIdAndUserIdAndStatus(Long teamId, Long userId, JoinRequestStatus status);

    /** Joining one team makes every other open invitation moot. */
    @Modifying(flushAutomatically = true)
    @Query("UPDATE TeamJoinRequest r SET r.status = com.crm.realestate.enums.JoinRequestStatus.CANCELLED, "
            + "r.respondedAt = :now WHERE r.user.id = :userId "
            + "AND r.status = com.crm.realestate.enums.JoinRequestStatus.PENDING AND r.id <> :keepId")
    int cancelOtherPending(@Param("userId") Long userId, @Param("keepId") Long keepId,
                           @Param("now") LocalDateTime now);
}
