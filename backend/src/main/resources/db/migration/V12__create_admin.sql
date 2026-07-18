-- V12__create_admin.sql
--
-- Seeds a second ADMIN account with a known password, ACTIVE and ready to log in.
-- Idempotent upsert (email is UNIQUE): creates the row if missing, or normalizes
-- an existing row to ADMIN / ACTIVE with the known password.
--
--   email:    admin@gmail.com
--   password: admin123   (bcrypt $2a$10$, verified against BCryptPasswordEncoder)
--
-- Change this password after first login.

INSERT INTO users (email, password, full_name, phone, role, is_active,
                   status, must_change_password, data_scope, created_at, updated_at)
VALUES (
    'admin@gmail.com',
    '$2a$10$BvpOdBr7QO4qL834ePExzuARllcAf4v8uaDpu85s8fErTaPIvBTJq',
    'Admin',
    NULL,
    'ADMIN',
    TRUE,
    'ACTIVE',
    FALSE,
    'ALL',
    NOW(),
    NOW()
)
ON CONFLICT (email) DO UPDATE
SET role                 = 'ADMIN',
    status               = 'ACTIVE',
    is_active            = TRUE,
    must_change_password = FALSE,
    data_scope           = 'ALL',
    password             = EXCLUDED.password,
    updated_at           = NOW();
