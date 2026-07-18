-- V11__activate_seed_admin.sql
--
-- The seed admin created in V8 was inserted BEFORE the `status` column existed.
-- V10 later added `status VARCHAR(20) NOT NULL DEFAULT 'PENDING_INVITE'`, so the
-- existing seed row was backfilled to PENDING_INVITE. Because login enablement
-- (User.isEnabled()) requires `is_active = true AND status = 'ACTIVE'`, the seed
-- admin could never log in — locking everyone out (only a logged-in admin can
-- invite other users).
--
-- This migration activates the seed admin and sets a known password so the app
-- is usable after deploy. Change this password after first login.
--
--   email:    mainadmin@gmail.com
--   password: Admin123456   (bcrypt $2a$10$, verified against BCryptPasswordEncoder)

UPDATE users
SET status               = 'ACTIVE',
    is_active            = TRUE,
    must_change_password = FALSE,
    password             = '$2a$10$VfIOaOoxQ/YtASHnjIQuJOsCqqqeYUQ4OMixrYsk17/2JtSPy4QhC',
    updated_at           = NOW()
WHERE email = 'mainadmin@gmail.com';
