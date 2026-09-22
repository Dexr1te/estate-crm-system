-- V20__meeting_property.sql
--
-- A meeting could name the client and the deal but not the listing, which left
-- the most common meeting an agency books — a viewing — with nowhere to record
-- what is being viewed. The address went into the title as text, so a listing
-- could not say how often it had been shown, and a viewing booked from a
-- matching listing had to have that listing retyped into it.
--
-- Nullable: plenty of meetings are not viewings.
--
-- ON DELETE SET NULL, because the meeting happened. Deleting a listing later
-- must not take the history of showing it with it.

ALTER TABLE meetings
    ADD COLUMN property_id BIGINT,
    ADD CONSTRAINT fk_meetings_property FOREIGN KEY (property_id)
        REFERENCES properties(id) ON DELETE SET NULL;

CREATE INDEX idx_meetings_property ON meetings(property_id);
