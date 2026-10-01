-- V44__open_houses.sql
--
-- An open house: an agent holds a listing open for an afternoon, and whoever
-- walks in signs in on the agent's phone. Each visitor is matched against the
-- agency's clients by phone; a number nobody knows becomes a new buyer, one
-- the agency knows gets a line in that client's history.
--
-- open_houses               one per event, on one listing.
--   property_id  ON DELETE CASCADE: an open house is about the flat, and
--                means nothing once the listing is gone.
--   team_id      always the listing's agency, like every business record (V15).
--   agent_id     who holds it. Handed to a successor with the agent's other
--                records when they leave; SET NULL only as the last resort, so
--                deleting an account can never fail on it.
--   starts_at / ends_at  local wall-clock time, as meetings are. The end is
--                after the start; the service also keeps it within a day.
--
-- open_house_visitors       the sign-in sheet.
--   full_name / phone   as typed at the door; phone_normalized is the
--                comparable form (ContactNormalizer, V29), one per open house.
--   interest     INTERESTED, JUST_LOOKING, or nothing when nobody asked.
--   client_id    the agency's client this visitor is. SET NULL if the card
--                is deleted later: the sheet still says who came.
--   new_client   whether the sign-in made that client, for the summary.
--   activity_id  the line it put in the client's history, so taking a
--                visitor back off the sheet takes the line with it.
--   signed_in_by who signed them in; SET NULL with the account.
--
-- client_activities.open_house_id  the open house a history line came from,
--                so the app can call it a visit rather than a note. SET NULL:
--                the visit happened, whatever becomes of the event.
--
-- clients.source gains OPEN_HOUSE, for buyers who first came through the door.

CREATE TABLE open_houses (
    id           BIGSERIAL     PRIMARY KEY,
    property_id  BIGINT        NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
    team_id      BIGINT        REFERENCES teams(id),
    agent_id     BIGINT        REFERENCES users(id) ON DELETE SET NULL,
    starts_at    TIMESTAMP     NOT NULL,
    ends_at      TIMESTAMP     NOT NULL,
    note         VARCHAR(1000),
    created_at   TIMESTAMP     NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMP     NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_open_houses_ends_after_start CHECK (ends_at > starts_at)
);

-- The listing's open houses, and the calendar's window over an agency.
CREATE INDEX idx_open_houses_property ON open_houses(property_id, starts_at DESC);
CREATE INDEX idx_open_houses_team_start ON open_houses(team_id, starts_at);
CREATE INDEX idx_open_houses_agent ON open_houses(agent_id);

CREATE TABLE open_house_visitors (
    id                BIGSERIAL     PRIMARY KEY,
    open_house_id     BIGINT        NOT NULL REFERENCES open_houses(id) ON DELETE CASCADE,
    team_id           BIGINT        REFERENCES teams(id),
    full_name         VARCHAR(120)  NOT NULL,
    phone             VARCHAR(40)   NOT NULL,
    phone_normalized  VARCHAR(40)   NOT NULL,
    interest          VARCHAR(20),
    note              VARCHAR(1000),
    client_id         BIGINT        REFERENCES clients(id) ON DELETE SET NULL,
    new_client        BOOLEAN       NOT NULL DEFAULT FALSE,
    activity_id       BIGINT        REFERENCES client_activities(id) ON DELETE SET NULL,
    signed_in_by      BIGINT        REFERENCES users(id) ON DELETE SET NULL,
    signed_in_at      TIMESTAMP     NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_open_house_visitors_interest
        CHECK (interest IS NULL OR interest IN ('INTERESTED', 'JUST_LOOKING')),
    CONSTRAINT uq_open_house_visitors_phone UNIQUE (open_house_id, phone_normalized)
);

CREATE INDEX idx_open_house_visitors_client ON open_house_visitors(client_id);
CREATE INDEX idx_open_house_visitors_activity ON open_house_visitors(activity_id);
CREATE INDEX idx_open_house_visitors_signed_in_by ON open_house_visitors(signed_in_by);

ALTER TABLE client_activities
    ADD COLUMN open_house_id BIGINT REFERENCES open_houses(id) ON DELETE SET NULL;

CREATE INDEX idx_client_activities_open_house ON client_activities(open_house_id);

ALTER TABLE clients DROP CONSTRAINT chk_clients_source;

ALTER TABLE clients
    ADD CONSTRAINT chk_clients_source
        CHECK (source IN ('MANUAL', 'IMPORT', 'PUBLIC_LINK', 'OPEN_HOUSE'));
