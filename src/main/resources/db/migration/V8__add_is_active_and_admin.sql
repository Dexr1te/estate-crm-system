-- V8__add_is_active_and_admin.sql

-- 1. Add isActive column to users table
ALTER TABLE users ADD COLUMN is_active BOOLEAN NOT NULL DEFAULT TRUE;

-- 2. create first admin
INSERT INTO users (email, password, full_name, phone, role, is_active, created_at, updated_at)
VALUES (
    'mainadmin@gmail.com',
    '$2a$10$O0u7HuVg2eq9qnG25eo2Q.AzjGRlgYn43x1fmw5Ohx5N2GWx94dhm',
    'Main Admin',
    NULL,
    'ADMIN',
    TRUE,
    NOW(),
    NOW()
);