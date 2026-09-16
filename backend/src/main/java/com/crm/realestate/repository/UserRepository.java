package com.crm.realestate.repository;

import com.crm.realestate.entity.User;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    // The team comes along: the auth response names it, and the scope checks read it on every request.
    @org.springframework.data.jpa.repository.EntityGraph(attributePaths = {"team"})
    Optional<User> findByEmail(String email);

    /** Sign-up and "add by email" must not treat Ivan@mail.kz and ivan@mail.kz as two people. */
    @org.springframework.data.jpa.repository.EntityGraph(attributePaths = {"team"})
    Optional<User> findFirstByEmailIgnoreCase(String email);
    Optional<User> findByInviteToken(String inviteToken);
    Optional<User> findByPasswordResetToken(String resetToken);

    boolean existsByEmail(String email);

    long countByRoleAndStatusAndIsActiveTrue(Role role, UserStatus status);

    // active agents for frontend select (only active!)
    List<User> findByRoleAndIsActiveTrueOrderByFullNameAsc(Role role);

    /** Everyone who can be assigned work — see UserService.getAgentOptions. */
    List<User> findByIsActiveTrueOrderByFullNameAsc();

    // all users by role (for admin - including inactive)
    List<User> findByRoleOrderByFullNameAsc(Role role);

    // all users sorted by createdAt desc (for admin dashboard)
    List<User> findAllByOrderByCreatedAtDesc();
    List<User> findByTeamId(Long teamId);

    /** A team's assignable people — see UserService.getAgentOptions. */
    List<User> findByTeamIdAndIsActiveTrueOrderByFullNameAsc(Long teamId);
}