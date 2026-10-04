-- V53__partners.sql
--
-- An agency works with people outside it: the mortgage broker who sends a
-- buyer over, the notary the papers go to, the appraiser, the developer, the
-- agency across town. They are now in the book, they can be where a client
-- came from, and a client can be sent to them.
--
-- partners                  the agency's, not an agent's: everyone in it sees
--                           every partner.
--   team_id       the agency, like every business record (V15).
--   created_by_id who added it; with whoever added it, a manager or an admin
--                 may change it. Handed to the successor when that account
--                 is deleted, and SET NULL as the last resort: the partner
--                 stays with the agency either way.
--   kind          MORTGAGE_BROKER, LAWYER (a lawyer or a notary), APPRAISER,
--                 DEVELOPER, AGENCY or OTHER.
--   fee_type / fee_value   the referral fee, both or neither: PERCENT of the
--                 agency's commission on a won deal (above 0, at most 100),
--                 or a FIXED amount per won deal in the agency's currency
--                 (V36). Worked out per deal by ReferralFee, from the deal's
--                 commission as DealMoney defines it, so a rent pays on one
--                 month's rent.
--
-- partner_handoffs          a client sent to a partner, on a day, with where
--                           it has got to: SENT, IN_PROGRESS or DONE.
--   client_id     ON DELETE CASCADE: the hand-off is part of the client's card.
--   partner_id    no cascade: a partner with hand-offs is not deleted (the
--                 service refuses with PARTNER_IN_USE first).
--   sent_by_id    who sent them; SET NULL with the account.
--
-- clients.referred_by_partner_id   the partner who sent the client. Rides on
--                 the lead source (V41) rather than beside it: lead_source
--                 gains PARTNER, and the partner is there exactly when the
--                 source is PARTNER. No cascade, for the same reason as the
--                 hand-offs: where a client came from, and the fee owed on
--                 it, outlive nobody's tidying up.

CREATE TABLE partners (
    id             BIGSERIAL     PRIMARY KEY,
    team_id        BIGINT        REFERENCES teams(id),
    created_by_id  BIGINT        REFERENCES users(id) ON DELETE SET NULL,
    name           VARCHAR(120)  NOT NULL,
    company        VARCHAR(120),
    kind           VARCHAR(20)   NOT NULL,
    phone          VARCHAR(40),
    email          VARCHAR(255),
    note           VARCHAR(1000),
    fee_type       VARCHAR(10),
    fee_value      NUMERIC(15, 2),
    created_at     TIMESTAMP     NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMP     NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_partners_kind
        CHECK (kind IN ('MORTGAGE_BROKER', 'LAWYER', 'APPRAISER', 'DEVELOPER', 'AGENCY', 'OTHER')),
    CONSTRAINT chk_partners_fee CHECK (
        (fee_type IS NULL AND fee_value IS NULL)
        OR (COALESCE(fee_type, '') = 'PERCENT' AND fee_value IS NOT NULL AND fee_value > 0 AND fee_value <= 100)
        OR (COALESCE(fee_type, '') = 'FIXED' AND fee_value IS NOT NULL AND fee_value > 0))
);

-- The agency's directory, by name.
CREATE INDEX idx_partners_team_name ON partners(team_id, name);
CREATE INDEX idx_partners_created_by ON partners(created_by_id);

CREATE TABLE partner_handoffs (
    id          BIGSERIAL     PRIMARY KEY,
    team_id     BIGINT        REFERENCES teams(id),
    client_id   BIGINT        NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    partner_id  BIGINT        NOT NULL REFERENCES partners(id),
    sent_by_id  BIGINT        REFERENCES users(id) ON DELETE SET NULL,
    sent_on     DATE          NOT NULL,
    status      VARCHAR(12)   NOT NULL DEFAULT 'SENT',
    note        VARCHAR(500),
    created_at  TIMESTAMP     NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP     NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_partner_handoffs_status CHECK (status IN ('SENT', 'IN_PROGRESS', 'DONE'))
);

CREATE INDEX idx_partner_handoffs_client ON partner_handoffs(client_id);
CREATE INDEX idx_partner_handoffs_partner ON partner_handoffs(partner_id);
CREATE INDEX idx_partner_handoffs_sent_by ON partner_handoffs(sent_by_id);

ALTER TABLE clients ADD COLUMN referred_by_partner_id BIGINT REFERENCES partners(id);

-- A partner's referrals are counted by partner.
CREATE INDEX idx_clients_referred_by ON clients(referred_by_partner_id);

ALTER TABLE clients DROP CONSTRAINT chk_clients_lead_source;

ALTER TABLE clients
    ADD CONSTRAINT chk_clients_lead_source
        CHECK (lead_source IS NULL OR lead_source IN ('REFERRAL', 'WEBSITE', 'PORTAL', 'SOCIAL',
                                                      'WALK_IN', 'COLD_CALL', 'REPEAT', 'PARTNER',
                                                      'OTHER'));

ALTER TABLE clients
    ADD CONSTRAINT chk_clients_referred_by CHECK (
        (referred_by_partner_id IS NULL AND COALESCE(lead_source, '') <> 'PARTNER')
        OR (referred_by_partner_id IS NOT NULL AND COALESCE(lead_source, '') = 'PARTNER'));
