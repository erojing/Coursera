--Report on Mode: https://app.mode.com/erojing/reports/e0c274e2fbf1

-- Exercise 1: We’ll be using the users table to answer the question “How many new users are
-- added each day?“. Start by making sure you understand the columns in the table.

-- Starter Code:
SELECT 
  * 
FROM 
  dsv1069.users

-- Exercise 2: WIthout worrying about deleted user or merged users, count the number of users
-- added each day.

-- Starter Code:
SELECT 
  date(created_at) AS date,
  COUNT(id) AS users
FROM 
  dsv1069.users
GROUP BY
  date
ORDER BY
  date

-- Exercise 3: Consider the following query. Is this the right way to count merged or deleted
-- users? If all of our users were deleted tomorrow what would the result look like?

-- Starter Code:
SELECT
  date(created_at) AS day,
  COUNT(*) AS users
FROM
  dsv1069.users
WHERE
  deleted_at IS NULL
AND
  (id <> parent_user_id OR parent_user_id IS NULL)
GROUP BY
  date(created_at)

-- Exercise 4: Count the number of users deleted each day. Then count the number of users
-- removed due to merging in a similar way.

-- Starter Code: (Use the result from #2 as a guide)
SELECT 
  date(deleted_at) AS del_date,
  COUNT(id) AS users
FROM 
  dsv1069.users
WHERE
  deleted_at IS NOT NULL
GROUP BY
  del_date
ORDER BY
  del_date

-- Exercise 5: Use the pieces you’ve built as subtables and create a table that has a column for
-- the date, the number of users created, the number of users deleted and the number of users
-- merged that day.

-- Starter Code:
SELECT
  new_users.new_date,
  new_users.new_user,
  del_users.del_user,
  merge_users.merge_user
FROM
  (
  SELECT 
    date(created_at) AS new_date,
    COUNT(id) AS new_user
  FROM 
    dsv1069.users
  GROUP BY
    new_date
  ORDER BY
    new_date
  ) new_users
LEFT JOIN
  (
  SELECT 
    date(deleted_at) AS del_date,
    COUNT(id) AS del_user
  FROM 
    dsv1069.users
  WHERE
    deleted_at IS NOT NULL
  GROUP BY
    del_date
  ORDER BY
    del_date
  ) del_users
ON del_users.del_date = new_users.new_date
LEFT JOIN 
  (
  SELECT 
    date(merged_at) AS merge_date,
    COUNT(id) AS merge_user
  FROM 
    dsv1069.users
  WHERE
    id <> parent_user_id OR parent_user_id IS NULL
  AND 
    parent_user_id IS NOT NULL 
  GROUP BY
    merge_date
  ORDER BY
    merge_date
  ) merge_users
ON merge_users.merge_date = new_users.new_date

-- Exercise 6: Refine your query from #5 to have informative column names and so that null
-- columns return 0.

-- Starter Code:
SELECT
  new_users.new_date,
  new_users.new_user,
  COALESCE(del_users.del_user,0) AS del_user,
  COALESCE(merge_users.merge_user,0) AS merge_user,
  (new_users.new_user -  COALESCE(del_users.del_user,0) - COALESCE(merge_users.merge_user,0)) AS net_user
FROM
  (
  SELECT 
    date(created_at) AS new_date,
    COUNT(id) AS new_user
  FROM 
    dsv1069.users
  GROUP BY
    new_date
  ORDER BY
    new_date
  ) new_users
LEFT JOIN
  (
  SELECT 
    date(deleted_at) AS del_date,
    COUNT(id) AS del_user
  FROM 
    dsv1069.users
  WHERE
    deleted_at IS NOT NULL
  GROUP BY
    del_date
  ORDER BY
    del_date
  ) del_users
ON del_users.del_date = new_users.new_date
LEFT JOIN 
  (
  SELECT 
    date(merged_at) AS merge_date,
    COUNT(id) AS merge_user
  FROM 
    dsv1069.users
  WHERE
    id <> parent_user_id OR parent_user_id IS NULL
  AND 
    parent_user_id IS NOT NULL 
  GROUP BY
    merge_date
  ORDER BY
    merge_date
  ) merge_users
ON merge_users.merge_date = new_users.new_date

-- Exercise 7:
-- What if there were days where no users were created, but some users were deleted or merged.
-- Does the previous query still work? No, it doesn’t. Use the dates_rollup as a backbone for this
-- query, so that we won’t miss any dates.

-- Starter Code:
SELECT 
  * 
FROM 
  dsv1069.dates_rollup