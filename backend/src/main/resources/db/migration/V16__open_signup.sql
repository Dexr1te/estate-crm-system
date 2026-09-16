-- V16__open_signup.sql
--
-- Anyone can now open an account: a manager starts an agency, an agent waits to be
-- added to one. Two things that needs.

-- 1. Proving the address -----------------------------------------------------------
--
-- A new account stays PENDING_VERIFICATION until its owner types the six-digit code
-- mailed to them. The code is stored hashed, expires, and only survives a few wrong
-- guesses before a fresh one has to be sent.

ALTER TABLE users
    ADD COLUMN email_verification_code_hash  VARCHAR(255),
    ADD COLUMN email_verification_expires_at TIMESTAMP,
    ADD COLUMN email_verification_sent_at    TIMESTAMP,
    ADD COLUMN email_verification_attempts   INTEGER NOT NULL DEFAULT 0;

-- 2. Joining an agency -------------------------------------------------------------
--
-- A manager cannot simply pull an existing account into their team: that account's
-- owner would find their work visible to a stranger. The manager sends a request,
-- and the agent accepts it or not.

CREATE TABLE team_join_requests (
    id            BIGSERIAL PRIMARY KEY,
    team_id       BIGINT      NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    user_id       BIGINT      NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    invited_by    BIGINT      REFERENCES users(id) ON DELETE SET NULL,
    status        VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    created_at    TIMESTAMP   NOT NULL DEFAULT NOW(),
    responded_at  TIMESTAMP
);

CREATE INDEX idx_team_join_requests_user ON team_join_requests(user_id, status);
CREATE INDEX idx_team_join_requests_team ON team_join_requests(team_id, status);

-- One open request per person per team; answered ones are history and may repeat.
CREATE UNIQUE INDEX uq_team_join_requests_pending
    ON team_join_requests(team_id, user_id)
    WHERE status = 'PENDING';
