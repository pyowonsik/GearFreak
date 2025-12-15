BEGIN;

--
-- ACTION DROP TABLE
--
DROP TABLE "chat_participant" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "chat_participant" (
    "id" bigserial PRIMARY KEY,
    "chatRoomId" bigint NOT NULL,
    "userId" bigint NOT NULL,
    "joinedAt" timestamp without time zone,
    "isActive" boolean NOT NULL,
    "leftAt" timestamp without time zone,
    "lastReadAt" timestamp without time zone,
    "isNotificationEnabled" boolean NOT NULL,
    "createdAt" timestamp without time zone,
    "updatedAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "unique_chat_participant_idx" ON "chat_participant" USING btree ("chatRoomId", "userId");
CREATE INDEX "active_participants_idx" ON "chat_participant" USING btree ("chatRoomId", "isActive");
CREATE INDEX "user_participations_idx" ON "chat_participant" USING btree ("userId", "isActive");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "chat_participant"
    ADD CONSTRAINT "chat_participant_fk_0"
    FOREIGN KEY("chatRoomId")
    REFERENCES "chat_room"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "chat_participant"
    ADD CONSTRAINT "chat_participant_fk_1"
    FOREIGN KEY("userId")
    REFERENCES "user"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR gear_freak
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('gear_freak', '20251215065421459', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251215065421459', "timestamp" = now();

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
