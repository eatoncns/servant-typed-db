-- Verify servant-typed-db:users on pg

BEGIN;

SELECT id, first_name, last_name FROM users WHERE FALSE;

ROLLBACK;
