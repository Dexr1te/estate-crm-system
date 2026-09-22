-- V21__viewing_outcome.sql
--
-- What came of a showing. A meeting carried only `completed`, a yes-or-no that
-- says the appointment happened and nothing about how it went — so a flat a
-- buyer walked away from kept coming back to the top of their matching
-- listings, and the agent had to remember, every time, that it had been shown
-- and turned down.
--
-- Null until somebody records it: a meeting in the future has no outcome, and
-- most meetings never get one.

ALTER TABLE meetings
    ADD COLUMN outcome      VARCHAR(20),
    ADD COLUMN outcome_note TEXT;

-- Matching asks the same question for every candidate listing: has this buyer
-- already been shown it, and what did they say.
CREATE INDEX idx_meetings_client_property ON meetings(client_id, property_id);
