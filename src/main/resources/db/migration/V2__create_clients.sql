-- V2__create_clients.sql
CREATE TABLE clients (
    id          BIGSERIAL PRIMARY KEY,
    full_name   VARCHAR(255) NOT NULL,
    email       VARCHAR(255) UNIQUE,
    phone       VARCHAR(50),
    type        VARCHAR(20)  NOT NULL,   -- BUYER / SELLER
    notes       TEXT,
    agent_id    BIGINT REFERENCES users(id) ON DELETE SET NULL,
    created_at  TIMESTAMP    NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP    NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_clients_agent ON clients(agent_id);
CREATE INDEX idx_clients_type  ON clients(type);