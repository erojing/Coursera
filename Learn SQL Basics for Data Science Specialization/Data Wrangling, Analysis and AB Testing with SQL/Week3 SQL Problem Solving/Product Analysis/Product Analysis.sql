-- Report on Mode: https://app.mode.com/erojing/reports/d51bcf35e4ac

-- Exercise 0: Count how many users we have

-- Starter Code:
SELECT 
  COUNT(*) AS total_users
FROM 
  dsv1069.users

-- Exercise 1: Find out how many users have ever ordered

-- Starter Code:
SELECT 
  COUNT(DISTINCT user_id) AS users_with_orders
FROM 
  dsv1069.orders

-- Exercise 2:
-- --Goal find how many users have reordered the same item

-- Starter Code:
SELECT 
  COUNT(DISTINCT user_id) AS users_who_reordered
FROM 
  (
  SELECT
    user_id,
    item_id,
    COUNT(DISTINCT line_item_id) AS times_user_ordered
  FROM 
    dsv1069.orders
  GROUP BY
    user_id,
    item_id
  ) user_level_orders
WHERE
  times_user_ordered > 1

-- Exercise 3:
-- Do users even order more than once?

-- Starter Code:

SELECT 
  COUNT(DISTINCT user_id) AS users_who_ordered_more_than_once
FROM 
  (
  SELECT
    user_id,
    COUNT(DISTINCT invoice_id) AS order_count
  FROM 
    dsv1069.orders
  GROUP BY
    user_id
  ) user_level_order_counts
WHERE
  order_count > 1

-- Exercise 4:
-- Orders per item

-- Starter Code:

SELECT
  item_id,
  COUNT(DISTINCT line_item_id) AS times_user_ordered
FROM 
  dsv1069.orders
GROUP BY
  item_id
ORDER BY
  times_user_ordered DESC

-- Exercise 5:
-- Orders per category

-- Starter Code:

SELECT
  item_category,
  COUNT(DISTINCT line_item_id) AS times_user_ordered
FROM 
  dsv1069.orders
GROUP BY
  item_category
ORDER BY
  times_user_ordered DESC

-- Exercise 6:
-- Goal: Do user order multiple things from the same category?

-- Starter Code:

SELECT 
  item_category,
  AVG(items_category_ordered) AS avg_items_category_ordered
FROM 
  (
  SELECT
    user_id,
    item_category,
    COUNT(DISTINCT line_item_id) AS items_category_ordered
  FROM 
    dsv1069.orders
  GROUP BY
    user_id,
    item_category
  ) user_level
GROUP BY
  item_category

-- Exercise 7:
-- Goal: Find the average time between orders
-- Decide if this analysis is necessary

-- Starter Code:
SELECT 
  first_orders.user_id,
  DATE(first_orders.paid_at)                               AS first_order_date,
  DATE(second_orders.paid_at)                              AS second_order_date,
  DATE(second_orders.paid_at) - DATE(first_orders.paid_at) AS date_diff
FROM 
  (
  SELECT 
    user_id,
    invoice_id,
    paid_at,
    DENSE_RANK() OVER (PARTITION BY user_id ORDER BY paid_at ASC)
    AS order_num
  FROM 
    dsv1069.orders
  ) first_orders
JOIN 
  (
  SELECT 
    user_id,
    invoice_id,
    paid_at,
    DENSE_RANK() OVER (PARTITION BY user_id ORDER BY paid_at ASC)
    AS order_num
  FROM 
    dsv1069.orders
  ) second_orders
ON 
  first_orders.user_id = second_orders.user_id
WHERE
  first_orders.order_num = 1
AND
  second_orders.order_num = 2