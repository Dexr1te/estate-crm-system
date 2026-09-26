-- V34__deal_comments.sql
--
-- A deal involves the agent, a manager, sometimes a colleague who covers a
-- viewing. Until now they talked about it in a messenger and the context was
-- lost the moment somebody new picked the deal up. The conversation now lives
-- on the deal: one row per comment, and who in it was @mentioned.
--
-- deal_id     ON DELETE CASCADE: a discussion about a deal means nothing once
--             the deal is gone, so deleting a deal still works in one step.
-- team_id     always the deal's team, like every other business record (V15).
-- author_id   ON DELETE SET NULL: the comment outlives whoever wrote it and is
--             not handed to a successor — that would put the leaver's words in
--             someone else's mouth — so it keeps author_name, the name it was
--             written under (the same rule as client_activities, V25).
-- edited_at   null until the author corrects the text.
--
-- A comment that is taken back is deleted outright rather than flagged. A
-- tombstone would have to be filtered out of every read and count, and the
-- person who removed it asked for the words to be gone, not hidden.

CREATE TABLE deal_comments (
    id           BIGSERIAL     PRIMARY KEY,
    deal_id      BIGINT        NOT NULL REFERENCES deals(id) ON DELETE CASCADE,
    team_id      BIGINT        REFERENCES teams(id),
    author_id    BIGINT        REFERENCES users(id) ON DELETE SET NULL,
    author_name  VARCHAR(255),
    body         TEXT          NOT NULL,
    created_at   TIMESTAMP     NOT NULL DEFAULT NOW(),
    edited_at    TIMESTAMP,
    CONSTRAINT chk_deal_comments_body_length
        CHECK (char_length(body) BETWEEN 1 AND 4000)
);

-- Every read is "this deal's discussion, in order", and the deal list counts
-- comments per deal.
CREATE INDEX idx_deal_comments_deal ON deal_comments(deal_id, id);

-- A closed account's rows are found and cleared by the SET NULL above.
CREATE INDEX idx_deal_comments_author ON deal_comments(author_id);

-- Who a comment @mentions. The link goes with the comment, and with the person:
-- once their account is closed there is nobody left to point at, and the
-- readable "@Name" stays in the body.
CREATE TABLE deal_comment_mentions (
    comment_id  BIGINT  NOT NULL REFERENCES deal_comments(id) ON DELETE CASCADE,
    user_id     BIGINT  NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    PRIMARY KEY (comment_id, user_id)
);

CREATE INDEX idx_deal_comment_mentions_user ON deal_comment_mentions(user_id);
