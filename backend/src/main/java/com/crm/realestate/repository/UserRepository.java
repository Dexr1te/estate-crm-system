package com.crm.realestate.repository;

import com.crm.realestate.entity.User;
import com.crm.realestate.enums.Role;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByEmail(String email);

    boolean existsByEmail(String email);

    // active agents for frontend select (only active!)
    List<User> findByRoleAndIsActiveTrueOrderByFullNameAsc(Role role);

    // all users by role (for admin - including inactive)
    List<User> findByRoleOrderByFullNameAsc(Role role);

    // all users sorted by createdAt desc (for admin dashboard)
    List<User> findAllByOrderByCreatedAtDesc();
}