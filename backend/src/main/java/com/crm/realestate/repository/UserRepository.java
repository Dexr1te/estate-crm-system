package com.crm.realestate.repository;

import com.crm.realestate.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

import com.crm.realestate.enums.Role;
import java.util.List;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);

    // Список агентов для селекта на фронтенде (сортировка по имени)
    List<User> findByRoleOrderByFullNameAsc(Role role);
}