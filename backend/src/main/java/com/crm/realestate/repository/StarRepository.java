package com.crm.realestate.repository;

import com.crm.realestate.entity.Star;
import com.crm.realestate.enums.StarType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

@Repository
public interface StarRepository extends JpaRepository<Star, Long> {

    /** One person's stars, newest first. */
    List<Star> findByUserIdOrderByCreatedAtDescIdDesc(Long userId);

    Optional<Star> findByUserIdAndEntityTypeAndEntityId(Long userId, StarType entityType, Long entityId);

    /** Takes one person's star off one record; no star to take is not an error. */
    @Modifying(flushAutomatically = true)
    @Query("DELETE FROM Star s WHERE s.user.id = :userId AND s.entityType = :type AND s.entityId = :entityId")
    int deleteOne(@Param("userId") Long userId, @Param("type") StarType type, @Param("entityId") Long entityId);

    /** These records are gone: everybody's stars on them go too. */
    @Modifying(flushAutomatically = true)
    @Query("DELETE FROM Star s WHERE s.entityType = :type AND s.entityId IN :entityIds")
    int deleteForRecords(@Param("type") StarType type, @Param("entityIds") Collection<Long> entityIds);

    /**
     * Moves the stars on one record to another of the same type — a merged client's to the card
     * that stays — for everybody who has not starred that one already. What is left on the source
     * is for {@link #deleteForRecords}.
     */
    @Modifying(flushAutomatically = true)
    @Query("UPDATE Star s SET s.entityId = :targetId WHERE s.entityType = :type AND s.entityId = :sourceId "
            + "AND s.user.id NOT IN (SELECT o.user.id FROM Star o WHERE o.entityType = :type "
            + "AND o.entityId = :targetId)")
    int moveToRecord(@Param("type") StarType type, @Param("sourceId") Long sourceId,
                     @Param("targetId") Long targetId);
}
