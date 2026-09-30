package com.crm.realestate.repository;

import com.crm.realestate.entity.MessageTemplate;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface MessageTemplateRepository extends JpaRepository<MessageTemplate, Long> {

    List<MessageTemplate> findByTeamIdOrderByIdAsc(Long teamId);

    /** A template only if it is this agency's: the tenant wall for every write. */
    Optional<MessageTemplate> findByIdAndTeamId(Long id, Long teamId);

    long countByTeamId(Long teamId);

    /**
     * Claims the right to write the default templates: 1 for the one caller that flips the flag,
     * 0 for everyone after, so two first reads at once cannot both seed them.
     */
    @Modifying(flushAutomatically = true)
    @Query("UPDATE Team t SET t.messageTemplatesSeeded = true "
            + "WHERE t.id = :teamId AND t.messageTemplatesSeeded = false")
    int markSeeded(@Param("teamId") Long teamId);
}
