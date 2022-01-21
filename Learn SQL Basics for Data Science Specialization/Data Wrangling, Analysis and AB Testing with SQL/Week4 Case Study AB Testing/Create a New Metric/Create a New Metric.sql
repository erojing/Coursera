-- Report on Mode: https://app.mode.com/erojing/reports/45a733a32398

-- Exercise 1:
-- Using the table from Exercise 4.3 and compute a metric that measures
-- Whether a user created an order after their test assignment
-- Requirements: Even if a user had zero orders, we should have a row that counts
-- their number of orders as zero
-- If the user is not in the experiment they should not be included

-- Starter Code:

SELECT 
  assignment_event.user_id,
  assignment_event.test_assignment,
  assignment_event.test_id,
  assignment_event.platform,
  assignment_event.event_time,
  MIN(CASE WHEN assignment_event.event_time < orders.paid_at THEN paid_at ELSE NULL END)
  AS first_paid_after_assignment,
  MAX(CASE WHEN assignment_event.event_time < orders.paid_at THEN 1 ELSE 0 END)
  AS order_after_assignment_binary,
  COUNT(DISTINCT (CASE WHEN assignment_event.event_time < orders.paid_at THEN invoice_id ELSE NULL END))
  AS total_orders_after_assignment,
  COUNT(DISTINCT (CASE WHEN assignment_event.event_time < orders.paid_at THEN line_item_id ELSE NULL END))
  AS total_items_after_assignment,
  SUM(DISTINCT (CASE WHEN assignment_event.event_time < orders.paid_at THEN price ELSE 0 END))
  AS total_revenue
FROM 
  (
  SELECT 
    event_id,
    event_time,
    user_id,
    platform,
    MAX(CASE WHEN parameter_name = 'test_assignment'
             THEN parameter_value
             ELSE NULL 
        END) AS test_assignment,
    MAX(CASE WHEN parameter_name = 'test_id'
             THEN parameter_value
             ELSE NULL 
        END) AS test_id
  FROM 
    dsv1069.events
  WHERE 
    event_name = 'test_assignment'
  GROUP BY
    event_id,
    event_time,
    user_id,
    platform
  ) assignment_event
LEFT OUTER JOIN
  dsv1069.orders
ON 
  assignment_event.user_id = orders.user_id
GROUP BY
  assignment_event.user_id,
  assignment_event.test_assignment,
  assignment_event.test_id,
  assignment_event.platform,
  assignment_event.event_time
ORDER BY
  -- first_paid_after_assignment DESC
  total_orders_after_assignment DESC