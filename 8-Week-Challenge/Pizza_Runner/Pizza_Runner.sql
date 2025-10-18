use pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  runner_id INT,
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
  order_id INT,
  customer_id INT,
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
  
  
  
# Part A ------ Pizza Metrics
#1. How many pizzas were ordered?
SELECT COUNT(pizza_id) AS pizza_count
FROM customer_orders;

#2. How many unique customer orders were made?
SELECT * 
FROM customer_orders;

SELECT COUNT(DISTINCT order_id) AS unique_order_count
FROM customer_orders;
#3. How many successful orders were delivered by each runner?
UPDATE runner_orders
SET pickup_time  = NULLIF(pickup_time, 'null'),
    distance     = NULLIF(distance, 'null'),
    duration     = NULLIF(duration, 'null'),
    cancellation = NULLIF(NULLIF(cancellation, 'null'), '');

SELECT runner_id, COUNT(order_id) AS order_count
FROM runner_orders
WHERE duration IS NOT NULL
GROUP BY runner_id;

#4. How many of each type of pizza was delivered?
SELECT p.pizza_name,count(*) AS Delivery_Count 
FROM customer_orders AS c INNER JOIN runner_orders AS r USING(order_id) 
INNER JOIN pizza_names AS p USING(pizza_id) 
WHERE r.distance is not null
GROUP BY p.pizza_name;

#5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT customer_id,pizza_name,count(*) AS Number_of_times_Ordered
FROM customer_orders AS c INNER JOIN pizza_names AS p using(pizza_id)
GROUP BY customer_id,pizza_name
ORDER BY customer_id;


#6. What was the maximum number of pizzas delivered in a single order?
SELECT order_id, pizza_count
FROM(
	 SELECT c.order_id,count(*) as pizza_count 
     FROM customer_orders c INNER JOIN runner_orders r USING(order_id) 
     WHERE distance IS NOT NULL
	 GROUP BY c.order_id) AS T
ORDER BY pizza_count DESC
LIMIT 1;

#7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT c.customer_id,
       SUM(CASE WHEN (c.exclusions IS NOT NULL OR c.extras IS NOT NULL) THEN 1 ELSE 0 END) AS with_changes,
       SUM(CASE WHEN (c.exclusions IS NULL AND c.extras IS NULL) THEN 1 ELSE 0 END) AS no_changes
FROM customer_orders AS c INNER JOIN runner_orders AS r using(order_id)
WHERE r.distance IS NOT NULL
GROUP BY c.customer_id;

#8. How many pizzas were delivered that had both exclusions and extras?
SELECT c.customer_id,SUM(CASE WHEN (c.exclusions IS NOT NULL AND c.extras IS NOT NULL) THEN 1 ELSE 0 END) AS with_exclusions_and_extras
FROM customer_orders AS c INNER JOIN runner_orders AS r using(order_id)
WHERE r.distance IS NOT NULL
GROUP BY c.customer_id;


#9. What was the total volume of pizzas ordered for each hour of the day?
SELECT HOUR(order_time) AS hour , COUNT(*) AS pizza_count
FROM customer_orders
GROUP BY hour;

#10. What was the volume of orders for each day of the week?
SELECT WEEKDAY(order_time) AS WEEKDAY , COUNT(*) AS pizza_count
FROM customer_orders
GROUP BY WEEKDAY;


#Part B ------ Pizza Metrics
#1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT WEEK(registration_date) AS week, COUNT(runner_id) AS runner_count
FROM runners
GROUP BY WEEK(registration_date);

#2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT r.runner_id, AVG(TIMESTAMPDIFF(MINUTE, c.order_time, r.pickup_time)) AS avg_time_to_pickup
FROM customer_orders c JOIN runner_orders r USING (order_id)
GROUP BY r.runner_id;

#3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
SELECT c.order_id,COUNT(c.pizza_id) AS pizzas_in_order,
TIMESTAMPDIFF(MINUTE, c.order_time, r.pickup_time) AS prep_time_minutes
FROM customer_orders c INNER JOIN runner_orders r USING(order_id)
WHERE r.pickup_time IS NOT NULL
GROUP BY c.order_id, c.order_time, r.pickup_time
ORDER BY pizzas_in_order;

#4. What was the average distance travelled for each customer?
SELECT c.customer_id,AVG(CAST(REPLACE(r.distance,'km','') AS DECIMAL(5,2))) AS avg_distance_km
FROM customer_orders c
JOIN runner_orders r USING(order_id)
WHERE r.distance IS NOT NULL
GROUP BY c.customer_id;


#5. What was the difference between the longest and shortest delivery times for all orders?
SELECT MAX(CAST(REPLACE(duration,'minutes','') AS UNSIGNED)) -
       MIN(CAST(REPLACE(duration,'minutes','') AS UNSIGNED)) AS diff_minutes
FROM runner_orders
WHERE duration IS NOT NULL;

#6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT runner_id,
       order_id,
       ROUND( CAST(REPLACE(distance,'km','') AS DECIMAL(5,2))/(CAST(REPLACE(duration,'minutes','') AS DECIMAL(5,2)) / 60),2) AS speed_kmh
FROM runner_orders
WHERE distance IS NOT NULL AND duration IS NOT NULL
ORDER BY runner_id, order_id;

#7. What is the successful delivery percentage for each runner?
SELECT runner_id,100.0 * SUM(CASE WHEN distance IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) AS success_pct
FROM runner_orders
GROUP BY runner_id;


#Part C ------ Pizza Ingredient Optimisation
 
#1. What are the standard ingredients for each pizza?
SELECT p.pizza_name,GROUP_CONCAT(t.topping_name ORDER BY t.topping_name) AS ingredients
FROM pizza_recipes r
JOIN pizza_toppings t ON FIND_IN_SET(t.topping_id, r.toppings)
JOIN pizza_names p USING(pizza_id)
GROUP BY p.pizza_name;

#2. What was the most commonly added extra?
SELECT t.topping_name, COUNT(*) AS extra_count
FROM customer_orders c INNER JOIN pizza_toppings t ON FIND_IN_SET(t.topping_id, c.extras) INNER JOIN runner_orders r USING(order_id)
WHERE r.distance IS NOT NULL
GROUP BY t.topping_name
ORDER BY extra_count DESC
LIMIT 1;


#3. What was the most common exclusion?
select exclusions, count(*) as times_excluded
from customer_orders
where exclusions not in ('', 'null')
  and exclusions is not null
group by exclusions
order by times_excluded desc
limit 1;


#4. Generate an order item for each record in the customers_orders table in the format of one of the following:
/* Meat Lovers
Meat Lovers - Exclude Beef
Meat Lovers - Extra Bacon
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers */
with order_base as (
   select 
       co.order_id,
       pn.pizza_name,
       co.exclusions,
       co.extras
   from customer_orders co
   join pizza_names pn 
     on co.pizza_id = pn.pizza_id
),
exclude_map as (
   select 
       ob.order_id,
       group_concat(pt.topping_name order by pt.topping_id) as exclude_names
   from order_base ob
   join pizza_toppings pt 
     on find_in_set(pt.topping_id, ob.exclusions)
   where ob.exclusions not in ('', 'null') 
   group by ob.order_id
),
extra_map as (
   select 
       ob.order_id,
       group_concat(pt.topping_name order by pt.topping_id) as extra_names
   from order_base ob
   join pizza_toppings pt 
     on find_in_set(pt.topping_id, ob.extras)
   where ob.extras not in ('', 'null') 
   group by ob.order_id
)
select 
    ob.order_id,
    concat(
        ob.pizza_name,
        if(em.exclude_names is not null, concat(' - Exclude ', em.exclude_names), ''),
        if(xm.extra_names is not null, concat(' - Extra ', xm.extra_names), '')
    ) as order_item
from order_base ob
left join exclude_map em on ob.order_id = em.order_id
left join extra_map xm on ob.order_id = xm.order_id
order by ob.order_id;



#5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
#For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
with order_base as (
    select 
        co.order_id,
        co.pizza_id,
        pn.pizza_name,
        co.extras
    from customer_orders co
    join pizza_names pn on co.pizza_id = pn.pizza_id
),
topping_list as (
    select 
        ob.order_id,
        ob.pizza_name,
        pt.topping_name,
        case 
            when find_in_set(pt.topping_id, ob.extras) then concat('2x', pt.topping_name)
            else pt.topping_name
        end as final_topping
    from order_base ob
    join pizza_recipes pr on ob.pizza_id = pr.pizza_id
    join pizza_toppings pt 
      on find_in_set(pt.topping_id, pr.toppings)
)
select 
    order_id,
    concat(
        pizza_name, ': ',
        group_concat(final_topping order by final_topping separator ', ')
    ) as ingredient_list
from topping_list
group by order_id, pizza_name
order by order_id;




#6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
SELECT t.topping_name, COUNT(*) AS total_used
FROM customer_orders c
INNER JOIN runner_orders r USING(order_id) INNER JOIN pizza_recipes pr USING(pizza_id) INNER JOIN pizza_toppings t ON FIND_IN_SET(t.topping_id, pr.toppings)
WHERE r.distance IS NOT NULL
GROUP BY t.topping_name
ORDER BY total_used DESC;

#Part D ------ Pricing and Ratings

#1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
SELECT SUM(CASE WHEN p.pizza_name = 'Meatlovers' THEN 12 ELSE 10 END) AS revenue
FROM customer_orders c
JOIN pizza_names p USING(pizza_id)
JOIN runner_orders r USING(order_id)
WHERE r.distance IS NOT NULL;

#2. What if there was an additional $1 charge for any pizza extras?
#Add cheese is $1 extra
SELECT SUM(
         CASE WHEN p.pizza_name = 'Meatlovers' THEN 12 ELSE 10 END
       + (CASE WHEN c.extras IS NOT NULL AND c.extras <> '' 
               THEN LENGTH(REPLACE(c.extras, ',', ''))+1 ELSE 0 END) * 1
       ) AS revenue
FROM customer_orders c
JOIN pizza_names p USING(pizza_id)
JOIN runner_orders r USING(order_id)
WHERE r.distance IS NOT NULL;

#3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

CREATE TABLE runner_ratingss (
  order_id INT PRIMARY KEY,
  runner_id INT,
  customer_id INT,
  rating INT CHECK (rating BETWEEN 1 AND 5)
);

-- Example insert
INSERT INTO runner_ratingss VALUES
(1, 1, 101, 5),
(2, 1, 101, 4),
(3, 1, 102, 5),
(4, 2, 103, 4),
(5, 3, 104, 5),
(7, 2, 105, 3),
(8, 2, 102, 5),
(10, 1, 104, 4);
select * from runner_ratingss;
   
#4. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
SELECT 
  SUM(CASE WHEN p.pizza_name = 'Meatlovers' THEN 12 ELSE 10 END) -
  SUM(0.30 * CAST(REPLACE(r.distance,'km','') AS DECIMAL(5,2))) AS net_profit
FROM customer_orders c
JOIN pizza_names p USING(pizza_id)
JOIN runner_orders r USING(order_id)
WHERE r.distance IS NOT NULL;

#Part E ------ Bonus Questions
#1. If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?
INSERT INTO pizza_names (pizza_id, pizza_name)
VALUES (3, 'Supreme');

INSERT INTO pizza_recipes (pizza_id, toppings)
VALUES (3, '1,2,3,4,5,6,7,8,9,10,11,12');

select * from pizza_names;

  