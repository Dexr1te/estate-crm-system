-- V45__client_dates.sql
--
-- Reasons to get back in touch that come round every year: a client's
-- birthday, and the day their deal was won. The app lists the ones coming up
-- with a greeting a tap away, and the agent is told on the day.
--
-- clients.birth_month, birth_day   the birthday. Both or neither. Nullable:
--             no client has one today, so no backfill is needed. 29 February
--             is kept as typed and marked on the 28th in a common year.
-- clients.birth_year               only when somebody knows it. Needs the
--             day and month, and is never before 1900. The API also refuses a
--             29 February in a year that had none, and a date in the future.
--
-- A purchase anniversary needs no column: it is the closed_at of a deal won
-- in an earlier year. Won deals are few next to clients, so they are read
-- by status and the day compared, with no index of their own.
--
-- client_date_notices  that the agent was told about one of them, once per
--             client, kind and year. The unique key, not a lookup beforehand,
--             is what makes it once: the reminder runs every hour of the day,
--             perhaps on more than one server.
--   kind             BIRTHDAY or PURCHASE_ANNIVERSARY.
--   occurrence_year  the year it fell in.
--   ON DELETE CASCADE with the client: nothing to remember once they are gone.

ALTER TABLE clients ADD COLUMN birth_month INTEGER;
ALTER TABLE clients ADD COLUMN birth_day   INTEGER;
ALTER TABLE clients ADD COLUMN birth_year  INTEGER;

ALTER TABLE clients
    ADD CONSTRAINT chk_clients_birthday
        CHECK ((birth_month IS NULL AND birth_day IS NULL AND birth_year IS NULL)
            OR (birth_month IS NOT NULL AND birth_day IS NOT NULL
                AND birth_month BETWEEN 1 AND 12
                AND birth_day BETWEEN 1 AND
                    CASE WHEN birth_month = 2 THEN 29
                         WHEN birth_month IN (4, 6, 9, 11) THEN 30
                         ELSE 31 END
                AND (birth_year IS NULL OR birth_year >= 1900)));

-- "Whose birthday falls in the next two weeks", asked hourly across agencies
-- and by every dashboard within one.
CREATE INDEX idx_clients_birthday ON clients(birth_month, birth_day);

CREATE TABLE client_date_notices (
    id               BIGSERIAL    PRIMARY KEY,
    client_id        BIGINT       NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    kind             VARCHAR(30)  NOT NULL,
    occurrence_year  INTEGER      NOT NULL,
    created_at       TIMESTAMP    NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_client_date_notices UNIQUE (client_id, kind, occurrence_year),
    CONSTRAINT chk_client_date_notices_kind
        CHECK (kind IN ('BIRTHDAY', 'PURCHASE_ANNIVERSARY'))
);
