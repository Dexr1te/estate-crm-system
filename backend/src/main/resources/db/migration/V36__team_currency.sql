-- V36__team_currency.sql
--
-- The currency an agency prices its listings in.
--
-- teams.currency  an ISO 4217 code, one of the currencies the agencies we serve
--                 work in: KZT, RUB, USD, EUR, UZS, KGS. Amounts are stored as
--                 plain numbers, so this only decides how they are shown; a
--                 manager changing it converts nothing.
--
-- Every agency that exists today has been looking at its prices with a "$" in
-- front of them, so USD is the honest backfill. Guessing from the city would
-- quietly change what somebody sees the morning after a deploy.

ALTER TABLE teams
    ADD COLUMN currency VARCHAR(3) NOT NULL DEFAULT 'USD';

ALTER TABLE teams
    ADD CONSTRAINT chk_teams_currency
        CHECK (currency IN ('KZT', 'RUB', 'USD', 'EUR', 'UZS', 'KGS'));
