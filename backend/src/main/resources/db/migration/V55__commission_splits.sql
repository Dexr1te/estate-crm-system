-- V55__commission_splits.sql
--
-- A deal is often worked by more than one person: the agent who holds it, a
-- colleague who found the buyer, an agent from another agency who brought the
-- flat. Until now the whole commission went to the deal's agent, and the
-- leaderboard, the monthly goals and the dashboard said so too.
--
-- commission_splits      one row per party the deal's agent shares the
--                        commission with. The deal's agent has no row: they
--                        hold whatever the rows leave, so a deal with no rows
--                        is exactly what every deal was before, all of it the
--                        agent's. The service keeps the rows at most 100 in
--                        total and never gives the deal's agent a row.
--   deal_id              ON DELETE CASCADE: a share means nothing without its
--                        deal.
--   user_id              a colleague from the deal's agency, or NULL for an
--                        outside co-broker. ON DELETE CASCADE: an account
--                        closed with nobody to take its records gives its
--                        share back to the deal's agent (with a successor, the
--                        service hands the share over first).
--   co_broker_name       the outside co-broker: a name, and the agency they
--   co_broker_agency     work for if given. Exactly one of user_id and
--                        co_broker_name is set. A co-broker's share leaves the
--                        agency: nobody here is credited with it.
--   share_percent        of the deal's commission (whatever DealMoney takes it
--                        to be: the price of a sale, a month's rent of a rent),
--                        above 0 and at most 100.
--   position             the order the editor listed them in.

CREATE TABLE commission_splits (
    id               BIGSERIAL     PRIMARY KEY,
    deal_id          BIGINT        NOT NULL REFERENCES deals(id) ON DELETE CASCADE,
    user_id          BIGINT        REFERENCES users(id) ON DELETE CASCADE,
    co_broker_name   VARCHAR(255),
    co_broker_agency VARCHAR(255),
    share_percent    NUMERIC(5, 2) NOT NULL,
    position         INTEGER       NOT NULL DEFAULT 0,
    created_at       TIMESTAMP     NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_commission_splits_party CHECK (
        (user_id IS NOT NULL AND co_broker_name IS NULL AND co_broker_agency IS NULL)
        OR (user_id IS NULL AND co_broker_name IS NOT NULL)),
    CONSTRAINT chk_commission_splits_share CHECK (share_percent > 0 AND share_percent <= 100),
    CONSTRAINT uq_commission_splits_person UNIQUE (deal_id, user_id)
);

-- Every read is "this deal's split" or, for the totals, "the splits of these
-- deals"; the deal comes first.
CREATE INDEX idx_commission_splits_deal ON commission_splits(deal_id);

-- "Deals I have a share in": what an agent on their own records may still see,
-- and what a leaver hands over. Also found and cleared by the CASCADE above.
CREATE INDEX idx_commission_splits_user ON commission_splits(user_id);
