-- V11__activate_seed_admin.sql
--
-- Guarantees a usable ADMIN login exists after deploy.
--
-- Two problems this fixes:
--   1. The seed admin from V8 was inserted BEFORE the `status` column existed.
--      V10 added `status NOT NULL DEFAULT 'PENDING_INVITE'`, so the seed row was
--      backfilled to PENDING_INVITE. Login enablement (User.isEnabled()) requires
--      `is_active = true AND status = 'ACTIVE'`, so the seed admin could never log
--      in -- locking everyone out (only a logged-in admin can invite others).
--   2. If the seed admin row was manually deleted, a plain UPDATE would match zero
--      rows and silently leave the system with no admin at all.
--
-- Using INSERT ... ON CONFLICT (email) makes this self-healing and idempotent:
--   - row missing  -> it is (re)created, ACTIVE, with a known password
--   - row present  -> it is normalized to ADMIN / ACTIVE with the known password
--
--   email:    mainadmin@gmail.com
--   password: Admin123456   (bcrypt $2a$10$, verified against BCryptPasswordEncoder)
--
-- Change this password after first login.

INSERT INTO users (email, password, full_name, phone, role, is_active,
                   status, must_change_password, data_scope, created_at, updated_at)
VALUES (
    'mainadmin@gmail.com',
    '$2a$10$VfIOaOoxQ/YtASHnjIQuJOsCqqqeYUQ4OMixrYsk17/2JtSPy4QhC',
    'Main Admin',
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
