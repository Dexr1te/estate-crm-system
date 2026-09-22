-- V22__property_photos.sql
--
-- Photographs of a listing. A CRM for estate agents held none: a flat was a
-- title, an address and a price, and the one thing every buyer asks to see
-- first was not in the system at all.
--
-- Only the key is kept here. The bytes live wherever app.documents.storage
-- points, the same as a deal's paperwork — which for photographs should be a
-- bucket rather than the database.
--
-- ON DELETE CASCADE: unlike a viewing, a photograph of a flat has no meaning
-- once the flat is gone.

CREATE TABLE property_photos (
    id           BIGSERIAL PRIMARY KEY,
    property_id  BIGINT       NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
    storage_key  VARCHAR(500) NOT NULL,
    file_name    VARCHAR(255) NOT NULL,
    content_type VARCHAR(100) NOT NULL,
    file_size    BIGINT       NOT NULL,
    sort_order   INTEGER      NOT NULL DEFAULT 0,
    uploaded_by  BIGINT REFERENCES users(id) ON DELETE SET NULL,
    uploaded_at  TIMESTAMP    NOT NULL DEFAULT NOW()
);

-- Every read is "the photos of this listing, in the order they are shown".
CREATE INDEX idx_property_photos_property ON property_photos(property_id, sort_order);
