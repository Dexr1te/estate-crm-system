-- V46__deal_deposits.sql
--
-- When a buyer puts money down on a flat, the flat is theirs to buy until an
-- agreed day, and the money sits with somebody until the sale goes through or
-- falls apart. None of that was written anywhere the CRM could see: a listing
-- under deposit was still offered to other buyers, and nobody was reminded
-- when the hold ran out.
--
-- deal_deposits               one row per deposit on a deal. A deal has at most
--                             one active deposit at a time (the service refuses
--                             a second); an older one stays as history once it
--                             is closed.
--   deal_id     ON DELETE CASCADE: a deposit means nothing without its deal.
--   team_id     always the deal's team, like every other business record (V15).
--   amount      in the agency's currency (V36); the amount carries none itself.
--   received_on the day the money came in.
--   hold_until  the last day the listing is held for this buyer. Never before
--               received_on.
--   holder      who keeps the money meanwhile: AGENCY, SELLER or NOTARY.
--   note        optional, at most 500 characters.
--   outcome     NULL while the deposit is active; then APPLIED (counted towards
--               the purchase), REFUNDED or FORFEITED.
--   closed_on   the day it ended. Set exactly when outcome is.
--   recorded_by ON DELETE SET NULL: the deposit outlives whoever wrote it down.
--
-- While a deposit is active the deal's listing reads as reserved for that buyer
-- and is not offered as a match to anybody else.

CREATE TABLE deal_deposits (
    id           BIGSERIAL      PRIMARY KEY,
    deal_id      BIGINT         NOT NULL REFERENCES deals(id) ON DELETE CASCADE,
    team_id      BIGINT         REFERENCES teams(id),
    amount       NUMERIC(15, 2) NOT NULL,
    received_on  DATE           NOT NULL,
    hold_until   DATE           NOT NULL,
    holder       VARCHAR(16)    NOT NULL,
    note         VARCHAR(500),
    outcome      VARCHAR(16),
    closed_on    DATE,
    recorded_by  BIGINT         REFERENCES users(id) ON DELETE SET NULL,
    created_at   TIMESTAMP      NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMP,
    CONSTRAINT chk_deal_deposits_amount CHECK (amount > 0),
    CONSTRAINT chk_deal_deposits_hold CHECK (hold_until >= received_on),
    CONSTRAINT chk_deal_deposits_holder CHECK (holder IN ('AGENCY', 'SELLER', 'NOTARY')),
    CONSTRAINT chk_deal_deposits_outcome
        CHECK (outcome IS NULL OR outcome IN ('APPLIED', 'REFUNDED', 'FORFEITED')),
    CONSTRAINT chk_deal_deposits_closed
        CHECK ((outcome IS NULL) = (closed_on IS NULL))
);

-- Every read on a deal is "this deal's deposits"; the listing badge and the
-- matching ask whether a deal has an active one.
CREATE INDEX idx_deal_deposits_deal ON deal_deposits(deal_id, outcome);

-- The dashboard asks for the agency's active deposits whose hold runs out soon.
CREATE INDEX idx_deal_deposits_hold ON deal_deposits(team_id, hold_until);

-- Found and cleared by the SET NULL above.
CREATE INDEX idx_deal_deposits_recorded_by ON deal_deposits(recorded_by);
