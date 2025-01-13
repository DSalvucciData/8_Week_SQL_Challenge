CREATE DATABASE pizza_runner;
USE pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);
INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);
INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
  -- -----------------
SELECT *
FROM runners;
  
SELECT *
FROM customer_orders;
  
SELECT *
FROM runner_orders;
  
SELECT *
FROM pizza_names;
  
SELECT *
FROM pizza_recipes;
  
SELECT *
FROM pizza_toppings;

-- A. Pizza Metrics
-- DATA CLEANING STEPS
-- 1) Make it NULL whatever the string 'null' or blank entries appear
SET SQL_SAFE_UPDATES = 0;

UPDATE customer_orders
SET extras = NULL
WHERE extras = '' OR extras = 'null'
;
  
UPDATE customer_orders
SET exclusions = NULL
WHERE exclusions = '' OR exclusions = 'null'
  ;

SELECT *
FROM customer_orders;

-- Table runner_orders
-- 2) Remove 'km' and then trim spaces
UPDATE runner_orders
SET distance = TRIM(REPLACE(distance, 'km', ''))
;

-- 2) Replace 'null' with NULL
UPDATE runner_orders
SET distance = NULL
WHERE distance = 'null'

UPDATE runner_orders
SET duration = NULL
WHERE duration = 'null'
;

UPDATE runner_orders
SET pickup_time = NULL
WHERE pickup_time = 'null'
;

UPDATE runner_orders
SET cancellation = NULL
WHERE cancellation IN ('null', '')
;

-- 3) Remove text and then trim spaces
UPDATE runner_orders
SET duration = TRIM(REGEXP_REPLACE(duration, '[^0-9]', ''));

SELECT *
FROM runner_orders;

-- 4) Convert data type of distance column to float
ALTER TABLE runner_orders
MODIFY COLUMN distance FLOAT;

-- 5) Convert data type of duration column to int
ALTER TABLE runner_orders
MODIFY COLUMN duration INT;

-- 6) Convert data type of pickup_time column to TIMESTAMP
ALTER TABLE runner_orders
MODIFY COLUMN pickup_time TIMESTAMP;


-- Questions. Pizza Metrics
-- 1. How many pizzas were ordered?
SELECT 
    COUNT(order_id)
FROM
    customer_orders
;

-- 2. How many unique customer orders were made?
SELECT
	COUNT(DISTINCT order_id)
FROM 
    customer_orders
;

-- 3. How many successful orders were delivered by each runner?
SELECT
   runner_id
   , SUM(
   CASE 
      WHEN cancellation IS NULL THEN 1
      END
   ) AS successful_orders
FROM 
   runner_orders
GROUP BY
   runner_id
;

-- 4. How many of each type of pizza was delivered?
SELECT
   pn.pizza_name AS type_of_pizza
   , COUNT(co.pizza_id) AS pizzas_delivered
FROM
   customer_orders AS co
   JOIN pizza_names AS pn ON co.pizza_id = pn.pizza_id
   JOIN runner_orders AS ro ON co.order_id = ro.order_id
WHERE 
   cancellation IS NULL
GROUP BY 
   pn.pizza_name
ORDER BY 
   pizzas_delivered DESC;
;
   
-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT
   co.customer_id AS customer
   , pn.pizza_name AS pizza
   , COUNT(co.pizza_id) AS pizzas_ordered
FROM 
   customer_orders AS co 
   JOIN pizza_names AS pn ON co.pizza_id = pn.pizza_id
GROUP BY 
   customer
   , pizza
ORDER BY 
   customer
;

-- 6. What was the maximum number of pizzas delivered in a single order?
SELECT 
  MAX(pizza_count) AS max_pizzas_per_order
FROM (
   SELECT
   co.order_id AS order_id
   , COUNT(co.pizza_id) AS pizza_count
   FROM
   customer_orders AS co
    JOIN runner_orders AS ro ON co.order_id = ro.order_id
   WHERE ro.cancellation IS NULL
   GROUP BY
    order_id
   ) AS pizzas_per_order
   ;

-- 7. For each customer, how many delivered pizzas had at least 1 change and 
-- how many had no changes? (change here implies exlusion o extras)
SELECT
   co.customer_id AS customer,
   COUNT(co.pizza_id) AS total_pizzas,
   SUM(
      CASE 
         WHEN co.exclusions IS NOT NULL OR co.extras IS NOT NULL 
         THEN 1 
         ELSE 0 
      END
   ) AS at_least_1_change,
   SUM(
      CASE 
         WHEN co.exclusions IS NULL AND co.extras IS NULL 
         THEN 1 
         ELSE 0 
      END
   ) AS no_change
FROM
   customer_orders AS co
   JOIN runner_orders AS ro 
      ON co.order_id = ro.order_id
WHERE 
   ro.cancellation IS NULL
GROUP BY
   co.customer_id
;

-- 8. How many pizzas were delivered that had both exclusions and extras?
SELECT
  COUNT(co.pizza_id) AS pizzas_delivered_with_exlusions_and_extras
FROM
   customer_orders AS co
   JOIN runner_orders AS ro ON co.order_id = ro.order_id
WHERE 
   co.exclusions IS NOT NULL AND co.extras IS NOT NULL AND  ro.cancellation IS NULL
;

-- 9. What was the total volume of pizzas ordered for each hour of the day?

SELECT 
   HOUR(order_time) AS hours
   , COUNT(order_id) AS volume_of_pizzas
FROM
   customer_orders
GROUP BY
   hours
ORDER BY
   hours
;

-- 10. What was the volume of orders for each day of the week?
SELECT 
   weekdays
   , pizza_volume
FROM
   (
   SELECT 
      DAYNAME(order_time) AS weekdays
      , COUNT(order_id) AS pizza_volume
   FROM
      customer_orders
   GROUP BY
      weekdays
   ) AS pizza_volume_by_weekday
ORDER BY
   FIELD(weekdays, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')
;

-- B. Runner and Customer Experience
-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT
    WEEK(registration_date, 1) AS week,
    COUNT(runner_id) AS runners
FROM 
    runners
GROUP BY
    week
    ;

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT 
	ro.runner_id,
    ROUND(AVG(TIMESTAMPDIFF(MINUTE, co.order_time, ro.pickup_time)), 2) AS average_duration_in_minutes
FROM 
    runner_orders AS ro
    INNER JOIN customer_orders AS co
    ON ro.order_id = co.order_id
WHERE 
    ro.pickup_time IS NOT NULL
GROUP BY
   ro.runner_id
;

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH CTE AS (
    SELECT
        co.order_id,
        COUNT(co.pizza_id) AS number_of_pizzas,
        MAX(TIMESTAMPDIFF(MINUTE, co.order_time, ro.pickup_time)) AS prep_time
    FROM 
        customer_orders AS co
    JOIN 
        runner_orders AS ro 
        ON co.order_id = ro.order_id
    WHERE 
        ro.cancellation IS NULL
    GROUP BY
        co.order_id
)
SELECT 
    number_of_pizzas,
    AVG(prep_time) AS avg_time_prep,
    AVG(prep_time) / number_of_pizzas AS avg_time_prep_per_pizza
FROM 
    CTE
GROUP BY
    number_of_pizzas
;

-- 4. What was the average distance travelled for each customer?
SELECT
   co.customer_id As customer
   , AVG(ro.distance) AS avg_distance
FROM 
   customer_orders AS co
   JOIN runner_orders AS ro
   ON ro.order_id = co.order_id
WHERE 
   cancellation IS NULL
GROUP BY
   customer
;
-- 5. What was the difference between the longest and shortest delivery times for all orders?
SELECT 
   MAX(duration) - MIN(duration) as time_diff
FROM 
   runner_orders
;
    
-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT
   runner_id,
   order_id,
   ROUND(AVG(60 * distance / duration), 0) AS avg_speed
FROM 
   runner_orders
WHERE 
   cancellation IS NULL
GROUP BY
   runner_id,
   order_id
ORDER BY
   runner_id,
   order_id;
   
-- 7. What is the successful delivery percentage for each runner
SELECT 
   runner_id
   , SUM(CASE
       WHEN pickup_time IS NULL THEN 0
       ELSE 1
	   END) / COUNT(order_id) * 100 AS successful_delivery_percentage
FROM 
   runner_orders
GROUP BY
   runner_id
;
	
-- C. Ingredient Optimisation
-- 1. What are the standard ingredients for each pizza?
SELECT 
    pt.topping_name
	, COUNT(DISTINCT pizza_id) AS pizzas
FROM pizza_recipes,
JSON_TABLE(
    CONCAT('[', toppings, ']'), 
    "$[*]" COLUMNS(topping INT PATH "$")
) AS jt -- transform topping_id values into rows values
  INNER JOIN pizza_toppings AS pt 
  ON jt.topping = pt.topping_id
GROUP BY 
   pt.topping_name
HAVING 
   pizzas = 2;

-- 2. What was the most commonly added extra?
SELECT 
    pt.topping_name AS extra,
    COUNT(pizza_id) AS pizzas
FROM 
    customer_orders,
    JSON_TABLE(
        CONCAT('[', extras, ']'), 
        "$[*]" COLUMNS(extras INT PATH "$")
    ) AS jt
JOIN 
    pizza_toppings AS pt 
    ON jt.extras = pt.topping_id
GROUP BY 
    pt.topping_name
ORDER BY 
    pizzas DESC
LIMIT 1;

-- Another possible SQL query:

WITH CTE AS (
          SELECT 
              pt.topping_name AS extra
			, COUNT(pizza_id) AS pizzas
          FROM  
              customer_orders,
             JSON_TABLE(
				CONCAT('[', extras, ']'), 
				"$[*]" COLUMNS(extras INT PATH "$")
				) AS jt -- transform topping_id values into rows values
			 JOIN pizza_toppings AS pt
                 ON jt.extras = pt.topping_id
		  GROUP BY
				pt.topping_name
) 
SELECT 
   extra
   , pizzas / SUM(pizzas) OVER() AS porportion -- SUM(pizzas) OVER () calculates the total sum of pizzas across all rows
FROM 
   CTE
   ;
   
-- 3. What was the most common exclusion?
SELECT 
    pt.topping_name AS exclusion,
    COUNT(pizza_id) AS pizzas
FROM 
    customer_orders,
    JSON_TABLE(
        CONCAT('[', exclusions, ']'), 
        "$[*]" COLUMNS(exclusions INT PATH "$")
    ) AS jt
JOIN 
    pizza_toppings AS pt 
    ON jt.exclusions = pt.topping_id
GROUP BY 
    pt.topping_name
ORDER BY 
    pizzas DESC
LIMIT 1
;

-- 4. Generate an order item for each record in the customers_orders table in the format of one of the following:
-- Meat Lovers
-- Meat Lovers - Exclude Beef
-- Meat Lovers - Extra Bacon
-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

WITH EXTRAS AS (
		SELECT 
			co.order_id,
			co.pizza_id,
            co.extras,
			GROUP_CONCAT(DISTINCT pt.topping_name ORDER BY pt.topping_name SEPARATOR ', ') AS added_extra 
		FROM 
			customer_orders AS co,
			JSON_TABLE(
			CONCAT('[', extras, ']'), 
			"$[*]" COLUMNS(extras INT PATH "$")
			) AS jt
			JOIN 
				pizza_toppings AS pt 
				ON jt.extras = pt.topping_id
		GROUP BY
			co.order_id,
			co.pizza_id,
            co.extras
)
, EXCLUDED AS (
		SELECT 
			co.order_id,
			co.pizza_id,
            co.exclusions,
			GROUP_CONCAT(DISTINCT pt.topping_name ORDER BY pt.topping_name SEPARATOR ', ') AS excluded
		FROM 
			customer_orders AS co,
			JSON_TABLE(
			CONCAT('[', exclusions, ']'), 
			"$[*]" COLUMNS(exclusions INT PATH "$")
			) AS jt
		JOIN 
			pizza_toppings AS pt 
			ON jt.exclusions = pt.topping_id
		GROUP BY
			co.order_id,
			co.pizza_id,
            co.exclusions
)
SELECT 
   co.order_id,
   pn.pizza_name,
   COALESCE(co.extras, '') AS added_extra,
   COALESCE(co.exclusions, '') AS exluded,
   CONCAT(CASE WHEN
        pn.pizza_name = 'Meatlovers' THEN 'Meat Lovers' ELSE pn.pizza_name END, 
        COALESCE(CONCAT(' - Extra ', added_extra), ''), 
        COALESCE(CONCAT(' - Exclude ', excluded), '')
    ) AS order_details
FROM 
   customer_orders AS co
LEFT JOIN EXTRAS AS ext ON co.order_id = ext.order_id AND co.pizza_id = ext.pizza_id AND ext.extras = co.extras
LEFT JOIN EXCLUDED AS exc ON co.order_id = exc.order_id AND co.pizza_id = exc.pizza_id AND exc.exclusions = co.exclusions
INNER JOIN pizza_names AS pn ON pn.pizza_id = co.pizza_id
;

-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
-- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

WITH EXTRAS AS (
    SELECT 
        co.order_id,
        co.pizza_id,
        co.extras,
        pt.topping_id,
        pt.topping_name AS added_extras
    FROM 
        customer_orders AS co,
        JSON_TABLE(
            CONCAT('[', extras, ']'), 
            "$[*]" COLUMNS(extras INT PATH "$")
        ) AS jt
    JOIN 
        pizza_toppings AS pt 
        ON jt.extras = pt.topping_id
),
EXCLUDED AS (
    SELECT 
        co.order_id,
        co.pizza_id,
        co.exclusions,
        pt.topping_id,
        pt.topping_name AS excluded
    FROM 
        customer_orders AS co,
        JSON_TABLE(
            CONCAT('[', exclusions, ']'), 
            "$[*]" COLUMNS(exclusions INT PATH "$")
        ) AS jt
    JOIN 
        pizza_toppings AS pt 
        ON jt.exclusions = pt.topping_id
),
ORDERS AS (
    SELECT 
        co.order_id,
        co.pizza_id,
        jt.toppings AS topping_id,
        pt.topping_name
    FROM 
        customer_orders AS co
    INNER JOIN pizza_recipes AS pr 
        ON pr.pizza_id = co.pizza_id,
        JSON_TABLE(
            CONCAT('[', pr.toppings, ']'), 
            "$[*]" COLUMNS(toppings INT PATH "$")
        ) AS jt
    INNER JOIN pizza_toppings AS pt 
        ON pt.topping_id = jt.toppings
),
ORDERS_WITH_EXTRAS_AND_EXCLUSIONS AS (
    SELECT 
        O.order_id,
        O.pizza_id,
        O.topping_id,
        O.topping_name
    FROM 
        ORDERS AS O
    LEFT JOIN EXCLUDED AS EXC 
        ON EXC.order_id = O.order_id AND EXC.topping_id = O.topping_id
    WHERE 
        EXC.topping_id IS NULL

    UNION ALL

    SELECT 
        order_id,
        pizza_id,
        topping_id,
        added_extras AS topping_name
    FROM 
        EXTRAS
),
INGREDIENT_TOTAL AS (
    SELECT 
        order_id,
        pn.pizza_name,
        topping_name,
        COUNT(topping_id) AS n
    FROM 
        ORDERS_WITH_EXTRAS_AND_EXCLUSIONS AS O
    INNER JOIN pizza_names AS pn 
        ON pn.pizza_id = O.pizza_id
    GROUP BY
        order_id,
        pn.pizza_name,
        topping_name
)
, SUMMARY AS (
SELECT 
    order_id,
    pizza_name,
    GROUP_CONCAT(
        DISTINCT CASE 
            WHEN n > 1 THEN CONCAT(n, 'x', topping_name)
            ELSE topping_name
        END SEPARATOR ', '
    ) AS ingred
FROM 
    INGREDIENT_TOTAL
GROUP BY
    order_id,
    pizza_name
)
SELECT 
    order_id,
    CONCAT(CASE WHEN
        pizza_name = 'Meatlovers' THEN 'Meat Lovers' ELSE pizza_name END, ': ', ingred) AS ingredient_list
FROM 
    SUMMARY
;


-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?           

WITH EXTRAS AS (
    SELECT 
        co.order_id,
        co.pizza_id,
        co.extras,
        pt.topping_id,
        pt.topping_name AS added_extras
    FROM 
        customer_orders AS co,
        JSON_TABLE(
            CONCAT('[', extras, ']'), 
            "$[*]" COLUMNS(extras INT PATH "$")
        ) AS jt
    JOIN 
        pizza_toppings AS pt 
        ON jt.extras = pt.topping_id
),
EXCLUDED AS (
    SELECT 
        co.order_id,
        co.pizza_id,
        co.exclusions,
        pt.topping_id,
        pt.topping_name AS excluded
    FROM 
        customer_orders AS co,
        JSON_TABLE(
            CONCAT('[', exclusions, ']'), 
            "$[*]" COLUMNS(exclusions INT PATH "$")
        ) AS jt
    JOIN 
        pizza_toppings AS pt 
        ON jt.exclusions = pt.topping_id
),
ORDERS AS (
    SELECT 
        co.order_id,
        co.pizza_id,
        jt.toppings AS topping_id,
        pt.topping_name
    FROM 
        customer_orders AS co
    INNER JOIN pizza_recipes AS pr 
        ON pr.pizza_id = co.pizza_id,
        JSON_TABLE(
            CONCAT('[', pr.toppings, ']'), 
            "$[*]" COLUMNS(toppings INT PATH "$")
        ) AS jt
    INNER JOIN pizza_toppings AS pt 
        ON pt.topping_id = jt.toppings
),
ORDERS_WITH_EXTRAS_AND_EXCLUSIONS AS (
    SELECT 
        O.order_id,
        O.pizza_id,
        O.topping_id,
        O.topping_name
    FROM 
        ORDERS AS O
    LEFT JOIN EXCLUDED AS EXC 
        ON EXC.order_id = O.order_id AND EXC.topping_id = O.topping_id
    WHERE 
        EXC.topping_id IS NULL

    UNION ALL

    SELECT 
        order_id,
        pizza_id,
        topping_id,
        added_extras AS topping_name
    FROM 
        EXTRAS
)
SELECT 
       topping_name,
       COUNT(topping_id) AS n
FROM 
        ORDERS_WITH_EXTRAS_AND_EXCLUSIONS AS O
        INNER JOIN runner_orders AS ro ON O.order_id = ro.order_id
 WHERE cancellation IS NULL  
 GROUP BY
        topping_name
ORDER BY 
		COUNT(topping_id) DESC
 ;

-- D. Pricing and Ratings
-- 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes 
-- how much money has Pizza Runner made so far if there are no delivery fees?

SELECT 
    SUM(CASE WHEN co.pizza_id = 1 THEN 12 ELSE 10 END) AS total_price
FROM 
   customer_orders AS co
   JOIN runner_orders AS ro
       ON ro.order_id = co.order_id
WHERE 
    ro.cancellation IS NULL
;  

-- 2. What if there was an additional $1 charge for any pizza extras?
-- Add cheese is $1 extra

WITH CTE AS (
    SELECT 
        co.order_id,
        co.pizza_id,
        co.extras,
        LENGTH(extras) - LENGTH(REPLACE(extras, ',', '')) + 1 AS number_of_extras
    FROM 
        customer_orders AS co
    JOIN 
        runner_orders AS ro
        ON ro.order_id = co.order_id
    WHERE 
        ro.cancellation IS NULL
)
SELECT
    SUM(
        CASE 
            WHEN pizza_id = 1 AND number_of_extras IS NULL THEN 12
            WHEN pizza_id = 2 AND number_of_extras IS NULL THEN 10
            WHEN pizza_id = 1 AND number_of_extras >= 1 THEN 12 + number_of_extras * 1
            WHEN pizza_id = 2 AND number_of_extras >= 1 THEN 10 + number_of_extras * 1
            ELSE 0
        END
    ) AS total_revenue
FROM 
    CTE;
    

-- 3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

DROP TABLE IF EXISTS ratings;
CREATE TABLE ratings (
order_id int,
rating TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5));

INSERT INTO ratings VALUES 
(1, 5), (2, 5), (3, 3), (4, 4), (5, 2), (7, 1), (8, 3), (10, 4);

SELECT * FROM ratings;

 SELECT * FROM ratings
 
-- 4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
-- customer_id
-- order_id
-- runner_id
-- rating
-- order_time
-- pickup_time
-- Time between order and pickup
-- Delivery duration
-- Average speed
-- Total number of pizzas

SELECT
	co.customer_id,
	co.order_id,
	ro.runner_id,
	r.rating,
	co.order_time,
	ro.pickup_time,
	ROUND(TIMESTAMPDIFF(MINUTE, co.order_time, ro.pickup_time), 0) AS time_between_order_and_pickup,
	ro.duration AS delivery_duration,
	ROUND(AVG((ro.distance / ro.duration) * 60), 0) AS average_speed,
	COUNT(co.pizza_id) AS Total_number_of_pizzas
FROM 
	customer_orders AS co
    INNER JOIN runner_orders AS  ro
		ON co.order_id = ro.order_id
    INNER JOIN ratings AS r
		ON ro.order_id = r.order_id
WHERE
	ro.cancellation IS NULL
GROUP BY
	co.customer_id,
	co.order_id,
	ro.runner_id,
	r.rating,
	co.order_time,
	ro.pickup_time,
    ro.duration
ORDER BY
    customer_id
; 
  
-- 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled 
-- how much money does Pizza Runner have left over after these deliveries?

WITH CTE AS (
	SELECT 
		co.customer_id,
		co.order_id,
		pizza_id,
		COUNT(pizza_id),
		CASE
			WHEN co.pizza_id = 1 THEN COUNT(co.pizza_id) * 12
			WHEN co.pizza_id = 2 THEN COUNT(co.pizza_id) * 10
			ELSE 0
			END AS price,
		ro.distance * 0.30 AS cost_due_to_distance
	FROM
		customer_orders AS co
		JOIN runner_orders AS ro
			ON co.order_id = ro.order_id
	WHERE 
		ro.cancellation IS NULL
GROUP BY
		co.customer_id,
		co.order_id,
		co.pizza_id,
		ro.distance
)
SELECT
   SUM(price) - SUM(cost_due_to_distance) AS total_profit
FROM 
   CTE
   ;