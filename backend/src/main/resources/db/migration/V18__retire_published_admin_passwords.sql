-- V18__retire_published_admin_passwords.sql
--
-- V8, V11 and V12 each seeded an ADMIN account with its password written into
-- the migration, on DATA_SCOPE 'ALL' — every agency's clients, deals and phone
-- numbers, behind a password that ships with the repository. Anyone who can
-- read this file can read the whole database of any deployment that ran it.
--
-- Both rows lose that password here. The account that stays is repaired at boot
-- by AdminAccountBootstrap from ADMIN_PASSWORD, so the credential lives with
-- whoever runs the host instead of in the history of this repository.
--
-- The WHERE clauses match only the published hashes. An administrator who has
-- already changed their password owns that row, and it is left untouched.

-- The account this deployment keeps. Its password is set at the next boot.
UPDATE users
   SET password             = NULL,
       must_change_password = TRUE,
       updated_at           = NOW()
 WHERE email = 'admin@gmail.com'
   AND password = '$2a$10$BvpOdBr7QO4qL834ePExzuARllcAf4v8uaDpu85s8fErTaPIvBTJq';

-- The second seed. Deactivated rather than deleted: it may own clients, deals
-- or audit history, and a DELETE would either fail on those references or take
-- the records with it. With no password and DEACTIVATED it cannot sign in, and
-- the admin console can remove it properly once its records are handed on.
UPDATE users
   SET password             = NULL,
       is_active            = FALSE,
       status               = 'DEACTIVATED',
       updated_at           = NOW()
 WHERE email = 'mainadmin@gmail.com'
   AND password IN (
       '$2a$10$VfIOaOoxQ/YtASHnjIQuJOsCqqqeYUQ4OMixrYsk17/2JtSPy4QhC',
       '$2a$10$O0u7HuVg2eq9qnG25eo2Q.AzjGRlgYn43x1fmw5Ohx5N2GWx94dhm');
