BEGIN;

-- 1. Product table
-- status: selling=0, reserved=1, sold=2
ALTER TABLE product ALTER COLUMN status TYPE bigint USING
  CASE status
    WHEN 'selling' THEN 0
    WHEN 'reserved' THEN 1
    WHEN 'sold' THEN 2
    ELSE NULL
  END;

-- category: equipment=0, supplement=1, clothing=2, shoes=3, etc=4
ALTER TABLE product ALTER COLUMN category TYPE bigint USING
  CASE category
    WHEN 'equipment' THEN 0
    WHEN 'supplement' THEN 1
    WHEN 'clothing' THEN 2
    WHEN 'shoes' THEN 3
    WHEN 'etc' THEN 4
    ELSE NULL
  END;

-- condition: brandNew=0, usedExcellent=1, usedGood=2, usedFair=3
ALTER TABLE product ALTER COLUMN condition TYPE bigint USING
  CASE condition
    WHEN 'brandNew' THEN 0
    WHEN 'usedExcellent' THEN 1
    WHEN 'usedGood' THEN 2
    WHEN 'usedFair' THEN 3
    ELSE NULL
  END;

-- tradeMethod: direct=0, delivery=1, both=2
ALTER TABLE product ALTER COLUMN "tradeMethod" TYPE bigint USING
  CASE "tradeMethod"
    WHEN 'direct' THEN 0
    WHEN 'delivery' THEN 1
    WHEN 'both' THEN 2
    ELSE NULL
  END;

-- 2. ChatMessage table
-- messageType: text=0, image=1, file=2, system=3
ALTER TABLE chat_message ALTER COLUMN "messageType" TYPE bigint USING
  CASE "messageType"
    WHEN 'text' THEN 0
    WHEN 'image' THEN 1
    WHEN 'file' THEN 2
    WHEN 'system' THEN 3
    ELSE NULL
  END;

-- 3. ChatRoom table
-- chatRoomType: direct=0, group=1
ALTER TABLE chat_room ALTER COLUMN "chatRoomType" TYPE bigint USING
  CASE "chatRoomType"
    WHEN 'direct' THEN 0
    WHEN 'group' THEN 1
    ELSE NULL
  END;

-- 4. Notification table
-- notificationType: review_received=0
ALTER TABLE notification ALTER COLUMN "notificationType" TYPE bigint USING
  CASE "notificationType"
    WHEN 'review_received' THEN 0
    ELSE NULL
  END;

-- 5. ProductReport table
-- reason: spam=0, inappropriate=1, fake=2, prohibited=3, duplicate=4, other=5
ALTER TABLE product_report ALTER COLUMN reason TYPE bigint USING
  CASE reason
    WHEN 'spam' THEN 0
    WHEN 'inappropriate' THEN 1
    WHEN 'fake' THEN 2
    WHEN 'prohibited' THEN 3
    WHEN 'duplicate' THEN 4
    WHEN 'other' THEN 5
    ELSE NULL
  END;

-- status: pending=0, processing=1, resolved=2, rejected=3
ALTER TABLE product_report ALTER COLUMN status TYPE bigint USING
  CASE status
    WHEN 'pending' THEN 0
    WHEN 'processing' THEN 1
    WHEN 'resolved' THEN 2
    WHEN 'rejected' THEN 3
    ELSE NULL
  END;

-- 6. TransactionReview table
-- reviewType: seller_to_buyer=0, buyer_to_seller=1
ALTER TABLE transaction_review ALTER COLUMN "reviewType" TYPE bigint USING
  CASE "reviewType"
    WHEN 'seller_to_buyer' THEN 0
    WHEN 'buyer_to_seller' THEN 1
    ELSE NULL
  END;

COMMIT;
