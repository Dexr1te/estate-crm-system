-- V26__property_price_history.sql
--
-- What a listing used to cost. A listing holds one price, so when a seller
-- dropped it the old figure was simply overwritten: nobody could see that the
-- flat had come down, or by how much, or when.
--
-- A row is written whenever an edit changes the price, never on creation and
-- never when the figure is re-saved unchanged.
--
-- ON DELETE CASCADE from the listing: its history means nothing once it is
-- gone. ON DELETE SET NULL from the author: the history belongs to the agency
-- and outlives whoever made the change.

CREATE TABLE property_price_changes (
    id           BIGSERIAL PRIMARY KEY,
    property_id  BIGINT         NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
    team_id      BIGINT REFERENCES teams(id),
    old_price    NUMERIC(15, 2) NOT NULL,
    new_price    NUMERIC(15, 2) NOT NULL,
    changed_by   BIGINT REFERENCES users(id) ON DELETE SET NULL,
    changed_at   TIMESTAMP      NOT NULL DEFAULT NOW()
);

-- Every read is "this listing's changes, newest first", or the newest one only.
CREATE INDEX idx_property_price_changes_property
    ON property_price_changes(property_id, changed_at DESC);
