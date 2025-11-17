BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "user" (
    "id" bigserial PRIMARY KEY,
    "userInfoId" bigint NOT NULL,
    "nickname" text,
    "bio" text,
    "withdrawalDate" timestamp without time zone,
    "blockedReason" text,
    "blockedAt" timestamp without time zone,
    "lastLoginAt" timestamp without time zone,
    "createdAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "user_info_id_unique_idx" ON "user" USING btree ("userInfoId");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "user"
    ADD CONSTRAINT "user_fk_0"
    FOREIGN KEY("userInfoId")
    REFERENCES "serverpod_user_info"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR gear_freak
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('gear_freak', '20251115080615952', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251115080615952', "timestamp" = now();

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
