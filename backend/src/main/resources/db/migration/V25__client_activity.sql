-- V25__client_activity.sql
--
-- A client's history of contact. Until now a client carried one free-text
-- `notes` field, so "who called her last, and what did she say" lived in the
-- agent's head or got written over. Every call, message, email and note is now
-- its own row: what kind, when it happened, who logged it, what was said.
--
-- client_id  ON DELETE CASCADE: the history is about the client and means
--            nothing once the client is gone, so deleting a client still works
--            with no extra step.
-- author_id  ON DELETE SET NULL: the history outlives whoever wrote it. It is
--            not handed to a successor the way deals and meetings are — that
--            would put the leaver's words in someone else's mouth — so the row
--            forgets the account and keeps author_name, the name it was
--            written under.
-- team_id    always the client's team, like every other business record (V15).

CREATE TABLE client_activities (
    id           BIGSERIAL    PRIMARY KEY,
    client_id    BIGINT       NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    team_id      BIGINT       REFERENCES teams(id),
    author_id    BIGINT       REFERENCES users(id) ON DELETE SET NULL,
    author_name  VARCHAR(255),
    type         VARCHAR(20)  NOT NULL,
    note         TEXT,
    occurred_at  TIMESTAMP    NOT NULL DEFAULT NOW(),
    created_at   TIMESTAMP    NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_client_activities_type
        CHECK (type IN ('CALL', 'MESSAGE', 'EMAIL', 'NOTE')),
    CONSTRAINT chk_client_activities_note_length
        CHECK (note IS NULL OR char_length(note) <= 2000)
);

-- Every read is "this client's history, newest first", and the client list asks
-- for the latest one per client.
CREATE INDEX idx_client_activities_client ON client_activities(client_id, occurred_at DESC);

-- A closed account's rows are found and cleared by the SET NULL above.
CREATE INDEX idx_client_activities_author ON client_activities(author_id);
