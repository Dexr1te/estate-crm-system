-- V58__commission_payouts.sql
--
-- A split (V55) says who is owed what of a won deal's commission. Whether
-- the agency has actually paid it out was kept nowhere, so a manager tracked
-- it on paper and a colleague had to ask what they were still owed.
--
-- commission_splits.paid_at      when the share was paid out; NULL while it is
--                                still owed. Only a won deal's share is paid,
--                                and only by the agency's manager or an admin
--                                (the service's rules). Undoing a payout sets
--                                it back to NULL.
-- commission_splits.paid_by      who marked it paid. ON DELETE SET NULL: the
--                                payout stands when that account is closed.
-- commission_splits.payout_note  what the manager wrote down with it (a
--                                transfer number, "cash"), at most 500.
--
-- The deal's own agent still has no row (V55), so what they hold is not a
-- payout here: only the shares of colleagues and co-brokers are.
--
-- Every existing share is unpaid.

ALTER TABLE commission_splits ADD COLUMN paid_at TIMESTAMP;
ALTER TABLE commission_splits ADD COLUMN paid_by BIGINT REFERENCES users(id) ON DELETE SET NULL;
ALTER TABLE commission_splits ADD COLUMN payout_note VARCHAR(500);

-- Who paid it and the note belong to a payout: an unpaid share carries
-- neither. A paid one may have lost who paid it (the SET NULL above).
ALTER TABLE commission_splits ADD CONSTRAINT chk_commission_splits_payout CHECK (
    paid_at IS NOT NULL OR (paid_by IS NULL AND payout_note IS NULL));

-- Found and cleared by the SET NULL above.
CREATE INDEX idx_commission_splits_paid_by ON commission_splits(paid_by);
