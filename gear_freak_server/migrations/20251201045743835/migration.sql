BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "user" ADD COLUMN "profileImageUrl" text;

--
-- MIGRATION VERSION FOR gear_freak
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('gear_freak', '20251201045743835', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251201045743835', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20240516151843329', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240516151843329', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth', '20240520102713718', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240520102713718', "timestamp" = now();


COMMIT;
