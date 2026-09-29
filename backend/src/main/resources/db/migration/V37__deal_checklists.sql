-- V37__deal_checklists.sql
--
-- Closing a flat sale means collecting things — ID copies, a bank pre-approval,
-- the deposit agreement, the title extract, the signed contract — and until now
-- the list lived in the agent's head. An agency now keeps a checklist template
-- per stage, and every deal carries its own copy to tick off.
--
-- checklist_template_items   the agency's list. ON DELETE CASCADE with the team:
--                            it is the agency's way of working, nothing else's.
--   stage       the stage an item belongs to: LEAD, NEGOTIATION or CLOSED_WON.
--               A lost deal has nothing left to collect, so it has no stage here.
--   title       the agency's own words, in the agency's language. There is no
--               translation table: a template is typed by a manager, and the
--               default one is written once, in the language of the manager who
--               first opens it (Russian when that is not known).
--   position    order inside the stage, 0-based.
--   required    what the app warns about when a deal moves on without it.
--
-- teams.checklist_template_seeded  whether the default template has been
--               written for this agency. Agencies that exist today get it on
--               first read. The flag, not "has no rows", is what says so: a
--               manager may empty the template on purpose.
--
-- deal_checklist_items       the deal's copy, made when the deal is created — or
--                            on first read for deals that are older than this
--                            migration. Editing the template later does not
--                            rewrite deals already under way.
--   deal_id     ON DELETE CASCADE: a checklist means nothing without its deal.
--   team_id     always the deal's team, like every other business record (V15).
--   custom      added on this deal rather than copied from the template; only
--               these can be deleted.
--   done_at / done_by  when and by whom it was ticked; done_by ON DELETE SET NULL
--               so closing an account keeps the tick and forgets the person.
--   document_id the deal's document that proves it, ON DELETE SET NULL: deleting
--               the file un-links it and leaves the tick alone.

ALTER TABLE teams
    ADD COLUMN checklist_template_seeded BOOLEAN NOT NULL DEFAULT FALSE;

CREATE TABLE checklist_template_items (
    id        BIGSERIAL     PRIMARY KEY,
    team_id   BIGINT        NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    stage     VARCHAR(16)   NOT NULL,
    title     VARCHAR(200)  NOT NULL,
    position  INTEGER       NOT NULL,
    required  BOOLEAN       NOT NULL DEFAULT FALSE,
    CONSTRAINT chk_checklist_template_items_stage
        CHECK (stage IN ('LEAD', 'NEGOTIATION', 'CLOSED_WON'))
);

CREATE INDEX idx_checklist_template_items_team ON checklist_template_items(team_id, stage, position);

CREATE TABLE deal_checklist_items (
    id           BIGSERIAL     PRIMARY KEY,
    deal_id      BIGINT        NOT NULL REFERENCES deals(id) ON DELETE CASCADE,
    team_id      BIGINT        REFERENCES teams(id),
    stage        VARCHAR(16)   NOT NULL,
    title        VARCHAR(200)  NOT NULL,
    position     INTEGER       NOT NULL,
    required     BOOLEAN       NOT NULL DEFAULT FALSE,
    custom       BOOLEAN       NOT NULL DEFAULT FALSE,
    done_at      TIMESTAMP,
    done_by      BIGINT        REFERENCES users(id) ON DELETE SET NULL,
    document_id  BIGINT        REFERENCES documents(id) ON DELETE SET NULL,
    CONSTRAINT chk_deal_checklist_items_stage
        CHECK (stage IN ('LEAD', 'NEGOTIATION', 'CLOSED_WON'))
);

-- Every read is "this deal's checklist, in order"; the deal list counts it per deal.
CREATE INDEX idx_deal_checklist_items_deal ON deal_checklist_items(deal_id, stage, position);

-- Found and cleared by the SET NULLs above.
CREATE INDEX idx_deal_checklist_items_done_by ON deal_checklist_items(done_by);
CREATE INDEX idx_deal_checklist_items_document ON deal_checklist_items(document_id);
