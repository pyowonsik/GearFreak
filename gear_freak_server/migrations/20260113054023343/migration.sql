BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "product" ADD COLUMN "lastBumpedAt" timestamp without time zone;
CREATE INDEX "last_bumped_at_idx" ON "product" USING btree ("lastBumpedAt");

--
-- MIGRATION VERSION FOR gear_freak
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('gear_freak', '20260113054023343', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260113054023343', "timestamp" = now();

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
