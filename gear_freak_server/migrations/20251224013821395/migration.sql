BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "product_view" (
    "id" bigserial PRIMARY KEY,
    "userId" bigint NOT NULL,
    "productId" bigint NOT NULL,
    "viewedAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "product_view_user_product_unique_idx" ON "product_view" USING btree ("userId", "productId");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "product_view"
    ADD CONSTRAINT "product_view_fk_0"
    FOREIGN KEY("userId")
    REFERENCES "user"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "product_view"
    ADD CONSTRAINT "product_view_fk_1"
    FOREIGN KEY("productId")
    REFERENCES "product"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR gear_freak
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('gear_freak', '20251224013821395', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251224013821395', "timestamp" = now();

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
