create database Vetty_project;

CREATE TABLE transactions1(
    buyer_id INT,
    purchase_time DATETIME,
    refund_item DATETIME,
    store_id VARCHAR(20) NOT NULL,
    item_id VARCHAR(20) NOT NULL,
    gross_transaction_value DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (buyer_id, purchase_time)
);


INSERT INTO transactions1
VALUES
(3, '2019-09-19 21:19:06.544', NULL, 'a', 'a1', 58),
(12, '2019-12-10 20:10:14.324', '2019-12-15 23:19:06.544', 'b', 'b2', 475),
(3, '2020-09-01 23:59:46.561', '2020-09-02 21:22:06.331', 'f', 'f9', 33),
(2, '2020-04-30 21:19:06.544', NULL, 'd', 'd3', 250),
(1, '2020-10-22 22:20:06.531', NULL, 'f', 'f2', 91),
(8, '2020-04-16 21:10:22.214', NULL, 'e', 'e7', 24),
(5, '2019-09-23 12:09:35.542', '2019-09-27 02:55:02.114', 'g', 'g6', 61);

CREATE TABLE items1 (
    store_id      VARCHAR(10) NOT NULL,
    item_id       VARCHAR(10) NOT NULL,
    item_category VARCHAR(50) NOT NULL,
    item_name     VARCHAR(100) NOT NULL
);

INSERT INTO items1 (store_id, item_id, item_category, item_name) VALUES
('a', 'a1', 'pants',   'denim pants'),
('a', 'a2', 'tops',    'blouse'),
('f', 'f1', 'table',   'coffee table'),
('f', 'f5', 'chair',   'lounge chair'),
('f', 'f6', 'chair',   'armchair'),
('d', 'd2', 'jewelry', 'bracelet'),
('b', 'b4', 'earphone','airpods');


-- Q1.
SELECT 
    DATE_FORMAT(purchase_time, '%Y-%m') AS purchase_month,
    COUNT(*) AS purchase_count
FROM transactions1
WHERE refund_item IS NULL
GROUP BY 1
ORDER BY 1;

-- Approach: 
--    1. Filter out rows where refund_time is NOT NULL.
--    2. Format purchase_time to 'YYYY-MM' using DATE_FORMAT.
--    3. Group by the month and count.


-- Q2. 
SELECT COUNT(*) AS store_count
FROM (
    SELECT store_id
    FROM transactions1
    WHERE purchase_time >= '2020-10-01' 
      AND purchase_time < '2020-11-01'
    GROUP BY store_id
    HAVING COUNT(*) >= 5
) AS N_Stores;

-- Approach:
--    1. Filter transactions for October 2020.
--    2. Group by store_id.
--    3. Use HAVING to keep stores with count >= 5.
--    4. Wrap in a subquery to count the resulting stores.

-- Q3
SELECT 
    store_id,
    MIN(TIMESTAMPDIFF(MINUTE, purchase_time, refund_item)) AS short_time
FROM transactions1
WHERE refund_item IS NOT NULL
GROUP BY store_id;
--  Approach:
--    1. Filter only rows where refund_time IS NOT NULL.
--    2. Use TIMESTAMPDIFF(MINUTE, start, end) to get the interval.
--    3. Find the MIN value per store.



-- Q4  
WITH cte AS (
    SELECT 
        store_id,
        gross_transaction_value,
        purchase_time,
        ROW_NUMBER() OVER (PARTITION BY store_id ORDER BY purchase_time ASC) as rn
    FROM transactions1
)
SELECT 
    store_id,
    gross_transaction_value
FROM cte
WHERE rn = 1;
-- Approach:
--    1. Use ROW_NUMBER() to rank orders per store by time.
--    2. Filter for rn = 1.


-- Q5
WITH cte AS (
    SELECT 
        t.buyer_id,
        t.item_id,
        t.store_id,
        ROW_NUMBER() OVER (PARTITION BY t.buyer_id ORDER BY t.purchase_time ASC) as rn
    FROM transactions1 t
)
SELECT 
    i.item_name,
    COUNT(*) as popularity_count
FROM cte c
JOIN items1 i 
    ON c.item_id = i.item_id 
    AND c.store_id = i.store_id
WHERE c.rn = 1
GROUP BY i.item_name
ORDER BY popularity_count DESC
LIMIT 1;

-- Approach:
--    1. Identify first purchase per buyer using ROW_NUMBER.
--    2. Join with 'items' table on item_id and store_id.
--    3. Count occurrences of item_name and pick the top one.


-- Q6
SELECT 
    buyer_id,
    purchase_time,
    refund_item,
    CASE 
        WHEN refund_item IS NOT NULL 
             AND TIMESTAMPDIFF(HOUR, purchase_time, refund_item) <= 72 
        THEN 'Process Refund'
        ELSE 'Do Not Process'
    END AS refund_process_flag
FROM transactions1
WHERE refund_item IS NOT NULL;

-- Approach:
--    1. Use TIMESTAMPDIFF with HOUR unit.
--    2. Check if difference <= 72.


-- Q7

WITH cte AS (
    SELECT 
        buyer_id,
        purchase_time,
        item_id,
        gross_transaction_value,
        ROW_NUMBER() OVER (PARTITION BY buyer_id ORDER BY purchase_time ASC) as purchase_rank
    FROM transactions1
)
SELECT *
FROM cte
WHERE purchase_rank = 2;
--  Approach:
--    1. Rank purchases per buyer using ROW_NUMBER.
--    2. Filter where rank is 2.


-- Q8
SELECT 
    buyer_id,
    purchase_time AS second_transaction_time
FROM (
    SELECT 
        buyer_id,
        purchase_time,
        ROW_NUMBER() OVER (PARTITION BY buyer_id ORDER BY purchase_time ASC) as purchase_rank
    FROM transactions1
) AS ranked_data
WHERE purchase_rank = 2;

-- Same Approach as q7 just output the timestamp


