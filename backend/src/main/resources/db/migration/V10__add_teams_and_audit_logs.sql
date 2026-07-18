-- V10__add_teams_and_audit_logs.sql

-- 1. Create teams table
CREATE TABLE teams (
    id           BIGSERIAL PRIMARY KEY,
    name         VARCHAR(255) NOT NULL UNIQUE,
    manager_id   BIGINT UNIQUE,
    created_at   TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_teams_manager FOREIGN KEY (manager_id) REFERENCES users(id)
);

-- 2. Extend users table with team / scope / invite / reset fields
ALTER TABLE users
    ADD COLUMN data_scope VARCHAR(20) NOT NULL DEFAULT 'OWN',
    ADD COLUMN team_id BIGINT,
    ADD COLUMN status VARCHAR(20) NOT NULL DEFAULT 'PENDING_INVITE',
    ADD COLUMN must_change_password BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN invite_token VARCHAR(255),
    ADD COLUMN invite_token_expires_at TIMESTAMP,
    ADD COLUMN password_reset_token VARCHAR(255),
    ADD COLUMN password_reset_token_expires_at TIMESTAMP,
    ADD COLUMN created_by BIGINT;

ALTER TABLE users
    ADD CONSTRAINT fk_users_team FOREIGN KEY (team_id) REFERENCES teams(id),
    ADD CONSTRAINT fk_users_created_by FOREIGN KEY (created_by) REFERENCES users(id);

-- 3. Create audit log table
CREATE TABLE audit_logs (
    id          BIGSERIAL PRIMARY KEY,
    actor_id    BIGINT NOT NULL,
    action      VARCHAR(255) NOT NULL,
    entity_type VARCHAR(255) NOT NULL,
    entity_id   BIGINT NOT NULL,
    metadata    TEXT,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_audit_log_actor FOREIGN KEY (actor_id) REFERENCES users(id)
);
