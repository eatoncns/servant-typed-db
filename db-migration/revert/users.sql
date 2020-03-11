-- Revert servant-typed-db:users from pg

BEGIN;

DROP TABLE users;

COMMIT;
