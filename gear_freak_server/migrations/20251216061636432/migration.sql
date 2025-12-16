BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "transaction_review" (
    "id" bigserial PRIMARY KEY,
    "productId" bigint NOT NULL,
    "chatRoomId" bigint NOT NULL,
    "reviewerId" bigint NOT NULL,
    "revieweeId" bigint NOT NULL,
    "rating" bigint NOT NULL,
    "content" text,
    "reviewType" bigint NOT NULL,
    "createdAt" timestamp without time zone,
    "updatedAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "unique_review_idx" ON "transaction_review" USING btree ("productId", "chatRoomId", "reviewerId", "reviewType");
CREATE INDEX "product_reviews_idx" ON "transaction_review" USING btree ("productId");
CREATE INDEX "reviewee_reviews_idx" ON "transaction_review" USING btree ("revieweeId");
CREATE INDEX "reviewer_reviews_idx" ON "transaction_review" USING btree ("reviewerId");
CREATE INDEX "review_created_at_idx" ON "transaction_review" USING btree ("createdAt");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "transaction_review"
    ADD CONSTRAINT "transaction_review_fk_0"
    FOREIGN KEY("productId")
    REFERENCES "product"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "transaction_review"
    ADD CONSTRAINT "transaction_review_fk_1"
    FOREIGN KEY("chatRoomId")
    REFERENCES "chat_room"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "transaction_review"
    ADD CONSTRAINT "transaction_review_fk_2"
    FOREIGN KEY("reviewerId")
    REFERENCES "user"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "transaction_review"
    ADD CONSTRAINT "transaction_review_fk_3"
    FOREIGN KEY("revieweeId")
    REFERENCES "user"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR gear_freak
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('gear_freak', '20251216061636432', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251216061636432', "timestamp" = now();

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
