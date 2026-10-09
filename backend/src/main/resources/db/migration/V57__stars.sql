-- V57__stars.sql
--
-- Starred records: the clients, listings and deals somebody is working on
-- right now, one tap away. A star is personal: it is one person's, follows
-- them from phone to phone, and nobody else sees it.
--
-- stars                   one row per person per starred record.
--   user_id      whose star. ON DELETE CASCADE: a star means nothing once
--                the account is gone.
--   entity_type  CLIENT, PROPERTY or DEAL.
--   entity_id    the record. No foreign key, as it points into one of three
--                tables: the service removes a record's stars in the same
--                transaction that deletes it, and moves a merged client's
--                stars to the card that stays. What is read keeps to what
--                the person may still see, so a record that leaves their
--                agency or their data scope drops out of the list without
--                the star being touched, and comes back if the record does.
--   created_at   when it was starred; the list is newest first.
--
-- Starring the same record twice is still one star (uq_stars_user_entity),
-- which is what lets the API answer a repeated star with the same row.

CREATE TABLE stars (
    id           BIGSERIAL     PRIMARY KEY,
    user_id      BIGINT        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    entity_type  VARCHAR(10)   NOT NULL,
    entity_id    BIGINT        NOT NULL,
    created_at   TIMESTAMP     NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_stars_entity_type CHECK (entity_type IN ('CLIENT', 'PROPERTY', 'DEAL')),
    CONSTRAINT uq_stars_user_entity UNIQUE (user_id, entity_type, entity_id)
);

-- One person's stars come off the unique index's leading column. A deleted
-- record's stars, everybody's, are found by the record.
CREATE INDEX idx_stars_entity ON stars(entity_type, entity_id);
