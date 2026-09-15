package com.crm.realestate.service;

import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.Role;
import com.crm.realestate.exception.ResourceNotFoundException;
import jakarta.persistence.criteria.Predicate;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Component;

import java.util.Objects;

/**
 * Decides which business records — clients, listings, deals, meetings — someone may see.
 *
 * <p>Two walls, applied together:
 *
 * <ol>
 *   <li><b>The team.</b> A team is an agency, and nothing crosses between agencies. Someone who
 *       belongs to no team sees only records that are their own and in no team either — what an
 *       account accumulated before teams existed, until it joins one.
 *   <li><b>The data scope, inside the team.</b> {@link DataScope#OWN} narrows to records the person
 *       is the agent on; {@link DataScope#TEAM} sees the whole team. {@link DataScope#ALL} means the
 *       whole platform and is honoured for admins only — anyone else holding it is treated as TEAM,
 *       so a stray value on a manager can never open another agency's books.
 * </ol>
 *
 * <p>Admins operate the platform and see everything.
 *
 * <p>Every read goes through {@link #visibleTo} or {@link #canSee}, so the rule lives here once
 * rather than as a filter each service has to remember.
 */
@Component
public class ScopeService {

    private static final String TEAM = "team";
    private static final String AGENT = "agent";

    public boolean isAdmin(User user) {
        return user != null && user.getRole() == Role.ADMIN;
    }

    public boolean isManager(User user) {
        return user != null && user.getRole() == Role.MANAGER;
    }

    public boolean isAgent(User user) {
        return user != null && user.getRole() == Role.AGENT;
    }

    /** The agency this person works in, or null if they are not in one. */
    public Long teamIdOf(User user) {
        return user == null || user.getTeam() == null ? null : user.getTeam().getId();
    }

    /** Whether, inside their team, this person sees colleagues' records as well as their own. */
    public boolean seesWholeTeam(User user) {
        return user != null && user.getDataScope() != DataScope.OWN;
    }

    /** Records this person may see, filtered by both walls. */
    public <T> Specification<T> visibleTo(User user) {
        return (root, query, cb) -> {
            if (user == null) {
                return cb.disjunction();
            }
            if (isAdmin(user)) {
                return cb.conjunction();
            }
            Predicate mine = cb.equal(root.get(AGENT).get("id"), user.getId());
            Long teamId = teamIdOf(user);
            if (teamId == null) {
                return cb.and(cb.isNull(root.get(TEAM)), mine);
            }
            Predicate inTeam = cb.equal(root.get(TEAM).get("id"), teamId);
            return seesWholeTeam(user) ? inTeam : cb.and(inTeam, mine);
        };
    }

    /**
     * Records anyone in this person's team may see, whatever their data scope.
     *
     * <p>For listings: an agency's stock is what its agents sell, so an agent on their own clients
     * still needs every listing to put in front of them.
     */
    public <T> Specification<T> visibleToTeam(User user) {
        return (root, query, cb) -> {
            if (user == null) {
                return cb.disjunction();
            }
            if (isAdmin(user)) {
                return cb.conjunction();
            }
            Long teamId = teamIdOf(user);
            if (teamId == null) {
                return cb.and(cb.isNull(root.get(TEAM)), cb.equal(root.get(AGENT).get("id"), user.getId()));
            }
            return cb.equal(root.get(TEAM).get("id"), teamId);
        };
    }

    /** The single-record form of {@link #visibleTo}. */
    public boolean canSee(User user, Team recordTeam, User recordAgent) {
        if (user == null) {
            return false;
        }
        if (isAdmin(user)) {
            return true;
        }
        boolean mine = recordAgent != null && Objects.equals(recordAgent.getId(), user.getId());
        Long teamId = teamIdOf(user);
        if (teamId == null) {
            return recordTeam == null && mine;
        }
        if (recordTeam == null || !teamId.equals(recordTeam.getId())) {
            return false;
        }
        return seesWholeTeam(user) || mine;
    }

    /** The single-record form of {@link #visibleToTeam}. */
    public boolean canSeeInTeam(User user, Team recordTeam, User recordAgent) {
        if (user == null) {
            return false;
        }
        if (isAdmin(user)) {
            return true;
        }
        Long teamId = teamIdOf(user);
        if (teamId == null) {
            return recordTeam == null
                    && recordAgent != null && Objects.equals(recordAgent.getId(), user.getId());
        }
        return recordTeam != null && teamId.equals(recordTeam.getId());
    }

    /**
     * Refuses to link records from two different agencies — a deal on another team's client, a
     * meeting on another team's deal. Reported as not found, the same as reading one would be, so
     * the refusal does not confirm the other record exists.
     */
    public void requireSameTeam(Team expected, Team actual, String what) {
        if (!Objects.equals(idOf(expected), idOf(actual))) {
            throw new ResourceNotFoundException(what + " not found");
        }
    }

    private static Long idOf(Team team) {
        return team == null ? null : team.getId();
    }
}
