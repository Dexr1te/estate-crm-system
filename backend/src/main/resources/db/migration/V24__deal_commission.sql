-- V24__deal_commission.sql
--
-- What the agent is paid for closing a deal, as a share of its price. Agents
-- work on commission, and until now the CRM could say how much a flat sold for
-- but not what that sale was worth to the person who sold it.
--
-- Stored as a percentage rather than an amount: the rate is often agreed before
-- the price, and the amount follows from both. Null means nobody has said yet.

ALTER TABLE deals
    ADD COLUMN commission_percent NUMERIC(5,2);

ALTER TABLE deals
    ADD CONSTRAINT deals_commission_percent_range
    CHECK (commission_percent IS NULL OR (commission_percent > 0 AND commission_percent <= 100));
