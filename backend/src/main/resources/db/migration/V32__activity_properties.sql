-- V32__activity_properties.sql
--
-- What was sent. A logged message used to say "sent three flats" in free text,
-- if the agent wrote anything at all, so the next person to open the client had
-- no way to tell which three. An entry in the history can now point at the
-- listings it was about, and the match list can say "sent on the 26th" next to
-- each one it has already gone out as.
--
-- activity_id  ON DELETE CASCADE: the link is part of the entry and goes with it.
-- property_id  ON DELETE CASCADE: a listing that is deleted drops out of the
--              entries that mentioned it; the entry itself, the fact of the
--              message, stays.
--
-- No team_id: a link lives inside an entry, which already carries the client's
-- team, and it is only ever read through that entry.

CREATE TABLE client_activity_properties (
    activity_id  BIGINT NOT NULL REFERENCES client_activities(id) ON DELETE CASCADE,
    property_id  BIGINT NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
    PRIMARY KEY (activity_id, property_id)
);

-- The primary key answers "which listings did this entry send"; this answers
-- the other direction, and is what a listing's delete cascades through.
CREATE INDEX idx_client_activity_properties_property ON client_activity_properties(property_id);
