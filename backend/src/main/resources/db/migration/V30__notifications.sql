-- V30__notifications.sql
--
-- What happened while you were out: a task somebody gave you, a colleague's
-- clients handed to you, a new listing that fits one of your buyers.
--
-- No text is stored. The app speaks three languages, so a row keeps what
-- happened (type), what it points at (target_id) and the few values the
-- sentence needs (payload, a small JSON object of names, counts and prices).
--
-- team_id      the agency it happened in; null for a request to join one,
--              which reaches someone who is not in a team yet. ON DELETE SET
--              NULL: the recipient still owns the row.
-- recipient_id whose feed it is in. It means nothing once they are gone:
--              ON DELETE CASCADE.
-- target_id    the task, deal, listing or join request it is about, read
--              according to type. Deliberately not a foreign key: the record
--              may be deleted later and the notification should stay behind
--              as history, the app answers "not found" when opened.
-- read_at      null while unread.

CREATE TABLE notifications (
    id            BIGSERIAL    PRIMARY KEY,
    team_id       BIGINT       REFERENCES teams(id) ON DELETE SET NULL,
    recipient_id  BIGINT       NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type          VARCHAR(40)  NOT NULL,
    target_id     BIGINT,
    payload       TEXT,
    read_at       TIMESTAMP,
    created_at    TIMESTAMP    NOT NULL DEFAULT NOW()
);

-- The feed, the unread count and "mark all read" all read one person's rows,
-- unread first, newest first.
CREATE INDEX idx_notifications_recipient
    ON notifications(recipient_id, read_at, created_at DESC);
