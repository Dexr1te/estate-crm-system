-- V50__deal_leases.sql
--
-- Until now every deal was a sale. An agency also lets flats, and a let flat
-- comes back: the lease runs out on a known day, and that day is a reason to
-- call the tenant and the landlord before somebody else does.
--
-- deals.kind                 SALE or RENT. Every existing deal is a SALE.
-- deals.monthly_rent         RENT only, required there, above zero. In the
--                            agency's currency (V36), like deal_price. A rent
--                            has no deal_price: that column keeps meaning what
--                            a place sold for. The commission on a rent is
--                            commission_percent of one month's rent.
-- deals.lease_start          RENT only, required there: the first day of the
-- deals.lease_end            lease and the last. The end is after the start.
-- deals.lease_reminder_days  RENT only, optional: how many days before the end
--                            the agent wants to hear about it, 1-365. NULL
--                            means the default (30, in the service).
-- deals.landlord_id          RENT only, optional: the client who lets the place.
--                            The deal's own client is the tenant. ON DELETE SET
--                            NULL: the lease outlives the landlord's card.
-- deals.lease_reminded_for   the lease_end the agent was last reminded about.
--                            The reminder runs every hour; it speaks only while
--                            this differs from lease_end, so it says it once,
--                            and once more after the lease is renewed.

ALTER TABLE deals ADD COLUMN kind VARCHAR(8) NOT NULL DEFAULT 'SALE';
ALTER TABLE deals ADD COLUMN monthly_rent NUMERIC(15, 2);
ALTER TABLE deals ADD COLUMN lease_start DATE;
ALTER TABLE deals ADD COLUMN lease_end DATE;
ALTER TABLE deals ADD COLUMN lease_reminder_days INTEGER;
ALTER TABLE deals ADD COLUMN landlord_id BIGINT REFERENCES clients(id) ON DELETE SET NULL;
ALTER TABLE deals ADD COLUMN lease_reminded_for DATE;

ALTER TABLE deals ADD CONSTRAINT chk_deals_kind CHECK (kind IN ('SALE', 'RENT'));

-- A sale carries none of the lease; a rent carries its rent and both days, and
-- no sale price.
ALTER TABLE deals ADD CONSTRAINT chk_deals_lease CHECK (
    (kind = 'SALE' AND monthly_rent IS NULL AND lease_start IS NULL AND lease_end IS NULL
        AND lease_reminder_days IS NULL AND landlord_id IS NULL)
    OR (kind = 'RENT' AND monthly_rent > 0 AND lease_start IS NOT NULL AND lease_end > lease_start
        AND deal_price IS NULL
        AND (lease_reminder_days IS NULL OR lease_reminder_days BETWEEN 1 AND 365))
);

-- "Leases ending in the next N days" and the hourly reminder both look up
-- leases by their last day.
CREATE INDEX idx_deals_lease_end ON deals(team_id, lease_end);

-- Found and cleared by the SET NULL above.
CREATE INDEX idx_deals_landlord ON deals(landlord_id);
