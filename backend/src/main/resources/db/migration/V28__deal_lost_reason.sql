-- V28__deal_lost_reason.sql
--
-- Why a deal was lost, and when each deal moved between stages.
--
-- lost_reason is required by the API whenever a deal is moved to CLOSED_LOST
-- and cleared when it leaves that status. Deals lost before this migration
-- keep NULL: nobody recorded a reason then, and inventing one would put a
-- fake figure into the funnel. The API reads NULL as "unspecified".

ALTER TABLE deals ADD COLUMN lost_reason VARCHAR(32);
ALTER TABLE deals ADD COLUMN lost_note   VARCHAR(500);

-- One row per status change, and one on creation with from_status NULL, so
-- the funnel can tell whether a lost deal ever reached negotiation and how
-- long a won deal took. Existing deals get no rows; the funnel falls back to
-- created_at and closed_at for them.
--
-- ON DELETE CASCADE from the deal: its history means nothing once it is gone.
-- ON DELETE SET NULL from the author: the history belongs to the agency and
-- outlives whoever moved the deal.

CREATE TABLE deal_status_changes (
    id           BIGSERIAL PRIMARY KEY,
    deal_id      BIGINT      NOT NULL REFERENCES deals(id) ON DELETE CASCADE,
    from_status  VARCHAR(32),
    to_status    VARCHAR(32) NOT NULL,
    changed_by   BIGINT REFERENCES users(id) ON DELETE SET NULL,
    changed_at   TIMESTAMP   NOT NULL DEFAULT NOW()
);

-- The funnel asks "did this deal ever reach this status, and when".
CREATE INDEX idx_deal_status_changes_deal
    ON deal_status_changes(deal_id, to_status);
