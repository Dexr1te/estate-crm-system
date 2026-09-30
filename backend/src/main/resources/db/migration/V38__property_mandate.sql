-- V38__property_mandate.sql
--
-- The seller's agreement with the agency. An exclusive listing is the agency's
-- to sell only until the agreement runs out, and nobody saw that date coming:
-- the agent found out when the seller signed with somebody else.
--
-- properties.mandate_type      EXCLUSIVE or OPEN. NULL means no agreement has
--                              been recorded, which is true of every listing
--                              that exists today, so no backfill is needed.
-- properties.mandate_end_date  the last day the agreement holds; NULL means it
--                              has no end date. A date means nothing without
--                              an agreement, so the check refuses one alone.
--                              An exclusive agreement with no end date is
--                              allowed: some hold until the seller revokes it.

ALTER TABLE properties ADD COLUMN mandate_type     VARCHAR(20);
ALTER TABLE properties ADD COLUMN mandate_end_date DATE;

ALTER TABLE properties
    ADD CONSTRAINT chk_properties_mandate_type
        CHECK (mandate_type IS NULL OR mandate_type IN ('EXCLUSIVE', 'OPEN'));

ALTER TABLE properties
    ADD CONSTRAINT chk_properties_mandate_end_date
        CHECK (mandate_end_date IS NULL OR mandate_type IS NOT NULL);

-- The dashboard asks for the agency's listings whose agreement ends soon.
CREATE INDEX idx_properties_mandate_end_date ON properties(team_id, mandate_end_date);
