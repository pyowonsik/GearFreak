BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "chat_message" (
    "id" bigserial PRIMARY KEY,
    "chatRoomId" bigint NOT NULL,
    "senderId" bigint NOT NULL,
    "content" text NOT NULL,
    "messageType" bigint NOT NULL,
    "attachmentUrl" text,
    "attachmentName" text,
    "attachmentSize" bigint,
    "createdAt" timestamp without time zone,
    "updatedAt" timestamp without time zone
);

-- Indexes
CREATE INDEX "chat_room_messages_idx" ON "chat_message" USING btree ("chatRoomId", "createdAt");
CREATE INDEX "sender_messages_idx" ON "chat_message" USING btree ("senderId", "createdAt");
CREATE INDEX "message_type_idx" ON "chat_message" USING btree ("messageType");

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
    "createdAt" timestamp without time zone,
    "updatedAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "unique_chat_participant_idx" ON "chat_participant" USING btree ("chatRoomId", "userId");
CREATE INDEX "active_participants_idx" ON "chat_participant" USING btree ("chatRoomId", "isActive");
CREATE INDEX "user_participations_idx" ON "chat_participant" USING btree ("userId", "isActive");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "chat_room" (
    "id" bigserial PRIMARY KEY,
    "productId" bigint NOT NULL,
    "title" text,
    "chatRoomType" bigint NOT NULL,
    "participantCount" bigint NOT NULL,
    "lastActivityAt" timestamp without time zone,
    "createdAt" timestamp without time zone,
    "updatedAt" timestamp without time zone
);

-- Indexes
CREATE INDEX "product_id_idx" ON "chat_room" USING btree ("productId");
CREATE INDEX "last_activity_idx" ON "chat_room" USING btree ("lastActivityAt");
CREATE INDEX "chat_room_type_idx" ON "chat_room" USING btree ("chatRoomType");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "chat_message"
    ADD CONSTRAINT "chat_message_fk_0"
    FOREIGN KEY("chatRoomId")
    REFERENCES "chat_room"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

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
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "chat_room"
    ADD CONSTRAINT "chat_room_fk_0"
    FOREIGN KEY("productId")
    REFERENCES "product"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR gear_freak
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('gear_freak', '20251203063822524', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251203063822524', "timestamp" = now();

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
