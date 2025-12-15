BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "fcm_token" (
    "id" bigserial PRIMARY KEY,
    "userId" bigint NOT NULL,
    "token" text NOT NULL,
    "deviceType" text,
    "updatedAt" timestamp without time zone,
    "createdAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "user_id_token_unique_idx" ON "fcm_token" USING btree ("userId", "token");
CREATE INDEX "user_id_idx" ON "fcm_token" USING btree ("userId");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "fcm_token"
    ADD CONSTRAINT "fcm_token_fk_0"
    FOREIGN KEY("userId")
    REFERENCES "user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR gear_freak
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('gear_freak', '20251212080736591', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251212080736591', "timestamp" = now();

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
