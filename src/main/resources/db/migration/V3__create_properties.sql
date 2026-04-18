-- V3__create_properties.sql
CREATE TABLE properties (
    id            BIGSERIAL PRIMARY KEY,
    title         VARCHAR(255)   NOT NULL,
    description   TEXT,
    address       VARCHAR(500)   NOT NULL,
    city          VARCHAR(100),
    type          VARCHAR(30)    NOT NULL,   -- APARTMENT, HOUSE, COMMERCIAL...
    status        VARCHAR(20)    NOT NULL DEFAULT 'AVAILABLE',
    price         NUMERIC(15, 2) NOT NULL,
    area_sqm      DOUBLE PRECISION,
    rooms         INTEGER,
    floor         INTEGER,
    total_floors  INTEGER,
    agent_id      BIGINT REFERENCES users(id) ON DELETE SET NULL,
    created_at    TIMESTAMP      NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMP      NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_properties_agent  ON properties(agent_id);
CREATE INDEX idx_properties_status ON properties(status);
CREATE INDEX idx_properties_type   ON properties(type);
CREATE INDEX idx_properties_city   ON properties(city);