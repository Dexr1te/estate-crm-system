-- V17__document_blobs.sql
--
-- The bytes of a deal document used to live only on the container's
-- filesystem. That was true when this ran on a VM with a mounted volume; on a
-- host that rebuilds the container on every deploy and every wake from sleep,
-- the paperwork is gone by the time anyone asks for it, while the row that
-- describes it stays behind.
--
-- The bytes move into the database. `documents.file_path` keeps the same
-- `<dealId>/<uuid>.<ext>` key it always held, so nothing about the existing
-- rows changes — only where that key is looked up.

CREATE TABLE document_blobs (
    storage_key VARCHAR(500) PRIMARY KEY,
    content     BYTEA        NOT NULL,
    created_at  TIMESTAMP    NOT NULL DEFAULT NOW()
);
