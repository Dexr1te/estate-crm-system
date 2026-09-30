-- V40__message_templates.sql
--
-- Agents write the same few messages to clients all day — the first hello, a
-- listing that fits, an invitation to a viewing, the question after it. An
-- agency now keeps those as templates, and the app fills them in for the
-- client, the agent and a listing before the agent sends them over WhatsApp
-- or SMS.
--
-- message_templates        the agency's own. ON DELETE CASCADE with the team:
--                          they are the agency's words, nobody else's.
--   title     what the manager calls it in the picker ("Viewing invitation").
--   body      the text, with placeholders the app fills in: {client},
--             {agent}, {listing}, {price}, {address} and {link} (the listing's
--             public link, when it has one). The server refuses any other
--             name in braces, so the app never has to guess at one.
--             Like the checklist template (V37) there is no translation
--             table: the defaults are written once, in the language of the
--             manager who first opens them (Russian when that is not known),
--             and from then on they are the agency's text to edit.
--   created_at / updated_at  for the editor's order and nothing else.
--
-- teams.message_templates_seeded  whether the defaults have been written for
--             this agency. Agencies that exist today get them on first read.
--             The flag, not "has no rows", is what says so: a manager may
--             delete every template on purpose.

ALTER TABLE teams
    ADD COLUMN message_templates_seeded BOOLEAN NOT NULL DEFAULT FALSE;

CREATE TABLE message_templates (
    id          BIGSERIAL      PRIMARY KEY,
    team_id     BIGINT         NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    title       VARCHAR(80)    NOT NULL,
    body        VARCHAR(1000)  NOT NULL,
    created_at  TIMESTAMP      NOT NULL,
    updated_at  TIMESTAMP      NOT NULL
);

-- Every read is "this agency's templates".
CREATE INDEX idx_message_templates_team ON message_templates(team_id);
