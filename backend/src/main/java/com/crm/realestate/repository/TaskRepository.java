package com.crm.realestate.repository;

import com.crm.realestate.entity.Task;
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
import java.util.Optional;

@Repository
public interface TaskRepository extends JpaRepository<Task, Long>, JpaSpecificationExecutor<Task> {

    // The response names the assignee, author, client and deal; all to-one, so joining them
    // cannot duplicate rows and a list costs one statement.

    @Override
    @EntityGraph(attributePaths = {"assignee", "createdBy", "client", "deal"})
    Optional<Task> findById(Long id);

    @Override
    @EntityGraph(attributePaths = {"assignee", "createdBy", "client", "deal"})
    List<Task> findAll(Specification<Task> spec, Sort sort);

    List<Task> findByAssigneeId(Long assigneeId);

    /** Moves this person's team-less tasks into their team — see RecordHandoverService. */
    @Modifying(flushAutomatically = true)
    @Query("UPDATE Task t SET t.team = :team WHERE t.assignee = :assignee AND t.team IS NULL")
    int adoptTeamless(@Param("assignee") User assignee, @Param("team") Team team);

    /** Hands tasks held in a team to a colleague — see RecordHandoverService. */
    @Modifying(flushAutomatically = true)
    @Query("UPDATE Task t SET t.assignee = :to WHERE t.assignee = :from AND t.team = :team")
    int reassignInTeam(@Param("from") User from, @Param("to") User to, @Param("team") Team team);
}
