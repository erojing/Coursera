-- Report on Mode: https://app.mode.com/erojing/reports/4440d7224376

-- Exercise 1: Figure out how many tests we have running right now

SELECT 
  DISTINCT parameter_value AS test_id
FROM 
  dsv1069.events
WHERE 
  event_name = 'test_assignment'
AND
  parameter_name = 'test_id'

-- Exercise 2: Check for potential problems with test assignments. For example Make sure there
-- is no data obviously missing (This is an open ended question)

SELECT 
  parameter_value AS test_id,
  DATE(event_time) AS day,
  COUNT(*) AS event_rows
FROM 
  dsv1069.events
WHERE 
  event_name = 'test_assignment'
AND
  parameter_name = 'test_id'
GROUP BY
  test_id,
  day

-- Exercise 3: Write a query that returns a table of assignment events.Please include all of the
-- relevant parameters as columns (Hint: A previous exercise as a template)

-- Starter Code:

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

-- Exercise 4: Check for potential assignment problems with test_id 5. Specifically, make sure
-- users are assigned only one treatment group

SELECT 
  user_id,
  test_id,
  COUNT(DISTINCT test_assignment) AS assignments_count
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
GROUP BY
  user_id,
  test_id
ORDER BY 
  assignments_count DESC