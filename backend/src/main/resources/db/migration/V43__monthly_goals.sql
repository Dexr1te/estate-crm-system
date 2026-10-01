-- V43__monthly_goals.sql
--
-- A month's target: what an agent (or the whole agency) means to earn in
-- commission and how many deals they mean to win. Progress is never stored;
-- it is counted from the deals won in that calendar month (deals.closed_at,
-- deals.deal_price × deals.commission_percent), in the agency's currency.
--
-- monthly_goals
--   team_id           the agency. ON DELETE CASCADE: a target is the agency's.
--   agent_id          whose target it is; NULL is the agency-wide target.
--                     ON DELETE CASCADE with the account: a deleted person's
--                     targets mean nothing to anyone.
--   month_start       the first day of the month the target is for.
--   source            MANAGER  set by the agency's manager (or an admin);
--                     PERSONAL set by the agent for themselves.
--                     An agent may hold both for one month. The manager's
--                     wins; the agent's own counts only while the manager has
--                     set none, and comes back if the manager takes theirs
--                     off. The agency-wide target is only ever the manager's.
--   commission_target in the agency's currency, whole or to the cent.
--   deals_target      deals won.
--                     Either may be NULL, not both.

CREATE TABLE monthly_goals (
    id                 BIGSERIAL      PRIMARY KEY,
    team_id            BIGINT         NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    agent_id           BIGINT         REFERENCES users(id) ON DELETE CASCADE,
    month_start        DATE           NOT NULL,
    source             VARCHAR(10)    NOT NULL,
    commission_target  NUMERIC(15,2),
    deals_target       INTEGER,
    created_at         TIMESTAMP      NOT NULL,
    updated_at         TIMESTAMP      NOT NULL,
    CONSTRAINT monthly_goals_source CHECK (source IN ('MANAGER', 'PERSONAL')),
    CONSTRAINT monthly_goals_first_of_month CHECK (EXTRACT(DAY FROM month_start) = 1),
    CONSTRAINT monthly_goals_some_target
        CHECK (commission_target IS NOT NULL OR deals_target IS NOT NULL),
    CONSTRAINT monthly_goals_commission_positive
        CHECK (commission_target IS NULL OR commission_target > 0),
    CONSTRAINT monthly_goals_deals_range
        CHECK (deals_target IS NULL OR (deals_target > 0 AND deals_target <= 1000)),
    CONSTRAINT monthly_goals_agency_is_managers
        CHECK (agent_id IS NOT NULL OR source = 'MANAGER')
);

-- One target per person, month and source; one agency-wide target per month.
-- COALESCE because a unique index lets any number of NULL agent_ids through.
CREATE UNIQUE INDEX uq_monthly_goals_target
    ON monthly_goals (team_id, COALESCE(agent_id, 0), month_start, source);

-- Every read is "this agency's targets for this month".
CREATE INDEX idx_monthly_goals_team_month ON monthly_goals (team_id, month_start);
