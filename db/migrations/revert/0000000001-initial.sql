START TRANSACTION;

DROP SCHEMA api CASCADE;

DROP SCHEMA auth CASCADE;

DROP SCHEMA "data" CASCADE;

DROP SCHEMA pgjwt CASCADE;

DROP SCHEMA rabbitmq CASCADE;

DROP SCHEMA request CASCADE;

DROP SCHEMA settings CASCADE;

DROP EXTENSION plpgsql CASCADE;

DROP EXTENSION pgcrypto CASCADE;

COMMIT TRANSACTION;