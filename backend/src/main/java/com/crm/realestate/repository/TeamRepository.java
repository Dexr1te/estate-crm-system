package com.crm.realestate.repository;

import com.crm.realestate.entity.Team;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TeamRepository extends JpaRepository<Team, Long> {

    /** Names are not unique, so this is only for the demo seeder's own, clearly marked team. */
    java.util.Optional<Team> findFirstByNameOrderByIdAsc(String name);
}
