BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "product_report" (
    "id" bigserial PRIMARY KEY,
    "productId" bigint NOT NULL,
    "reporterId" bigint NOT NULL,
    "reason" bigint NOT NULL,
    "description" text,
    "status" bigint NOT NULL,
    "processedBy" bigint,
    "processedAt" timestamp without time zone,
    "processNote" text,
    "createdAt" timestamp without time zone,
    "updatedAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "unique_product_reporter_idx" ON "product_report" USING btree ("productId", "reporterId");
CREATE INDEX "product_reports_idx" ON "product_report" USING btree ("productId", "createdAt");
CREATE INDEX "reporter_reports_idx" ON "product_report" USING btree ("reporterId", "createdAt");
CREATE INDEX "status_idx" ON "product_report" USING btree ("status", "createdAt");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "product_report"
    ADD CONSTRAINT "product_report_fk_0"
    FOREIGN KEY("productId")
    REFERENCES "product"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "product_report"
    ADD CONSTRAINT "product_report_fk_1"
    FOREIGN KEY("reporterId")
    REFERENCES "user"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "product_report"
    ADD CONSTRAINT "product_report_fk_2"
    FOREIGN KEY("processedBy")
    REFERENCES "user"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR gear_freak
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('gear_freak', '20251229081709294', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251229081709294', "timestamp" = now();

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
