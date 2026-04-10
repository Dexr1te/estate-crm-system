-- V7__update_deals_table.sql

-- 1. Добавить бюджет клиента в сделку
ALTER TABLE deals ADD COLUMN budget NUMERIC(15,2);

-- 2. Сделать property_id необязательным (для этапа LEAD)
ALTER TABLE deals ALTER COLUMN property_id DROP NOT NULL;