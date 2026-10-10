-- V56__signup_without_code.sql
--
-- Sign-up no longer asks for a code by email. The host cannot be relied on to send
-- one, and an account that waits on a code that never arrives is one its owner can
-- neither confirm nor sign into. A new account is ACTIVE the moment it is created.
--
-- Accounts still waiting on a code are let in on the same terms, and the columns
-- that held the code go.

UPDATE users SET status = 'ACTIVE' WHERE status = 'PENDING_VERIFICATION';

ALTER TABLE users
    DROP COLUMN email_verification_code_hash,
    DROP COLUMN email_verification_expires_at,
    DROP COLUMN email_verification_sent_at,
    DROP COLUMN email_verification_attempts;
