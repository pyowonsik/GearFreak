BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "favorite" (
    "id" bigserial PRIMARY KEY,
    "userId" bigint NOT NULL,
    "productId" bigint NOT NULL,
    "createdAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "user_product_unique_idx" ON "favorite" USING btree ("userId", "productId");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "favorite"
    ADD CONSTRAINT "favorite_fk_0"
    FOREIGN KEY("userId")
    REFERENCES "user"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "favorite"
    ADD CONSTRAINT "favorite_fk_1"
    FOREIGN KEY("productId")
    REFERENCES "product"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR gear_freak
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('gear_freak', '20251119133110343', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251119133110343', "timestamp" = now();

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
