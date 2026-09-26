-- V29__client_phone_normalized.sql
--
-- The same buyer is entered twice when two agents type one phone number two ways:
-- "+7 916 220-84-11" and "89162208411". phone_normalized holds the comparable form — digits only,
-- a leading 8 on an 11-digit number read as 7 — so the duplicate check is one indexed lookup.
--
-- The application writes the column on every save (ContactNormalizer.phone); this backfills the
-- rows that already exist with the same rule. Fewer than 7 digits is no phone to match on: NULL.

ALTER TABLE clients ADD COLUMN phone_normalized VARCHAR(50);

UPDATE clients
SET phone_normalized = regexp_replace(phone, '[^0-9]', '', 'g')
WHERE phone IS NOT NULL;

UPDATE clients
SET phone_normalized = '7' || substring(phone_normalized FROM 2)
WHERE length(phone_normalized) = 11 AND phone_normalized LIKE '8%';

UPDATE clients
SET phone_normalized = NULL
WHERE length(phone_normalized) < 7;

CREATE INDEX idx_clients_team_phone_normalized ON clients(team_id, phone_normalized);
