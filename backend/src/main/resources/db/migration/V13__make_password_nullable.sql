-- V13__make_password_nullable.sql
--
-- Invited users are created WITHOUT a password (status PENDING_INVITE) and only
-- set one later via /auth/accept-invite. But the `password` column was NOT NULL
-- (from V1), so every invite INSERT failed with a not-null violation -> the
-- invite endpoint always returned 400 and no invited user could ever be created.
--
-- Allow NULL passwords so pending invites can be stored. A user cannot log in
-- while password is null anyway (status must be ACTIVE and BCrypt rejects null).

ALTER TABLE users ALTER COLUMN password DROP NOT NULL;
