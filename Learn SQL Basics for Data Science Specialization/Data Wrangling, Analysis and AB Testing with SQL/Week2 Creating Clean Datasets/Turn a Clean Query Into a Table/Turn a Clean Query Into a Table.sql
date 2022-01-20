--Report on Mode: https://app.mode.com/erojing/reports/1d42f411785c
--try CREATE TABLE AS

CREATE TABLE 
  view_item_event_1
AS 
SELECT 
  event_id,
  event_time,
  user_id,
  platform,
  MAX(CASE WHEN parameter_name = 'item_id'
           THEN parameter_value
           ELSE NULL 
      END) AS item_id,
  MAX(CASE WHEN parameter_name = 'referrer'
           THEN parameter_value
           ELSE NULL 
      END) AS referrer
FROM 
  events 
WHERE
  event_name = 'view_item'
GROUP BY
  event_id,
  event_time,
  user_id,
  platform
ORDER BY
  event_id

--Check the table

DESCRIBE 
  view_item_event_1;

SELECT 
  *
FROM 
  view_item_event_1
LIMIT
  10;
  
DROP TABLE 
  view_item_event_1;

-- Edit the query
-- Make sure time variable in correct data type

SELECT 
  event_id,
  TIMESTAMP(event_time) AS event_time,
  user_id,
  platform,
  MAX(CASE WHEN parameter_name = 'item_id'
           THEN parameter_value
           ELSE NULL 
      END) AS item_id,
  MAX(CASE WHEN parameter_name = 'referrer'
           THEN parameter_value
           ELSE NULL 
      END) AS referrer
FROM 
  events 
WHERE
  event_name = 'view_item'
GROUP BY
  event_id,
  event_time,
  user_id,
  platform
ORDER BY
  event_id

-- CREATE TABLE
-- Here we create the table structure

CREATE TABLE view_item_events (
event_id    VARCHAR(32) NOT NULL PRIMARY KEY,
event_time  VARCHAR(26),
user_id     INT(10),
platform    VARCHAR(10),
item_id     INT(10),
referrer    VARCHAR(17)
);

-- INSERT data
-- If want to clear the table first, use REPLACE INTO

INSERT INTO 
  view_item_events

SELECT 
  event_id,
  TIMESTAMP(event_time) AS event_time,
  user_id,
  platform,
  MAX(CASE WHEN parameter_name = 'item_id'
           THEN parameter_value
           ELSE NULL 
      END) AS item_id,
  MAX(CASE WHEN parameter_name = 'referrer'
           THEN parameter_value
           ELSE NULL 
      END) AS referrer
FROM 
  events 
WHERE
  event_name = 'view_item'
GROUP BY
  event_id,
  event_time,
  user_id,
  platform
ORDER BY
  event_id