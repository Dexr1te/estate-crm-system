package com.crm.realestate.repository;

import com.crm.realestate.entity.PropertyShareLink;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.Optional;

public interface PropertyShareLinkRepository extends JpaRepository<PropertyShareLink, Long> {

    /** The link that works for this listing, if there is one. */
    Optional<PropertyShareLink> findFirstByPropertyIdAndRevokedAtIsNull(Long propertyId);

    /** A working link by its token. A revoked one reads exactly like one that never existed. */
    Optional<PropertyShareLink> findByTokenAndRevokedAtIsNull(String token);

    /** Counted in the database, so two people opening the page at once are both counted. */
    @Modifying(clearAutomatically = true, flushAutomatically = true)
    @Query("update PropertyShareLink l set l.viewCount = l.viewCount + 1, l.lastViewedAt = :at "
            + "where l.id = :id")
    int recordView(@Param("id") Long id, @Param("at") LocalDateTime at);
}
