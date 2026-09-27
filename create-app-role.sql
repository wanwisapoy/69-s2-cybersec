-- Apply to an EXISTING database (this repo's live deploy).
-- Creates the dedicated least-privilege app role if missing and grants
-- the privileges Strapi needs. Run as superuser against the DB:
--   psql -U "PostgreSQL" -d postgres -f scripts/create-app-role.sql
-- with :APP_DB_USER / :APP_DB_PASSWORD substituted, or edit them below.
--
-- SECURITY: log_statement=mod logs every DDL, so a CREATE/ALTER ROLE
-- ... PASSWORD would print the plaintext password to the server log.
-- This session disables statement logging while the role/password is set
-- and restores it afterwards. Requires superuser (a plain role cannot SET
-- log_statement).

\set role_name 'app_user'
\set role_password 'REPLACE_ME'
\set db_name 'cybersec'

SET log_statement = 'none';
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = :'role_name') THEN
        EXECUTE format('CREATE ROLE %I LOGIN PASSWORD %L', :'role_name', :'role_password');
    ELSE
        EXECUTE format('ALTER ROLE %I WITH LOGIN PASSWORD %L', :'role_name', :'role_password');
    END IF;
END
$$;
SET log_statement = 'mod';

GRANT CONNECT ON DATABASE :db_name TO :role_name;
GRANT USAGE, CREATE ON SCHEMA public TO :role_name;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO :role_name;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO :role_name;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO :role_name;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO :role_name;

\echo 'App role created/updated. Set DATABASE_USERNAME/APP_DB_USER and DATABASE_PASSWORD/APP_DB_PASSWORD in .env to match.'