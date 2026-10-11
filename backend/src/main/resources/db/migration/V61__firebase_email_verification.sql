-- V61__firebase_email_verification.sql
--
-- Sign-up proves the address again, this time through Firebase: the app asks Firebase
-- to email a link, and the account stays PENDING_VERIFICATION until it is opened.
-- Firebase sends the mail because this host cannot.
--
-- The column ties an account to the Firebase user that carries its address. Nothing
-- else lives in Firebase: passwords and sessions stay here, and accounts made before
-- this (all ACTIVE since V60) never get one.

ALTER TABLE users ADD COLUMN firebase_uid VARCHAR(128);

CREATE UNIQUE INDEX uq_users_firebase_uid ON users(firebase_uid) WHERE firebase_uid IS NOT NULL;
