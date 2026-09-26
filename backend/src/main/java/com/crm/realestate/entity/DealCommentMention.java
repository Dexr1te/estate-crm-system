package com.crm.realestate.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.io.Serializable;

/**
 * Somebody a deal comment @mentions.
 *
 * <p>Mapped as its own row rather than a many-to-many on the comment so that both ends can declare
 * their cascade: the link goes with the comment, and with the person. Both are also in V34.
 */
@Entity
@Table(name = "deal_comment_mentions",
        indexes = @Index(name = "idx_deal_comment_mentions_user", columnList = "user_id"))
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class DealCommentMention {

    @EmbeddedId
    private Key id;

    @MapsId("commentId")
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "comment_id", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    private DealComment comment;

    @MapsId("userId")
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    private User user;

    public static DealCommentMention of(DealComment comment, User user) {
        return new DealCommentMention(new Key(comment.getId(), user.getId()), comment, user);
    }

    @Embeddable
    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @EqualsAndHashCode
    public static class Key implements Serializable {
        @Column(name = "comment_id")
        private Long commentId;

        @Column(name = "user_id")
        private Long userId;
    }
}
