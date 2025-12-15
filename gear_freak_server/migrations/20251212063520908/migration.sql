BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "chat_participant" ADD COLUMN "lastReadAt" timestamp without time zone;
--
-- ACTION ALTER TABLE
--
ALTER TABLE "chat_room" ADD COLUMN "unreadCount" bigint;

--
-- MIGRATION VERSION FOR gear_freak
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('gear_freak', '20251212063520908', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251212063520908', "timestamp" = now();

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
