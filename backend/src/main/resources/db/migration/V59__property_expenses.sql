-- V59__property_expenses.sql
--
-- An agency spends money marketing a listing: the photographer, ads on the
-- portals, staging, cleaning, the lawyer. That money went out of a card or a
-- cash box and the CRM knew nothing of it, so nobody could say what a listing
-- had cost, or what the agency spent on its stock over a month.
--
-- property_expenses        one row per payment made for one listing.
--   team_id      always the listing's agency, like every business record (V15).
--                Every read keeps to the listing's own wall.
--   property_id  ON DELETE CASCADE: what a listing cost means nothing once the
--                listing is gone.
--   category     PHOTO, ADVERTISING, STAGING, CLEANING, LEGAL or OTHER.
--   amount       in the agency's currency (V36), above zero.
--   spent_on     the day it was paid, as a calendar date in the agency's zone;
--                never after today (the service refuses that).
--   note         optional, at most 500 characters.
--   created_by   who recorded it. SET NULL with the account: the money was
--                still spent.

CREATE TABLE property_expenses (
    id           BIGSERIAL      PRIMARY KEY,
    team_id      BIGINT         REFERENCES teams(id) ON DELETE CASCADE,
    property_id  BIGINT         NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
    category     VARCHAR(20)    NOT NULL,
    amount       NUMERIC(14, 2) NOT NULL,
    spent_on     DATE           NOT NULL,
    note         VARCHAR(500),
    created_by   BIGINT         REFERENCES users(id) ON DELETE SET NULL,
    created_at   TIMESTAMP      NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_property_expenses_category
        CHECK (category IN ('PHOTO', 'ADVERTISING', 'STAGING', 'CLEANING', 'LEGAL', 'OTHER')),
    CONSTRAINT chk_property_expenses_amount CHECK (amount > 0)
);

-- A listing's expenses, the latest first.
CREATE INDEX idx_property_expenses_property ON property_expenses(property_id, spent_on DESC);

-- What an agency spent over a period.
CREATE INDEX idx_property_expenses_team_spent ON property_expenses(team_id, spent_on);

CREATE INDEX idx_property_expenses_created_by ON property_expenses(created_by);
