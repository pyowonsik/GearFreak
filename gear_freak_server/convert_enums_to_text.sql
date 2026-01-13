BEGIN;

-- 1. Product table
-- status: 0=selling, 1=reserved, 2=sold
ALTER TABLE product ALTER COLUMN status TYPE text USING
  CASE status::int
    WHEN 0 THEN 'selling'
    WHEN 1 THEN 'reserved'
    WHEN 2 THEN 'sold'
    ELSE NULL
  END;

-- category: 0=equipment, 1=supplement, 2=clothing, 3=shoes, 4=etc
ALTER TABLE product ALTER COLUMN category TYPE text USING
  CASE category::int
    WHEN 0 THEN 'equipment'
    WHEN 1 THEN 'supplement'
    WHEN 2 THEN 'clothing'
    WHEN 3 THEN 'shoes'
    WHEN 4 THEN 'etc'
    ELSE NULL
  END;

-- condition: 0=brandNew, 1=usedExcellent, 2=usedGood, 3=usedFair
ALTER TABLE product ALTER COLUMN condition TYPE text USING
  CASE condition::int
    WHEN 0 THEN 'brandNew'
    WHEN 1 THEN 'usedExcellent'
    WHEN 2 THEN 'usedGood'
    WHEN 3 THEN 'usedFair'
    ELSE NULL
  END;

-- tradeMethod: 0=direct, 1=delivery, 2=both
ALTER TABLE product ALTER COLUMN "tradeMethod" TYPE text USING
  CASE "tradeMethod"::int
    WHEN 0 THEN 'direct'
    WHEN 1 THEN 'delivery'
    WHEN 2 THEN 'both'
    ELSE NULL
  END;

-- 2. ChatMessage table
-- messageType: 0=text, 1=image, 2=file, 3=system
ALTER TABLE chat_message ALTER COLUMN "messageType" TYPE text USING
  CASE "messageType"::int
    WHEN 0 THEN 'text'
    WHEN 1 THEN 'image'
    WHEN 2 THEN 'file'
    WHEN 3 THEN 'system'
    ELSE NULL
  END;

-- 3. ChatRoom table
-- chatRoomType: 0=direct, 1=group
ALTER TABLE chat_room ALTER COLUMN "chatRoomType" TYPE text USING
  CASE "chatRoomType"::int
    WHEN 0 THEN 'direct'
    WHEN 1 THEN 'group'
    ELSE NULL
  END;

-- 4. Notification table
-- notificationType: 0=review_received
ALTER TABLE notification ALTER COLUMN "notificationType" TYPE text USING
  CASE "notificationType"::int
    WHEN 0 THEN 'review_received'
    ELSE NULL
  END;

-- 5. ProductReport table
-- reason: 0=spam, 1=inappropriate, 2=fake, 3=prohibited, 4=duplicate, 5=other
ALTER TABLE product_report ALTER COLUMN reason TYPE text USING
  CASE reason::int
    WHEN 0 THEN 'spam'
    WHEN 1 THEN 'inappropriate'
    WHEN 2 THEN 'fake'
    WHEN 3 THEN 'prohibited'
    WHEN 4 THEN 'duplicate'
    WHEN 5 THEN 'other'
    ELSE NULL
  END;

-- status: 0=pending, 1=processing, 2=resolved, 3=rejected
ALTER TABLE product_report ALTER COLUMN status TYPE text USING
  CASE status::int
    WHEN 0 THEN 'pending'
    WHEN 1 THEN 'processing'
    WHEN 2 THEN 'resolved'
    WHEN 3 THEN 'rejected'
    ELSE NULL
  END;

-- 6. TransactionReview table
-- reviewType: 0=seller_to_buyer, 1=buyer_to_seller
ALTER TABLE transaction_review ALTER COLUMN "reviewType" TYPE text USING
  CASE "reviewType"::int
    WHEN 0 THEN 'seller_to_buyer'
    WHEN 1 THEN 'buyer_to_seller'
    ELSE NULL
  END;

COMMIT;
