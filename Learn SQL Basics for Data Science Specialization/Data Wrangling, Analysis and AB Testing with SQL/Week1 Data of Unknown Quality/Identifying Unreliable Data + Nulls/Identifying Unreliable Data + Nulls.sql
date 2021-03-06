--Report on Mode: https://app.mode.com/erojing/reports/ab199430b39d

-- Exercise 1: Using any methods you like determine if you can you trust this events table.

-- Starter Code:
SELECT 
  date(event_time) AS date,
  count(*) AS rows
FROM 
  dsv1069.events_201701
GROUP BY
  date
ORDER BY
  date
  
--Looks reliable and complete in 2017-01


-- Exercise 2:
-- Using any methods you like, determine if you can you trust this events table. (HINT: When did
-- we start recording events on mobile)

-- Starter Code:
SELECT 
  date(event_time) AS date,
  platform,
  count(*) AS rows
FROM 
  dsv1069.events_ex2
GROUP BY
  date,
  platform 
ORDER BY
  platform,
  date  
  
--In the line chart we can see that mobile divices like Android and IOS are lately recorded,
--may be a concern using this data.


-- Exercise 3: Imagine that you need to count item views by day. You found this table
-- item_views_by_category_temp - should you use it to answer your question?

-- Starter Code:
SELECT 
  *
FROM 
  dsv1069.item_views_by_category_temp
-- Since the table doesn't provide information like date, we can't just use it to answer the question.


-- Exercise 4: Using any methods you like, decide if this table is ready to be used as a source of
-- truth.

-- Starter Code:
SELECT 
  *
FROM 
  dsv1069.raw_events

--Table 'dsv1069.raw_events' doesn't exist, should be fixed.


-- Exercise 5: Is this the right way to join orders to users? Is this the right way this join.

-- Starter Code:
SELECT 
  *
FROM 
  dsv1069.orders
JOIN 
  dsv1069.users
ON 
  orders.user_id = COALESCE(users.parent_user_id,users.id) 