-- V41__client_lead_source.sql
--
-- How a client reached the agency, so a manager can see which channels bring
-- people in and which of them end in a sale. Not the same thing as
-- clients.source (V35), which records how the card was entered (typed in,
-- imported or left on a public page) and never changes.
--
-- clients.lead_source         REFERRAL, WEBSITE, PORTAL, SOCIAL, WALK_IN,
--                             COLD_CALL, REPEAT or OTHER. NULL means nobody
--                             recorded it, which is true of almost every
--                             client that exists today.
-- clients.lead_source_detail  free text beside it: who referred them, which
--                             portal, which listing. Meaningless without a
--                             source, so the check refuses one alone.
--
-- Backfill: a client who left their details on a listing's public page came
-- through the agency's own website, and the app now records them so. Which
-- listing is not recoverable here, so their detail stays empty.

ALTER TABLE clients ADD COLUMN lead_source        VARCHAR(20);
ALTER TABLE clients ADD COLUMN lead_source_detail VARCHAR(255);

ALTER TABLE clients
    ADD CONSTRAINT chk_clients_lead_source
        CHECK (lead_source IS NULL OR lead_source IN ('REFERRAL', 'WEBSITE', 'PORTAL', 'SOCIAL',
                                                      'WALK_IN', 'COLD_CALL', 'REPEAT', 'OTHER'));

ALTER TABLE clients
    ADD CONSTRAINT chk_clients_lead_source_detail
        CHECK (lead_source_detail IS NULL OR lead_source IS NOT NULL);

UPDATE clients SET lead_source = 'WEBSITE' WHERE source = 'PUBLIC_LINK';

-- The list narrows by source within an agency, and the breakdown groups by it.
CREATE INDEX idx_clients_team_lead_source ON clients(team_id, lead_source);
