-- V49__audit_log.sql
--
-- Who changed what on a listing, a deal or a client, and when.
--
-- A record used to show only how it looks now. When a price went down, a deal
-- was moved back to negotiation or a client changed hands, nobody could say
-- who did it or what it was before. Every create, delete and edited field on
-- the three core records now leaves a row here.
--
-- record_changes            one row per field that moved, or one per creation
--                           or deletion. A single save that touches three
--                           fields writes three rows with the same changed_at.
--   team_id      the record's agency at the time, like every other business
--                record (V15). ON DELETE CASCADE: the trail goes with the
--                agency. NULL only for records that were in no agency.
--   entity_type  PROPERTY, DEAL or CLIENT.
--   entity_id    the record's id. Deliberately not a foreign key: the row that
--                says a record was deleted has to outlive the record.
--   entity_label the listing's title, the deal's title or the client's name as
--                it was then, so the team's feed can name a record that is
--                gone.
--   actor_id     ON DELETE SET NULL: the trail outlives whoever made the change.
--   actor_name   their name as it was then, kept when actor_id is cleared.
--   action       CREATED, DELETED, STATUS_CHANGED, PRICE_CHANGED,
--                AGENT_CHANGED or UPDATED (any other field).
--   field        which field moved; NULL for CREATED and DELETED.
--   old_value,   the values as plain text: enum names, plain decimals, ISO
--   new_value    dates, names for people and records. NULL when empty.
--
-- Properties keep their own property_price_changes (V26) for the price badge
-- and the price history; a price move is written to both.

CREATE TABLE record_changes (
    id            BIGSERIAL     PRIMARY KEY,
    team_id       BIGINT        REFERENCES teams(id) ON DELETE CASCADE,
    entity_type   VARCHAR(16)   NOT NULL,
    entity_id     BIGINT        NOT NULL,
    entity_label  VARCHAR(255),
    actor_id      BIGINT        REFERENCES users(id) ON DELETE SET NULL,
    actor_name    VARCHAR(255),
    action        VARCHAR(20)   NOT NULL,
    field         VARCHAR(40),
    old_value     TEXT,
    new_value     TEXT,
    changed_at    TIMESTAMP     NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_record_changes_entity_type
        CHECK (entity_type IN ('PROPERTY', 'DEAL', 'CLIENT')),
    CONSTRAINT chk_record_changes_action
        CHECK (action IN ('CREATED', 'DELETED', 'STATUS_CHANGED', 'PRICE_CHANGED',
                          'AGENT_CHANGED', 'UPDATED')),
    CONSTRAINT chk_record_changes_field
        CHECK ((field IS NULL) = (action IN ('CREATED', 'DELETED')))
);

-- One record's history, newest first.
CREATE INDEX idx_record_changes_entity
    ON record_changes (entity_type, entity_id, changed_at DESC, id DESC);

-- The agency's feed, newest first.
CREATE INDEX idx_record_changes_team
    ON record_changes (team_id, changed_at DESC, id DESC);
