-- V27__tasks.sql
--
-- Something to do, and when it is due: "call Irina back on Friday", "send the
-- contract to the seller tomorrow". Until now a follow-up lived in the agent's
-- head, or as a meeting nobody was going to attend.
--
-- team_id         the agency, like every other business record (V15): the
--                 linked client's or deal's, else the assignee's.
-- assignee_id     whoever has to do it. When an account is closed with a
--                 successor named, the service hands every task to them, like
--                 deals and meetings; open tasks with nobody to take them
--                 refuse the closure. What is left by then is finished work,
--                 which goes with the account (ON DELETE CASCADE).
-- created_by_id   who wrote it down. History, not a dependency: ON DELETE
--                 SET NULL, the way users.created_by is (V14).
-- client_id,      optional links. A task about a client or a deal means
-- deal_id         nothing once that record is gone: ON DELETE CASCADE.
-- completed_at    null while the task is open.

CREATE TABLE tasks (
    id             BIGSERIAL     PRIMARY KEY,
    team_id        BIGINT        REFERENCES teams(id),
    assignee_id    BIGINT        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_by_id  BIGINT        REFERENCES users(id) ON DELETE SET NULL,
    title          VARCHAR(200)  NOT NULL,
    note           TEXT,
    due_at         TIMESTAMP     NOT NULL,
    client_id      BIGINT        REFERENCES clients(id) ON DELETE CASCADE,
    deal_id        BIGINT        REFERENCES deals(id) ON DELETE CASCADE,
    completed_at   TIMESTAMP,
    created_at     TIMESTAMP     NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMP     NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_tasks_title_not_blank CHECK (char_length(trim(title)) > 0),
    CONSTRAINT chk_tasks_note_length
        CHECK (note IS NULL OR char_length(note) <= 2000)
);

-- The everyday read is "my open tasks, soonest first"; the manager's is the
-- agency's. Finished tasks are read far less and need no index of their own.
CREATE INDEX idx_tasks_assignee_open ON tasks(assignee_id, due_at) WHERE completed_at IS NULL;
CREATE INDEX idx_tasks_team_due      ON tasks(team_id, due_at);
CREATE INDEX idx_tasks_client        ON tasks(client_id);
CREATE INDEX idx_tasks_deal          ON tasks(deal_id);
CREATE INDEX idx_tasks_created_by    ON tasks(created_by_id);
