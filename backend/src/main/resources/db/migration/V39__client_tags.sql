-- V39__client_tags.sql
--
-- Short labels an agent puts on a client — "investor", "urgent", "VIP" — to find
-- them again. Free-form, but one vocabulary per agency, so that "vip" typed by one
-- agent and "VIP" typed by another are the same tag.
--
-- client_tags          the agency's vocabulary. ON DELETE CASCADE with the team:
--                      the words are the agency's and nobody else's.
--   name               how the tag is shown: trimmed, inner spaces collapsed, in the
--                      casing of whoever used it first in the agency. At most 32
--                      characters (ClientTags.MAX_LENGTH); the column has room to spare.
--   name_key           the name without case — what "the same tag" means. Unique
--                      per agency. A team-less record's tags have a NULL team_id,
--                      which the unique index does not constrain; the application
--                      looks them up by (NULL, key) itself.
--   A tag no client carries any more is deleted, so the next person to type it
--   chooses its casing again.
--
-- client_tag_links     which client carries which tag; at most 10 per client
--                      (ClientTags.MAX_PER_CLIENT). Both sides ON DELETE CASCADE:
--                      a link means nothing without its client or its tag.

CREATE TABLE client_tags (
    id          BIGSERIAL    PRIMARY KEY,
    team_id     BIGINT       REFERENCES teams(id) ON DELETE CASCADE,
    name        VARCHAR(64)  NOT NULL,
    name_key    VARCHAR(64)  NOT NULL,
    created_at  TIMESTAMP    NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX uq_client_tags_team_key ON client_tags(team_id, name_key);

CREATE TABLE client_tag_links (
    client_id  BIGINT  NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    tag_id     BIGINT  NOT NULL REFERENCES client_tags(id) ON DELETE CASCADE,
    PRIMARY KEY (client_id, tag_id)
);

-- "Clients with this tag" and "how many carry it" both start from the tag.
CREATE INDEX idx_client_tag_links_tag ON client_tag_links(tag_id);
