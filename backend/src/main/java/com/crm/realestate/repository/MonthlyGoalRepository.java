package com.crm.realestate.repository;

import com.crm.realestate.entity.MonthlyGoal;
import com.crm.realestate.enums.GoalSource;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface MonthlyGoalRepository extends JpaRepository<MonthlyGoal, Long> {

    /** Every target this agency has for the month: the agency's own and each person's. */
    List<MonthlyGoal> findByTeamIdAndMonthStart(Long teamId, LocalDate monthStart);

    /** One person's targets for the month, inside one agency: the manager's and their own. */
    List<MonthlyGoal> findByTeamIdAndAgentIdAndMonthStart(Long teamId, Long agentId, LocalDate monthStart);

    Optional<MonthlyGoal> findByTeamIdAndAgentIdAndMonthStartAndSource(
            Long teamId, Long agentId, LocalDate monthStart, GoalSource source);

    @Query("SELECT g FROM MonthlyGoal g WHERE g.team.id = :teamId AND g.agent IS NULL "
            + "AND g.monthStart = :monthStart")
    Optional<MonthlyGoal> findAgencyGoal(@Param("teamId") Long teamId, @Param("monthStart") LocalDate monthStart);
}
