-- V7__update_deals_table.sql

-- 1. Add a client's budget to a deal
ALTER TABLE deals ADD COLUMN budget NUMERIC(15,2);

-- 2. Make property_id optional (for the LEAD stage)
ALTER TABLE deals ALTER COLUMN property_id DROP NOT NULL;