package com.crm.realestate.repository;

import com.crm.realestate.entity.DealCommentMention;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Collection;
import java.util.List;

@Repository
public interface DealCommentMentionRepository
        extends JpaRepository<DealCommentMention, DealCommentMention.Key> {

    /** The people behind a page of comments, in one query, with each name on board. */
    @Query("SELECT m FROM DealCommentMention m JOIN FETCH m.user u "
            + "WHERE m.comment.id IN :commentIds ORDER BY u.id")
    List<DealCommentMention> findForComments(@Param("commentIds") Collection<Long> commentIds);

    @Modifying(flushAutomatically = true, clearAutomatically = true)
    @Query("DELETE FROM DealCommentMention m WHERE m.comment.id = :commentId")
    int deleteByComment(@Param("commentId") Long commentId);
}
