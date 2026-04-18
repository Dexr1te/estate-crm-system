-- V4__create_deals.sql
CREATE TABLE deals (
    id           BIGSERIAL PRIMARY KEY,
    title        VARCHAR(255)   NOT NULL,
    status       VARCHAR(20)    NOT NULL DEFAULT 'LEAD',
    deal_price   NUMERIC(15, 2),
    notes        TEXT,
    client_id    BIGINT NOT NULL REFERENCES clients(id)    ON DELETE RESTRICT,
    property_id  BIGINT NOT NULL REFERENCES properties(id) ON DELETE RESTRICT,
    agent_id     BIGINT NOT NULL REFERENCES users(id)      ON DELETE RESTRICT,
    created_at   TIMESTAMP      NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMP      NOT NULL DEFAULT NOW(),
    closed_at    TIMESTAMP
);

CREATE INDEX idx_deals_status   ON deals(status);
CREATE INDEX idx_deals_agent    ON deals(agent_id);
CREATE INDEX idx_deals_client   ON deals(client_id);
CREATE INDEX idx_deals_property ON deals(property_id);