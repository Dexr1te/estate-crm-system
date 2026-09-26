-- V31__listing_share_links.sql
--
-- A link to a listing that a client can open in any browser, without an
-- account. Photos forwarded in a chat get separated from the flat they show,
-- and a PDF is heavy; one link carries the whole listing.
--
-- A table of its own rather than a token column on properties: a revoked link
-- has to stay dead, so its token is kept (revoked_at set) instead of being
-- overwritten, and the view counter belongs to the link — a new link starts
-- at zero, which is what "how many opened what I sent" means.
--
-- token           >= 128 random bits, base64url. The only thing the public
--                 page is looked up by; ids are never in a public URL.
-- property_id     a link means nothing once the flat is gone: CASCADE.
-- created_by      history, not a dependency: SET NULL, like tasks (V27).
-- revoked_at      null while the link works.
-- view_count,     how often the page was opened, and when last. Photos
-- last_viewed_at  fetched by the page do not count.

CREATE TABLE property_share_links (
    id              BIGSERIAL    PRIMARY KEY,
    token           VARCHAR(64)  NOT NULL UNIQUE,
    property_id     BIGINT       NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
    created_by      BIGINT       REFERENCES users(id) ON DELETE SET NULL,
    created_at      TIMESTAMP    NOT NULL DEFAULT NOW(),
    revoked_at      TIMESTAMP,
    view_count      BIGINT       NOT NULL DEFAULT 0,
    last_viewed_at  TIMESTAMP
);

-- At most one working link per listing; "create" returns it rather than
-- minting a second one.
CREATE UNIQUE INDEX uq_property_share_links_active
    ON property_share_links(property_id) WHERE revoked_at IS NULL;
