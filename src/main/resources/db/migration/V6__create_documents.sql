-- V6__create_documents.sql
CREATE TABLE documents (
    id           BIGSERIAL PRIMARY KEY,
    file_name    VARCHAR(255) NOT NULL,
    file_type    VARCHAR(50)  NOT NULL,
    file_size    BIGINT       NOT NULL,
    file_path    VARCHAR(500) NOT NULL,
    deal_id      BIGINT NOT NULL REFERENCES deals(id) ON DELETE CASCADE,
    uploaded_by  BIGINT NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    uploaded_at  TIMESTAMP    NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_documents_deal ON documents(deal_id);