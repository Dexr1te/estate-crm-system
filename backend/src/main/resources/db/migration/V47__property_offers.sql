-- V47__property_offers.sql
--
-- A buyer names a price for a flat, the seller comes back with another, and
-- after a round or two one of them says yes. That went on in phone calls and
-- messengers, and the CRM knew nothing of it: not who had offered what, not
-- which figure was on the table, not that the seller had already said yes to
-- somebody.
--
-- property_offers            one row per buyer's offer on one listing.
--   property_id  ON DELETE CASCADE: an offer is on the flat, and means nothing
--                once the listing is gone.
--   client_id    the buyer. ON DELETE CASCADE: an offer from nobody is not an
--                offer. Merging two cards moves the offers to the one that stays.
--   team_id      always the listing's agency, like every business record (V15).
--   agent_id     who recorded it and follows it up. Handed to a successor with
--                the agent's other records when they leave; SET NULL only as
--                the last resort, so deleting an account never fails on it.
--   amount       the figure on the table now, in the agency's currency (V36):
--                the buyer's first offer, then each counter in turn.
--   last_party   whose figure that is: BUYER or SELLER.
--   note         optional, at most 1000 characters.
--   expires_on   optional; the last day the offer stands. An open offer past
--                it reads as EXPIRED. That is worked out when it is read, not
--                written: nothing in the backend runs on a schedule.
--   status       NEW, COUNTERED, ACCEPTED, REJECTED or WITHDRAWN as stored.
--                EXPIRED is never stored (see expires_on).
--   decided_at   when it was accepted, rejected or withdrawn. Set exactly when
--                the offer is no longer open.
--
-- A listing has at most one accepted offer at a time (the partial unique index
-- below, and the service says 409 OFFER_ALREADY_ACCEPTED first). The others
-- stay open as backups, flagged in the app, until somebody decides on them.
--
-- property_offer_events      the negotiation, oldest first: the offer, every
--                            counter, and how it ended.
--   action       OFFERED, COUNTERED, ACCEPTED, REJECTED or WITHDRAWN.
--   amount       the figure on the table after that step.
--   party        whose figure it was, for OFFERED and COUNTERED; empty for a
--                decision.
--   actor_id     who recorded the step. SET NULL with the account; actor_name
--                keeps the name, so the history still says who.

CREATE TABLE property_offers (
    id           BIGSERIAL      PRIMARY KEY,
    property_id  BIGINT         NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
    client_id    BIGINT         NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    team_id      BIGINT         REFERENCES teams(id),
    agent_id     BIGINT         REFERENCES users(id) ON DELETE SET NULL,
    amount       NUMERIC(15, 2) NOT NULL,
    last_party   VARCHAR(8)     NOT NULL DEFAULT 'BUYER',
    note         VARCHAR(1000),
    expires_on   DATE,
    status       VARCHAR(16)    NOT NULL DEFAULT 'NEW',
    decided_at   TIMESTAMP,
    created_at   TIMESTAMP      NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMP      NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_property_offers_amount CHECK (amount > 0),
    CONSTRAINT chk_property_offers_party CHECK (last_party IN ('BUYER', 'SELLER')),
    CONSTRAINT chk_property_offers_status
        CHECK (status IN ('NEW', 'COUNTERED', 'ACCEPTED', 'REJECTED', 'WITHDRAWN')),
    CONSTRAINT chk_property_offers_decided
        CHECK ((status IN ('NEW', 'COUNTERED')) = (decided_at IS NULL))
);

-- A listing's offers, highest first; a buyer's offers on their card.
CREATE INDEX idx_property_offers_property ON property_offers(property_id, amount DESC);
CREATE INDEX idx_property_offers_client ON property_offers(client_id);
CREATE INDEX idx_property_offers_team ON property_offers(team_id);
CREATE INDEX idx_property_offers_agent ON property_offers(agent_id);

-- One accepted offer per listing, whatever two phones send at once.
CREATE UNIQUE INDEX uq_property_offers_accepted ON property_offers(property_id) WHERE status = 'ACCEPTED';

CREATE TABLE property_offer_events (
    id           BIGSERIAL      PRIMARY KEY,
    offer_id     BIGINT         NOT NULL REFERENCES property_offers(id) ON DELETE CASCADE,
    action       VARCHAR(16)    NOT NULL,
    amount       NUMERIC(15, 2) NOT NULL,
    party        VARCHAR(8),
    note         VARCHAR(1000),
    actor_id     BIGINT         REFERENCES users(id) ON DELETE SET NULL,
    actor_name   VARCHAR(255),
    created_at   TIMESTAMP      NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_property_offer_events_amount CHECK (amount > 0),
    CONSTRAINT chk_property_offer_events_action
        CHECK (action IN ('OFFERED', 'COUNTERED', 'ACCEPTED', 'REJECTED', 'WITHDRAWN')),
    CONSTRAINT chk_property_offer_events_party CHECK (party IS NULL OR party IN ('BUYER', 'SELLER'))
);

CREATE INDEX idx_property_offer_events_offer ON property_offer_events(offer_id, created_at);
CREATE INDEX idx_property_offer_events_actor ON property_offer_events(actor_id);
