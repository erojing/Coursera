-- Report on Mode: https://app.mode.com/erojing/reports/8ac2704fea2a

-- 1. Data quality check
-- We are running an experiment at an item-level, which means all users who visit will see the same page, 
-- but the layout of different item pages may differ.
-- Compare this table to the assignment events we captured for user_level_testing.
-- Does this table have everything you need to compute metrics like 30-day view-binary?

SELECT 
  * 
FROM 
  dsv1069.final_assignments_qa

-- No, there's no information when the test assigned.

CREATE TABLE IF NOT EXISTS final_assignments
(
  item_id           INT(10) NOT NULL,
  test_assignment   INT(1) NOT NULL,
  test_number       CHAR(20) NOT NULL,
  test_start_date   DATE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO 
  final_assignments
SELECT 
  item_id,
  test_assignment,
  test_number,
  DATE(CURRENT_TIMESTAMP) AS test_start_date
FROM 
  (
  -- Reverse pivot
  SELECT item_id, test_a AS test_assignment, 'item_test_1' AS test_number FROM dsv1069.final_assignments_qa
   UNION
  SELECT item_id, test_b AS test_assignment, 'item_test_2' AS test_number FROM dsv1069.final_assignments_qa
   UNION
  SELECT item_id, test_c AS test_assignment, 'item_test_3' AS test_number FROM dsv1069.final_assignments_qa
   UNION
  SELECT item_id, test_d AS test_assignment, 'item_test_4' AS test_number FROM dsv1069.final_assignments_qa
   UNION
  SELECT item_id, test_e AS test_assignment, 'item_test_5' AS test_number FROM dsv1069.final_assignments_qa
   UNION
  SELECT item_id, test_f AS test_assignment, 'item_test_6' AS test_number FROM dsv1069.final_assignments_qa
  ) pivot
ORDER BY
  test_number

-- No information of test_start_date.

-- 3. Use this table to 
-- compute order_binary for the 30 day window after the test_start_date
-- for the test named item_test_2

SELECT 
  final_assignments.item_id,
  test_assignment,
  test_start_date,
  MAX(CASE WHEN orders.created_at IS NOT NULL THEN 1 ELSE 0 END) AS orders_in_30d_binary,
  COALESCE(COUNT(DISTINCT invoice_id),0)                         AS orders_in_30d
FROM 
  dsv1069.final_assignments
LEFT OUTER JOIN
  dsv1069.orders
ON 
  final_assignments.item_id = orders.item_id
AND 
  orders.created_at >= final_assignments.test_start_date
AND 
  DATE_PART('day', orders.created_at - final_assignments.test_start_date ) <= 30
WHERE
  test_number = 'item_test_2'
GROUP BY
  final_assignments.test_assignment,
  final_assignments.item_id,
  final_assignments.test_start_date

-- 4. Use this table to 
-- compute view_binary for the 30 day window after the test_start_date
-- for the test named item_test_2

SELECT 
  final_assignments.item_id,
  test_assignment,
  test_start_date,
  MAX(CASE WHEN views.event_time IS NOT NULL THEN 1 ELSE 0 END) AS views_in_30d_binary,
  COALESCE(COUNT(DISTINCT event_id),0)                          AS views_in_30d
FROM 
  dsv1069.final_assignments
LEFT OUTER JOIN
  (
    SELECT 
      event_time,
      event_id,
      CAST(parameter_value AS INT) AS item_id
    FROM 
      dsv1069.events 
    WHERE 
      event_name = 'view_item'
    AND 
      parameter_name = 'item_id'
  ) views
ON 
  final_assignments.item_id = views.item_id
AND 
  views.event_time >= final_assignments.test_start_date
AND 
  DATE_PART('day', views.event_time - final_assignments.test_start_date ) <= 30
WHERE
  test_number = 'item_test_2'
GROUP BY
  final_assignments.test_assignment,
  final_assignments.item_id,
  final_assignments.test_start_date

--5. Use the https://thumbtack.github.io/abba/demo/abba.html to compute the lifts in 
--metrics and the p-values for the binary metrics ( 30 day order binary and 30 day 
--view binary) using a interval 95% confidence. 

SELECT 
  order_metric.test_assignment,
  COUNT(*)                  AS total_count,
  SUM(orders_in_30d_binary) AS ordered_items,
  SUM(orders_in_30d)        AS orders,
  SUM(views_in_30d_binary)  AS viewed_items,
  SUM(views_in_30d)         AS views,
  AVG(views_in_30d)         AS average_views
FROM 
  (
  SELECT 
    final_assignments.item_id,
    test_assignment,
    test_start_date,
    MAX(CASE WHEN orders.created_at IS NOT NULL THEN 1 ELSE 0 END) AS orders_in_30d_binary,
    COALESCE(COUNT(DISTINCT invoice_id),0)                         AS orders_in_30d
  FROM 
    dsv1069.final_assignments
  LEFT OUTER JOIN
    dsv1069.orders
  ON 
    final_assignments.item_id = orders.item_id
  AND 
    orders.created_at >= final_assignments.test_start_date
  AND 
    DATE_PART('day', orders.created_at - final_assignments.test_start_date ) <= 30
  WHERE
    test_number = 'item_test_2'
  GROUP BY
    final_assignments.test_assignment,
    final_assignments.item_id,
    final_assignments.test_start_date
  ) order_metric
LEFT OUTER JOIN 
  (
  SELECT 
    final_assignments.item_id,
    test_assignment,
    test_start_date,
    MAX(CASE WHEN views.event_time IS NOT NULL THEN 1 ELSE 0 END) AS views_in_30d_binary,
    COALESCE(COUNT(DISTINCT event_id),0)                          AS views_in_30d
  FROM 
    dsv1069.final_assignments
  LEFT OUTER JOIN
    (
      SELECT 
        event_time,
        event_id,
        CAST(parameter_value AS INT) AS item_id
      FROM 
        dsv1069.events 
      WHERE 
        event_name = 'view_item'
      AND 
        parameter_name = 'item_id'
    ) views
  ON 
    final_assignments.item_id = views.item_id
  AND 
    views.event_time >= final_assignments.test_start_date
  AND 
    DATE_PART('day', views.event_time - final_assignments.test_start_date ) <= 30
  WHERE
    test_number = 'item_test_2'
  GROUP BY
    final_assignments.test_assignment,
    final_assignments.item_id,
    final_assignments.test_start_date
  ) view_metric
ON 
  order_metric.item_id = view_metric.item_id
AND
  order_metric.test_assignment = view_metric.test_assignment
AND 
  order_metric.test_start_date = view_metric.test_start_date
GROUP BY
  order_metric.test_assignment
  
-- ORDERS: p-value = 0.88, there's no different under 95% confidence. (https://reurl.cc/Y9d6Dn)
-- VIEWS:  p-value = 0.20, there's no different under 95% confidence. (https://reurl.cc/44Xml2)