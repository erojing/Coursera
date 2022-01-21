-- Report on Mode: https://app.mode.com/erojing/reports/1b2cc2d1b56c

-- Exercise 1: Use the order_binary metric from the previous exercise, count the number of users
-- per treatment group for test_id = 7, and count the number of users with orders (for test_id 7)

-- Calculating test result: https://thumbtack.github.io/abba/demo/abba

SELECT 
  test_assignment,
  COUNT(user_id)                     AS user_count,
  SUM(order_after_assignment_binary) AS orders_count
FROM 
  (
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
  ) user_level
WHERE
  test_id = '7'
GROUP BY
  test_assignment

-- EX2 prev

SELECT 
  assignment_event.user_id,
  assignment_event.test_assignment,
  assignment_event.test_id,
  assignment_event.platform,
  assignment_event.event_time,
  MIN(CASE WHEN assignment_event.event_time < views.event_time THEN views.event_time ELSE NULL END)
  AS first_view_after_assignment,
  MAX(CASE WHEN assignment_event.event_time < views.event_time THEN 1 ELSE 0 END)
  AS view_after_assignment_binary,
  COUNT(DISTINCT (CASE WHEN assignment_event.event_time < views.event_time THEN views.event_id ELSE NULL END))
  AS total_views_after_assignment
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
  (
  SELECT 
    *
  FROM 
    dsv1069.events 
  WHERE 
    event_name = 'view_item'
  ) views
ON 
  assignment_event.user_id = views.user_id
GROUP BY
  assignment_event.user_id,
  assignment_event.test_assignment,
  assignment_event.test_id,
  assignment_event.platform,
  assignment_event.event_time
ORDER BY
  first_view_after_assignment DESC
  --total_views_after_assignment DESC

-- Exercise 2: Create a new tem view binary metric. Count the number of users per treatment
-- group, and count the number of users with views (for test_id 7)

SELECT 
  test_assignment,
  COUNT(user_id)                    AS user_count,
  SUM(view_after_assignment_binary) AS views_count
FROM 
  (
  SELECT 
    assignment_event.user_id,
    assignment_event.test_assignment,
    assignment_event.test_id,
    assignment_event.platform,
    assignment_event.event_time,
    MIN(CASE WHEN assignment_event.event_time < views.event_time THEN views.event_time ELSE NULL END)
    AS first_view_after_assignment,
    MAX(CASE WHEN assignment_event.event_time < views.event_time THEN 1 ELSE 0 END)
    AS view_after_assignment_binary,
    COUNT(DISTINCT (CASE WHEN assignment_event.event_time < views.event_time THEN views.event_time ELSE NULL END))
    AS total_views_after_assignment
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
    (
    SELECT 
      *
    FROM 
      dsv1069.events 
    WHERE 
      event_name = 'view_item'
    ) views
  ON 
    assignment_event.user_id = views.user_id
  GROUP BY
    assignment_event.user_id,
    assignment_event.test_assignment,
    assignment_event.test_id,
    assignment_event.platform,
    assignment_event.event_time
  ORDER BY
    -- first_paid_after_assignment DESC
    total_views_after_assignment DESC
  ) user_level
WHERE
  test_id = '7'
GROUP BY
  test_assignment

-- Exercise 3: Alter the result from EX 2, to compute the users who viewed an item WITHIN 30
-- days of their treatment event

SELECT 
  test_assignment,
  COUNT(user_id)                    AS user_count,
  SUM(view_after_assignment_binary) AS views_count,
  SUM(view_after_30d_binary)        AS views_30d_count
FROM 
  (
  SELECT 
    assignment_event.user_id,
    assignment_event.test_assignment,
    assignment_event.test_id,
    assignment_event.platform,
    assignment_event.event_time,
    MIN(CASE WHEN assignment_event.event_time < views.event_time THEN views.event_time ELSE NULL END)
    AS first_view_after_assignment,
    MAX(CASE WHEN assignment_event.event_time < views.event_time THEN 1 ELSE 0 END)
    AS view_after_assignment_binary,
    MAX(CASE WHEN (assignment_event.event_time < views.event_time 
             AND DATE_PART('day',views.event_time - assignment_event.event_time) <= 30) THEN 1 ELSE 0 END)
    AS view_after_30d_binary,    
    COUNT(DISTINCT (CASE WHEN assignment_event.event_time < views.event_time THEN views.event_time ELSE NULL END))
    AS total_views_after_assignment
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
    (
    SELECT 
      *
    FROM 
      dsv1069.events 
    WHERE 
      event_name = 'view_item'
    ) views
  ON 
    assignment_event.user_id = views.user_id
  GROUP BY
    assignment_event.user_id,
    assignment_event.test_assignment,
    assignment_event.test_id,
    assignment_event.platform,
    assignment_event.event_time
  ORDER BY
    -- first_paid_after_assignment DESC
    total_views_after_assignment DESC
  ) user_level
WHERE
  test_id = '7'
GROUP BY
  test_assignment

-- Exercise 4:
-- Create the metric invoices (this is a mean metric, not a binary metric) and for test_id = 7
-- The count of users per treatment group
-- The average value of the metric per treatment group
-- The standard deviation of the metric per treatment group

SELECT 
  test_id,
  test_assignment,
  COUNT(user_id)                        AS user_count,
  AVG(total_orders_after_assignment)    AS AVG_orders,
  STDDEV(total_orders_after_assignment) AS STD_orders,
  AVG(total_items_after_assignment)     AS AVG_items,
  STDDEV(total_items_after_assignment)  AS STD_items,
  AVG(total_revenue)                    AS AVG_revenue,
  STDDEV(total_revenue)                 AS STD_revenue
FROM 
  (
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
  ) user_level
GROUP BY
  test_id,
  test_assignment
ORDER BY 
  test_id