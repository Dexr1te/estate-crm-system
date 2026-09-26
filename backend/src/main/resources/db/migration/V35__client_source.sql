-- V35__client_source.sql
--
-- Where a client came from. A buyer who opens a listing's public link can now
-- leave their name and number on the page, and the agent should be able to tell
-- those people apart from the ones they typed in themselves or brought in from a
-- spreadsheet.
--
-- clients.source  MANUAL (typed in the app), IMPORT (a CSV import),
--                 PUBLIC_LINK (the form on a listing's public page). Every row
--                 that exists today was typed in or imported before the two
--                 were told apart, so the default MANUAL is the honest backfill.
--
-- property_share_links.lead_count
--                 how many enquiries arrived through this link. A counter on
--                 the link, like view_count, so "N enquiries" on the listing is
--                 a column read; a new link starts at zero, as its views do.

ALTER TABLE clients
    ADD COLUMN source VARCHAR(20) NOT NULL DEFAULT 'MANUAL';

ALTER TABLE clients
    ADD CONSTRAINT chk_clients_source
        CHECK (source IN ('MANUAL', 'IMPORT', 'PUBLIC_LINK'));

ALTER TABLE property_share_links
    ADD COLUMN lead_count BIGINT NOT NULL DEFAULT 0;
