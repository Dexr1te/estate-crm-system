-- V5__create_meetings.sql
CREATE TABLE meetings (
    id            BIGSERIAL PRIMARY KEY,
    title         VARCHAR(255) NOT NULL,
    description   TEXT,
    scheduled_at  TIMESTAMP    NOT NULL,
    location      VARCHAR(500),
    completed     BOOLEAN      NOT NULL DEFAULT FALSE,
    deal_id       BIGINT REFERENCES deals(id)   ON DELETE SET NULL,
    agent_id      BIGINT NOT NULL REFERENCES users(id)   ON DELETE RESTRICT,
    client_id     BIGINT NOT NULL REFERENCES clients(id) ON DELETE RESTRICT,
    created_at    TIMESTAMP    NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMP    NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_meetings_agent       ON meetings(agent_id);
CREATE INDEX idx_meetings_client      ON meetings(client_id);
CREATE INDEX idx_meetings_deal        ON meetings(deal_id);
CREATE INDEX idx_meetings_scheduled   ON meetings(scheduled_at);