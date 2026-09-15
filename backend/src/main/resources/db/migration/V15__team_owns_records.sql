-- V15__team_owns_records.sql
--
-- A team becomes an agency: the wall that no record crosses.
--
-- Until now the only boundary was the agent on a record, and several reads ignored
-- even that — listings were global, and a client with no agent was visible to all.
-- That was tolerable while one agency ran the whole instance. It stops being
-- tolerable once anyone can sign up and start their own, so every business record
-- now names the team it belongs to, and the services filter on it.
--
-- The existing instance was one agency, and this migration treats it as one:
--
--   1. No teams yet but people to put in one  -> create a single team for them.
--   2. Exactly one team                       -> everyone who is not an admin and
--                                                has no team joins it; it gets a
--                                                manager if it has none.
--   3. Records take the team of their agent.
--   4. Exactly one team                       -> listings and clients that still
--                                                have no team go to it. They were
--                                                visible to everybody before.
--
-- With several teams nobody can be placed automatically. Those accounts and their
-- team-less records stay as they are: each person still sees their own, admins
-- see everything, and the records follow their owner into whichever team they
-- join (see RecordHandoverService).

-- The team column ----------------------------------------------------------------

ALTER TABLE clients    ADD COLUMN team_id BIGINT REFERENCES teams(id);
ALTER TABLE properties ADD COLUMN team_id BIGINT REFERENCES teams(id);
ALTER TABLE deals      ADD COLUMN team_id BIGINT REFERENCES teams(id);
ALTER TABLE meetings   ADD COLUMN team_id BIGINT REFERENCES teams(id);

CREATE INDEX idx_clients_team    ON clients(team_id);
CREATE INDEX idx_properties_team ON properties(team_id);
CREATE INDEX idx_deals_team      ON deals(team_id);
CREATE INDEX idx_meetings_team   ON meetings(team_id);
CREATE INDEX idx_users_team      ON users(team_id);

-- Two agencies may share a name, and may each have a client with the same address.

ALTER TABLE teams   DROP CONSTRAINT IF EXISTS teams_name_key;
ALTER TABLE clients DROP CONSTRAINT IF EXISTS clients_email_key;
ALTER TABLE clients ADD CONSTRAINT uq_clients_team_email UNIQUE (team_id, email);

-- 1. A single agency with no team yet ----------------------------------------------

INSERT INTO teams (name, created_at)
SELECT 'Agency', NOW()
WHERE NOT EXISTS (SELECT 1 FROM teams)
  AND EXISTS (SELECT 1 FROM users WHERE role <> 'ADMIN');

-- 2. Everyone into the only team -------------------------------------------------

UPDATE users
SET team_id = (SELECT id FROM teams)
WHERE role <> 'ADMIN'
  AND team_id IS NULL
  AND (SELECT COUNT(*) FROM teams) = 1;

UPDATE teams
SET manager_id = (
        SELECT u.id FROM users u
        WHERE u.team_id = teams.id AND u.role = 'MANAGER'
        ORDER BY u.created_at, u.id
        LIMIT 1)
WHERE manager_id IS NULL
  AND (SELECT COUNT(*) FROM teams) = 1;

-- 3. Records follow their agent ----------------------------------------------------

UPDATE clients    r SET team_id = u.team_id FROM users u WHERE r.agent_id = u.id AND u.team_id IS NOT NULL;
UPDATE properties r SET team_id = u.team_id FROM users u WHERE r.agent_id = u.id AND u.team_id IS NOT NULL;
UPDATE deals      r SET team_id = u.team_id FROM users u WHERE r.agent_id = u.id AND u.team_id IS NOT NULL;
UPDATE meetings   r SET team_id = u.team_id FROM users u WHERE r.agent_id = u.id AND u.team_id IS NOT NULL;

-- 4. What had no owner was shared, so it stays shared within the agency ----------

UPDATE properties
SET team_id = (SELECT id FROM teams)
WHERE team_id IS NULL
  AND agent_id IS NULL
  AND (SELECT COUNT(*) FROM teams) = 1;

UPDATE clients
SET team_id = (SELECT id FROM teams)
WHERE team_id IS NULL
  AND agent_id IS NULL
  AND (SELECT COUNT(*) FROM teams) = 1;
