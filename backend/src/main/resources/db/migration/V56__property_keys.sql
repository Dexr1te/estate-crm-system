-- V56__property_keys.sql
--
-- An agency holds the keys of its listings and hands them out all day: to an
-- agent showing the flat, to the owner, to a cleaner, to a buyer measuring up
-- for furniture. Which keys are out, with whom, and since when lived in a
-- notebook by the door, or nowhere.
--
-- property_key_handovers    one row per time a listing's keys left the office.
--   team_id         the listing's agency when the keys went out (V15's rule
--                   for every business record). Every read keeps to it.
--   property_id     ON DELETE CASCADE: the keys' story means nothing once the
--                   listing is gone.
--   holder_user_id  a colleague from the same agency who took them, or NULL
--   holder_name     for somebody outside it, by name: the owner, a cleaner.
--                   Exactly one of the two is set. Closing a holder's account
--                   writes their name into holder_name first, so the record
--                   still says who has the keys.
--   note            optional, at most 500 characters.
--   handed_out_at   when the keys went out.
--   due_back_at     optional: the last day they are to be back. Past it and
--                   not returned, they are overdue. A calendar date in the
--                   agency's zone, like the other days the agency keeps.
--   returned_at     when they came back; NULL while they are out.
--   handed_out_by   who recorded the handover. Always set when written;
--   returned_by     who recorded the return. Both SET NULL with the account.
--
-- A listing's keys are out at most once at a time: the partial unique index
-- below, and the service says 409 KEY_ALREADY_OUT first.

CREATE TABLE property_key_handovers (
    id              BIGSERIAL     PRIMARY KEY,
    team_id         BIGINT        REFERENCES teams(id) ON DELETE CASCADE,
    property_id     BIGINT        NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
    holder_user_id  BIGINT        REFERENCES users(id),
    holder_name     VARCHAR(255),
    note            VARCHAR(500),
    handed_out_at   TIMESTAMP     NOT NULL DEFAULT NOW(),
    due_back_at     DATE,
    returned_at     TIMESTAMP,
    handed_out_by   BIGINT        REFERENCES users(id) ON DELETE SET NULL,
    returned_by     BIGINT        REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT chk_property_key_handovers_holder CHECK (
        (holder_user_id IS NOT NULL AND holder_name IS NULL)
        OR (holder_user_id IS NULL AND holder_name IS NOT NULL)),
    CONSTRAINT chk_property_key_handovers_returned
        CHECK (returned_at IS NULL OR returned_at >= handed_out_at)
);

-- A listing's handovers, the newest first.
CREATE INDEX idx_property_key_handovers_property ON property_key_handovers(property_id, handed_out_at DESC);

-- The agency's keys that are out.
CREATE INDEX idx_property_key_handovers_team_open ON property_key_handovers(team_id, returned_at);

-- What a closed account still holds, and the people the SET NULLs clear.
CREATE INDEX idx_property_key_handovers_holder ON property_key_handovers(holder_user_id);
CREATE INDEX idx_property_key_handovers_handed_out_by ON property_key_handovers(handed_out_by);
CREATE INDEX idx_property_key_handovers_returned_by ON property_key_handovers(returned_by);

-- One open handover per listing, whatever two phones send at once.
CREATE UNIQUE INDEX uq_property_key_handovers_open ON property_key_handovers(property_id) WHERE returned_at IS NULL;
