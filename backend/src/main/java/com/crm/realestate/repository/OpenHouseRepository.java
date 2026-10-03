package com.crm.realestate.repository;

import com.crm.realestate.entity.OpenHouse;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface OpenHouseRepository extends JpaRepository<OpenHouse, Long>, JpaSpecificationExecutor<OpenHouse> {

    /** The calendar's window: every row names its listing and its host, so both come along. */
    @Override
    @EntityGraph(attributePaths = {"property", "agent"})
    List<OpenHouse> findAll(Specification<OpenHouse> spec, Sort sort);

    /** A listing's open houses, the latest first. */
    @Query("SELECT o FROM OpenHouse o JOIN FETCH o.property LEFT JOIN FETCH o.agent "
            + "WHERE o.property.id = :propertyId ORDER BY o.startsAt DESC, o.id DESC")
    List<OpenHouse> findByPropertyNewestFirst(@Param("propertyId") Long propertyId);

    /** The open houses someone is still to host in a team — see WorkHandoverService. */
    List<OpenHouse> findByAgentIdAndTeamIdAndEndsAtAfter(Long agentId, Long teamId, java.time.LocalDateTime now);

    /** Hands open houses held in a team to a colleague — see RecordHandoverService. */
    @Modifying(flushAutomatically = true)
    @Query("UPDATE OpenHouse o SET o.agent = :to WHERE o.agent = :from AND o.team = :team")
    int reassignInTeam(@Param("from") User from, @Param("to") User to, @Param("team") Team team);

    /** Hands every open house someone holds to their successor — see AccountRemovalService. */
    @Modifying(flushAutomatically = true)
    @Query("UPDATE OpenHouse o SET o.agent = :to WHERE o.agent = :from")
    int reassignAll(@Param("from") User from, @Param("to") User to);
}
