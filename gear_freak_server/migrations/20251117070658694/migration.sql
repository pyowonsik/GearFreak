BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "product" (
    "id" bigserial PRIMARY KEY,
    "sellerId" bigint NOT NULL,
    "title" text NOT NULL,
    "category" bigint NOT NULL,
    "price" bigint NOT NULL,
    "condition" bigint NOT NULL,
    "description" text NOT NULL,
    "tradeMethod" bigint NOT NULL,
    "baseAddress" text,
    "detailAddress" text,
    "imageUrls" json,
    "viewCount" bigint,
    "favoriteCount" bigint,
    "chatCount" bigint,
    "createdAt" timestamp without time zone,
    "updatedAt" timestamp without time zone
);

-- Indexes
CREATE INDEX "seller_id_idx" ON "product" USING btree ("sellerId");
CREATE INDEX "category_idx" ON "product" USING btree ("category");
CREATE INDEX "created_at_idx" ON "product" USING btree ("createdAt");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "product"
    ADD CONSTRAINT "product_fk_0"
    FOREIGN KEY("sellerId")
    REFERENCES "user"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR gear_freak
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('gear_freak', '20251117070658694', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251117070658694', "timestamp" = now();

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
