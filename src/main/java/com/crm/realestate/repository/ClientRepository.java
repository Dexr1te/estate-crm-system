package com.crm.realestate.repository;

import com.crm.realestate.entity.Client;
import com.crm.realestate.enums.ClientType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ClientRepository extends JpaRepository<Client, Long> {

    List<Client> findByAgentId(Long agentId);

    List<Client> findByType(ClientType type);

    List<Client> findByAgentIdAndType(Long agentId, ClientType type);

    @Query("SELECT c FROM Client c WHERE " +
           "LOWER(c.fullName) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
           "LOWER(c.email)    LIKE LOWER(CONCAT('%', :query, '%')) OR " +
           "c.phone           LIKE CONCAT('%', :query, '%')")
    List<Client> searchClients(@Param("query") String query);

    boolean existsByEmail(String email);
}