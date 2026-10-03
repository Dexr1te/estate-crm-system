-- V48__client_handover.sql
--
-- A manager can hand an agent's work to a colleague without anybody leaving:
-- a holiday, an agent with too much on. Each client that moves gets a line in
-- its history saying from whom and to whom, so whoever opens the card later
-- knows why the name on it changed.
--
-- client_activities.handover_from_name, handover_to_name
--             set on that line and on no other. Names, not ids, the way
--             author_name is kept: the line still reads right after either
--             account is closed. Both or neither. Nullable, so no backfill.
--
-- The line is a NOTE with no text and is not contact with the client: the
-- client list's "last contact" and the going-cold list leave it out.

ALTER TABLE client_activities ADD COLUMN handover_from_name VARCHAR(255);
ALTER TABLE client_activities ADD COLUMN handover_to_name   VARCHAR(255);

ALTER TABLE client_activities
    ADD CONSTRAINT chk_client_activities_handover
        CHECK ((handover_from_name IS NULL AND handover_to_name IS NULL)
            OR (handover_from_name IS NOT NULL AND handover_to_name IS NOT NULL
                AND type = 'NOTE'));
