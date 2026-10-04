-- V52__recurring_tasks.sql
--
-- A task that comes back: "call the landlord every month", "check the
-- listing's photos every Monday and Thursday". A repeating task is a series of
-- ordinary tasks, one open at a time: completing one writes the next, with
-- the next due time the rule gives. Nothing about a single task changes, so
-- everything that reads tasks (the lists, the calendar, the dashboard, the
-- reminders on the phone, the handovers) reads an occurrence like any other.
--
-- task_series     the rule, and nothing else. It has no team and no assignee
--                 of its own: it is only ever reached through one of its
--                 tasks, which carry both, so it sits behind the same walls,
--                 and the next occurrence goes to whoever held the one that
--                 was completed, wherever a handover put it.
--   frequency     DAILY, WEEKLY, MONTHLY, QUARTERLY or YEARLY. "No repeat"
--                 is no series at all.
--   weekdays      WEEKLY only, never empty there: a bit per day, Monday = 1,
--                 Tuesday = 2 ... Sunday = 64.
--   anchor_at     the due time the pattern is counted from: the first
--                 occurrence's, or the one whose due time or pattern was
--                 last changed. Months are added to the anchor, never to the
--                 previous occurrence, so the 31st clamps to the 30th or the
--                 28th in a shorter month and comes back to the 31st after
--                 it, and the 29th of February to the 28th until a leap year.
--   count_from    the occurrence the end "after N times" counts from: where
--                 the end or the pattern was last set.
--   until_date,   the end, at most one of the two: no occurrence falls after
--   max_occurrences  until_date, or after the N-th counted from count_from.
--   stopped_at    "stop repeating": the tasks stay, nothing more is written.
--
-- tasks.series_id   the series the task belongs to. A series lost with its
--                   last task leaves the rows it wrote alone: SET NULL.
-- tasks.occurrence  1, 2, 3 ... within the series; unique in it, so the same
--                   occurrence can never be written twice.
-- tasks.next_created  this occurrence already wrote the one after it.
--                   Reopening and completing it again writes nothing more.
--
-- Existing tasks get no series and repeat nothing.

CREATE TABLE task_series (
    id               BIGSERIAL    PRIMARY KEY,
    frequency        VARCHAR(16)  NOT NULL,
    weekdays         SMALLINT,
    anchor_at        TIMESTAMP    NOT NULL,
    count_from       INTEGER      NOT NULL DEFAULT 1,
    until_date       DATE,
    max_occurrences  INTEGER,
    stopped_at       TIMESTAMP,
    created_at       TIMESTAMP    NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMP    NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_task_series_frequency
        CHECK (frequency IN ('DAILY', 'WEEKLY', 'MONTHLY', 'QUARTERLY', 'YEARLY')),
    CONSTRAINT chk_task_series_weekdays
        CHECK ((frequency = 'WEEKLY' AND weekdays IS NOT NULL AND weekdays BETWEEN 1 AND 127)
            OR (frequency <> 'WEEKLY' AND weekdays IS NULL)),
    CONSTRAINT chk_task_series_one_end
        CHECK (until_date IS NULL OR max_occurrences IS NULL),
    CONSTRAINT chk_task_series_max
        CHECK (max_occurrences IS NULL OR max_occurrences BETWEEN 1 AND 999),
    CONSTRAINT chk_task_series_count_from CHECK (count_from >= 1)
);

ALTER TABLE tasks ADD COLUMN series_id BIGINT REFERENCES task_series(id) ON DELETE SET NULL;
ALTER TABLE tasks ADD COLUMN occurrence INTEGER;
ALTER TABLE tasks ADD COLUMN next_created BOOLEAN NOT NULL DEFAULT FALSE;

ALTER TABLE tasks ADD CONSTRAINT chk_tasks_occurrence CHECK (occurrence IS NULL OR occurrence >= 1);

CREATE UNIQUE INDEX uq_tasks_series_occurrence ON tasks(series_id, occurrence);
