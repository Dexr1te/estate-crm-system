package com.crm.realestate.repository;

import com.crm.realestate.entity.TimeOff;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.Collection;
import java.util.List;

@Repository
public interface TimeOffRepository extends JpaRepository<TimeOff, Long> {

    /**
     * An agency's absences that take in any day of {@code [from, to]}, soonest first, each with
     * its person, cover and author. Only people who still work there and are active: someone who
     * left or was switched off is nobody's concern on the team list.
     */
    @Query("SELECT t FROM TimeOff t JOIN FETCH t.user u LEFT JOIN FETCH t.cover LEFT JOIN FETCH t.createdBy "
            + "WHERE t.team.id = :teamId AND u.team.id = :teamId AND u.isActive = true "
            + "AND t.startDate <= :to AND t.endDate >= :from "
            + "AND (:userId IS NULL OR u.id = :userId) "
            + "ORDER BY t.startDate ASC, t.endDate ASC, t.id ASC")
    List<TimeOff> findInTeam(@Param("teamId") Long teamId, @Param("from") LocalDate from,
                             @Param("to") LocalDate to, @Param("userId") Long userId);

    /** One person's absences in an agency that share a day with {@code [from, to]}, but {@code exceptId}. */
    @Query("SELECT t FROM TimeOff t WHERE t.user.id = :userId AND t.team.id = :teamId "
            + "AND t.startDate <= :to AND t.endDate >= :from AND (:exceptId IS NULL OR t.id <> :exceptId) "
            + "ORDER BY t.startDate ASC")
    List<TimeOff> findOverlapping(@Param("userId") Long userId, @Param("teamId") Long teamId,
                                  @Param("from") LocalDate from, @Param("to") LocalDate to,
                                  @Param("exceptId") Long exceptId);

    /** The absences of these people in an agency that have not ended by {@code today}, soonest first. */
    @Query("SELECT t FROM TimeOff t WHERE t.team.id = :teamId AND t.user.id IN :userIds "
            + "AND t.endDate >= :today ORDER BY t.startDate ASC, t.id ASC")
    List<TimeOff> findNotOverFor(@Param("teamId") Long teamId, @Param("userIds") Collection<Long> userIds,
                                 @Param("today") LocalDate today);

    /** Someone leaves an agency: their absences there go with them. */
    @Modifying(flushAutomatically = true)
    @Query("DELETE FROM TimeOff t WHERE t.user = :user AND t.team = :team")
    int deleteForUserInTeam(@Param("user") User user, @Param("team") Team team);

    /** Someone closes their account: every absence of theirs goes. */
    @Modifying(flushAutomatically = true)
    @Query("DELETE FROM TimeOff t WHERE t.user = :user")
    int deleteForUser(@Param("user") User user);

    /** The absences somebody covers anywhere, for whoever is to take the cover over. */
    List<TimeOff> findByCoverId(Long coverId);

    List<TimeOff> findByCoverIdAndTeamId(Long coverId, Long teamId);
}
