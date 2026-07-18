package com.crm.realestate.repository;

import com.crm.realestate.entity.Deal;
import com.crm.realestate.enums.DealStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository

public interface DealRepository extends JpaRepository<Deal, Long>, JpaSpecificationExecutor<Deal> {

    List<Deal> findByAgentId(Long agentId);
    long countByAgentIdIn(List<Long> agentIds);
    List<Deal> findByAgentIdIn(List<Long> agentIds);

    List<Deal> findByClientId(Long clientId);

    List<Deal> findByStatus(DealStatus status);

    List<Deal> findByAgentIdAndStatus(Long agentId, DealStatus status);

    // для аналитики количество сделок по статусам у агента
    @Query("SELECT d.status, COUNT(d) FROM Deal d " +
           "WHERE d.agent.id = :agentId GROUP BY d.status")
    List<Object[]> countByStatusForAgent(@Param("agentId") Long agentId);

    // общая сводка по всем сделкам
    @Query("SELECT d.status, COUNT(d) FROM Deal d GROUP BY d.status")
    List<Object[]> countByStatus();
}