-- V54__time_off.sql
--
-- An agent's time off: a holiday, sick leave, a day off, and the colleague who
-- covers for them while they are away. Nothing changes hands: what the absent
-- person holds stays theirs (handing it over is V48's handover). What changes
-- is who hears about it: while somebody is away, every notification meant for
-- them goes to their cover as well, marked as covering for them.
--
-- time_off                one row per absence.
--   team_id      the agency it is taken from, the absent person's when it was
--                written down. Every read keeps to it.
--   user_id      who is away. ON DELETE CASCADE: an absence means nothing
--                once the account is gone.
--   cover_id     the colleague covering, or nobody. SET NULL with the
--                account; the service hands the cover to the leaver's
--                successor first when there is one. Never the absent person.
--   kind         VACATION, SICK_LEAVE, DAY_OFF or OTHER.
--   start_date / end_date  the first and the last day away, both inclusive,
--                as calendar dates in the agency's zone. The service keeps
--                one person's absences from overlapping and each within a
--                year.
--   created_by   who wrote it down, the person or a manager. SET NULL.
--
-- notifications.covering  true on the copy a cover gets of somebody else's
--                notification. The payload names whom they are covering for.
--                "Already told" checks look past these copies, so a cover
--                still hears about their own buyers.

CREATE TABLE time_off (
    id           BIGSERIAL     PRIMARY KEY,
    team_id      BIGINT        NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    user_id      BIGINT        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    cover_id     BIGINT        REFERENCES users(id) ON DELETE SET NULL,
    kind         VARCHAR(20)   NOT NULL,
    start_date   DATE          NOT NULL,
    end_date     DATE          NOT NULL,
    note         VARCHAR(1000),
    created_by   BIGINT        REFERENCES users(id) ON DELETE SET NULL,
    created_at   TIMESTAMP     NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMP     NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_time_off_kind
        CHECK (kind IN ('VACATION', 'SICK_LEAVE', 'DAY_OFF', 'OTHER')),
    CONSTRAINT chk_time_off_dates CHECK (end_date >= start_date),
    CONSTRAINT chk_time_off_cover CHECK (cover_id IS NULL OR cover_id <> user_id)
);

-- Who is out in an agency over a window, and whether one person is away today.
CREATE INDEX idx_time_off_team_dates ON time_off(team_id, start_date, end_date);
CREATE INDEX idx_time_off_user_dates ON time_off(user_id, start_date, end_date);
CREATE INDEX idx_time_off_cover ON time_off(cover_id);
CREATE INDEX idx_time_off_created_by ON time_off(created_by);

ALTER TABLE notifications
    ADD COLUMN covering BOOLEAN NOT NULL DEFAULT FALSE;
