-- V14__allow_deleting_users.sql
--
-- Makes it possible to delete a user at all.
--
-- Deals, meetings and documents are reassigned to a replacement agent before the
-- row goes, so their RESTRICT constraints are satisfied by the service. The three
-- references below cannot be reassigned that way and would otherwise block every
-- delete forever:
--
--   audit_logs.actor_id  the journal must outlive the person it recorded, so the
--                        row stays and simply forgets who acted. Deleting audit
--                        rows to free a user would defeat the point of having them.
--   users.created_by     "invited by" is history, not a dependency.
--   teams.manager_id     a team survives losing its manager; it just has none
--                        until one is assigned.

ALTER TABLE audit_logs ALTER COLUMN actor_id DROP NOT NULL;

ALTER TABLE audit_logs DROP CONSTRAINT fk_audit_log_actor;
ALTER TABLE audit_logs
    ADD CONSTRAINT fk_audit_log_actor FOREIGN KEY (actor_id)
        REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE users DROP CONSTRAINT fk_users_created_by;
ALTER TABLE users
    ADD CONSTRAINT fk_users_created_by FOREIGN KEY (created_by)
        REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE teams DROP CONSTRAINT fk_teams_manager;
ALTER TABLE teams
    ADD CONSTRAINT fk_teams_manager FOREIGN KEY (manager_id)
        REFERENCES users(id) ON DELETE SET NULL;
