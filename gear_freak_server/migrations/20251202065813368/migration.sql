BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "product" ADD COLUMN "status" bigint;

-- 기존 상품들의 status를 기본값 '판매중' (0)으로 설정
UPDATE "product" SET "status" = 0 WHERE "status" IS NULL;

--
-- MIGRATION VERSION FOR gear_freak
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('gear_freak', '20251202065813368', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251202065813368', "timestamp" = now();

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
