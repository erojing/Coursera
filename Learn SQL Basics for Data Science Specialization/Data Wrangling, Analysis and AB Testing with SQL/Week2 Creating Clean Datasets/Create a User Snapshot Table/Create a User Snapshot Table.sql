--Report on Mode: https://app.mode.com/erojing/reports/cd1dea715bd9
-- Liquid tags -(Variables)

{% assign ds = '2018-01-01' %}
SELECT 
  id
FROM 
  dsv1069.users
WHERE 
  created_at <= '{{ds}}'

-- Create query
-- Mode doesn't support function IF, using it will get an error

{% assign ds = '2018-01-01' %}

SELECT 
  users.id                                              AS user_id,
  -- IF(users.created_at = '{{ds}}', 1, 0)                 AS created_today,
  -- IF(users.deleted_at <= '{{ds}}', 1, 0)                AS is_deleted,
  -- IF(users.deleted_at = '{{ds}}', 1, 0)                 AS is_deleted_today,
  -- IF(users_with_orders.user_id IS NOT NULL, 1, 0)       AS has_ever_oredered,
  -- IF(users_with_orders_today.user_id IS NOT NULL, 1, 0) AS ordered_today,
  CASE WHEN users.created_at = '{{ds}}' THEN 1 ELSE 0 END                  AS created_today,
  CASE WHEN users.deleted_at <= '{{ds}}' THEN  1 ELSE 0 END                AS is_deleted,
  CASE WHEN users.deleted_at = '{{ds}}' THEN  1 ELSE 0 END                 AS is_deleted_today,
  CASE WHEN users_with_orders.user_id IS NOT NULL THEN  1 ELSE 0 END       AS has_ever_oredered,
  CASE WHEN users_with_orders_today.user_id IS NOT NULL THEN  1 ELSE 0 END AS ordered_today,
  '{{ds}}'                                              AS ds
FROM 
  dsv1069.users 
LEFT OUTER JOIN 
  (
  SELECT 
    DISTINCT user_id
  FROM 
    dsv1069.orders 
  WHERE 
    created_at <= '{{ds}}'
  ) users_with_orders
ON 
  users_with_orders.user_id = users.id 

LEFT OUTER JOIN 
  (
  SELECT 
    DISTINCT user_id
  FROM 
    dsv1069.orders 
  WHERE 
    created_at = '{{ds}}'
  ) users_with_orders_today
ON 
  users_with_orders_today.user_id = users.id 

-- CREATE TABLE

CREATE TABLE IF NOT EXISTS user_info
(
  user_id           INT(10) NOT NULL,
  created_today     INT(1) NOT NULL,
  is_deleted        INT(1) NOT NULL,
  is_deleted_today  INT(1) NOT NULL,
  has_ever_ordered  INT(1) NOT NULL,
  ordered_today     INT(1) NOT NULL,
  ds DATE NOTNULL
);
DESCRIBE user_info;

-- INSERT INTO TABLE

{% assign ds = '2018-01-01' %}
INSERT INTO 
  user_info

SELECT 
  users.id                                              AS user_id,
  -- IF(users.created_at = '{{ds}}', 1, 0)                 AS created_today,
  -- IF(users.deleted_at <= '{{ds}}', 1, 0)                AS is_deleted,
  -- IF(users.deleted_at = '{{ds}}', 1, 0)                 AS is_deleted_today,
  -- IF(users_with_orders.user_id IS NOT NULL, 1, 0)       AS has_ever_oredered,
  -- IF(users_with_orders_today.user_id IS NOT NULL, 1, 0) AS ordered_today,
  CASE WHEN users.created_at = '{{ds}}' THEN 1 ELSE 0 END                  AS created_today,
  CASE WHEN users.deleted_at <= '{{ds}}' THEN  1 ELSE 0 END                AS is_deleted,
  CASE WHEN users.deleted_at = '{{ds}}' THEN  1 ELSE 0 END                 AS is_deleted_today,
  CASE WHEN users_with_orders.user_id IS NOT NULL THEN  1 ELSE 0 END       AS has_ever_oredered,
  CASE WHEN users_with_orders_today.user_id IS NOT NULL THEN  1 ELSE 0 END AS ordered_today,
  '{{ds}}'                                              AS ds
FROM 
  dsv1069.users 
LEFT OUTER JOIN 
  (
  SELECT 
    DISTINCT user_id
  FROM 
    dsv1069.orders 
  WHERE 
    created_at <= '{{ds}}'
  ) users_with_orders
ON 
  users_with_orders.user_id = users.id 

LEFT OUTER JOIN 
  (
  SELECT 
    DISTINCT user_id
  FROM 
    dsv1069.orders 
  WHERE 
    created_at = '{{ds}}'
  ) users_with_orders_today
ON 
  users_with_orders_today.user_id = users.id 