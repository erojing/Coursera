-- Report on Mode: https://app.mode.com/erojing/reports/58b7c2b5e23c

-- Exercise 1: Create a subtable of orders per day. Make sure you decide whether you are
-- counting invoices or line items.

-- Starter Code:

SELECT 
  DATE(paid_at)                AS day,
  COUNT(DISTINCT invoice_id)   AS orders,
  COUNT(DISTINCT line_item_id) AS items_ordered
FROM 
  dsv1069.orders
GROUP BY
  day

-- Exercise 2: “Check your joins”. We are still trying to count orders per day. In this step join the
-- sub table from the previous exercise to the dates rollup table so we can get a row for every
-- date. Check that the join works by just running a “select *” query

-- Exercise 3: “Clean up your Columns” In this step be sure to specify the columns you actually
-- want to return, and if necessary do any aggregation needed to get a count of the orders made
-- per day.

-- Starter Code: (previous exercise)

SELECT 
  order_count,
  day,
  d7_ago,
  d28_ago
FROM 
  (
  SELECT 
    COUNT(invoice_id) AS order_count,
    DATE(created_at) AS day
  FROM 
    dsv1069.orders
  GROUP BY
    day
  ) daily_order_count
JOIN
  dsv1069.dates_rollup
ON 
  dates_rollup.date = daily_order_count.day

-- Exercise 4: Weekly Rollup. Figure out which parts of the JOIN condition need to be edited
-- create 7 day rolling orders table.

-- Exercise 5: Column Cleanup. Finish creating the weekly rolling orders table, by performing
-- any aggregation steps and naming your columns appropriately.

-- Starter Code: Result from EX2 or EX3

SELECT 
  date,
  COALESCE(SUM(orders), 0)        AS week_orders,
  COALESCE(SUM(items_ordered), 0) AS week_items_ordered,
  COUNT(*)                        AS check_days_count
FROM 
  dsv1069.dates_rollup  
LEFT OUTER JOIN
  (
  SELECT 
    DATE(paid_at)                AS day,
    COUNT(DISTINCT invoice_id)   AS orders,
    COUNT(DISTINCT line_item_id) AS items_ordered
  FROM 
    dsv1069.orders
  GROUP BY
    day
  ) daily_order_count
ON 
  dates_rollup.date >= daily_order_count.day
AND
  dates_rollup.d7_ago < daily_order_count.day
GROUP BY 
  date

-- This is creating a '7 days Moving Average' of orders and items ordered