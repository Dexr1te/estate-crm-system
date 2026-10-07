package com.crm.realestate.repository;

import com.crm.realestate.entity.DealDeposit;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

@Repository
public interface DealDepositRepository extends JpaRepository<DealDeposit, Long>,
        JpaSpecificationExecutor<DealDeposit> {

    @EntityGraph(attributePaths = {"deal", "deal.client", "deal.property", "deal.agent"})
    List<DealDeposit> findByDealIdOrderByIdDesc(Long dealId);

    /** The deal's active deposit, if it has one. */
    Optional<DealDeposit> findFirstByDealIdAndOutcomeIsNull(Long dealId);

    boolean existsByDealIdAndOutcomeIsNull(Long dealId);

    @Override
    @EntityGraph(attributePaths = {"deal", "deal.client", "deal.property", "deal.agent"})
    List<DealDeposit> findAll(Specification<DealDeposit> spec, Sort sort);

    /**
     * Rows of {@code [propertyId, holdUntil]}: the latest hold of an active deposit on a deal of
     * each of these listings, in one grouped query.
     */
    @Query("SELECT p.id, MAX(d.holdUntil) FROM DealDeposit d JOIN d.deal dl JOIN dl.property p "
            + "WHERE d.outcome IS NULL AND p.id IN :propertyIds GROUP BY p.id")
    List<Object[]> activeHolds(@Param("propertyIds") Collection<Long> propertyIds);
}
