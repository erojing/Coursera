-- Report on Mode: https://app.mode.com/erojing/reports/2a304354fc89

-- Exercise 1:
-- Create the right subtable for recently viewed events using the view_item_events table.

-- Exercise 2: Check your joins. Join your tables together recent_views, users, items

-- Starter Code:
SELECT 
  *
FROM 
  (
  SELECT 
    event_time,
    ROW_NUMBER() over (Partition by user_id Order by event_time DESC) 
    AS view_number,
    user_id,
    item_id
  FROM 
    dsv1069.view_item_events
  ) recent_views
WHERE
  view_number = 1

-- Exercise 3: Clean up your columns. The goal of all this is to return all of the information we’ll
-- need to send users an email about the item they viewed more recently. Clean up this query
-- outline from the outline in EX2 and pull only the columns you need. Make sure they are named
-- appropriately so that another human can read and understand their contents.

-- Exercise 4: Consider any edge cases. If we sent an email to everyone in the results of this
-- query, what would we want to filter out. Add in any extra filtering that you think would make this
-- email better. For example should we include deleted users? Should we send this email to users
-- who already ordered the item they viewed most recently?

-- Starter Code: Code from Ex2

SELECT 
  COALESCE(users.parent_user_id, users.id) AS user_id,
  users.email_address,
  items.id                                 AS item_id,
  items.name                               AS item_name,
  items.category                           AS item_category,
  recent_views.event_time
FROM 
  (
  SELECT 
    event_time,
    ROW_NUMBER() over (Partition by user_id Order by event_time DESC) 
    AS view_number,
    user_id,
    item_id
  FROM 
    dsv1069.view_item_events
  WHERE 
    event_time > '2017-01-01'
  ) recent_views
JOIN 
  dsv1069.users
ON 
  users.id = recent_views.user_id
JOIN 
  dsv1069.items
ON 
  items.id = recent_views.item_id
LEFT OUTER JOIN 
  dsv1069.orders 
ON 
  orders.item_id = recent_views.item_id 
AND 
  orders.user_id = recent_views.user_id
WHERE
  view_number = 1
AND
  users.deleted_at IS NULL
AND 
  orders.item_id IS NULL