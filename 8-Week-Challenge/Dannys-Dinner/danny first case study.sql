/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
select customer_id,sum(price) as total_amout_spent from 
menu inner join sales using (product_id)
group by customer_id
order by total_amout_spent desc;

-- 2. How many days has each customer visited the restaurant?
select customer_id,count(distinct(order_date)) as  no_of_visits
from sales
group by customer_id
order by customer_id;

-- 3. What was the first item from the menu purchased by each customer?
with order_info_cte as (select customer_id,order_date,product_name,
dense_rank () over(partition by customer_id order by order_date) as rank_num
from sales s inner join menu m using (product_id))
select customer_id,
group_concat(distinct product_name order by product_name) as product_name
from order_info_cte 
where rank_num =1 
group by customer_id;


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

select m.product_name, count(*) as total_purchased
from sales s
join menu m using (product_id)
group by m.product_name
order by total_purchased desc
limit 1;

-- 5. Which item was the most popular for each customer?
with item_counts as (
  select s.customer_id, m.product_name, count(*) as times_purchased,
         rank() over (partition by s.customer_id order by count(*) desc) as rnk
  from sales s
  join menu m on s.product_id = m.product_id
  group by s.customer_id, m.product_name)
  select customer_id, (product_name), times_purchased
  from item_counts
where rnk = 1;

-- 6. Which item was purchased first by the customer after they became a member?
WITH diner_info AS
  (SELECT product_name,
          s.customer_id,
          order_date,
          join_date,
          m.product_id,
          DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS first_item
   FROM menu AS m
   INNER JOIN sales AS s using(product_id)
   INNER JOIN members AS mem using(customer_id)
   WHERE order_date >= join_date )
SELECT customer_id,
       product_name,
       order_date
FROM diner_info
WHERE first_item=1;

-- 7. Which item was purchased just before the customer became a member?
WITH diner_info AS
  (SELECT product_name,s.customer_id,order_date,join_date,m.product_id,
  DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS item_rank
   FROM menu AS m
   INNER JOIN sales AS s using(product_id)
   INNER JOIN members AS mem using (customer_id)
   WHERE order_date < join_date )
SELECT customer_id,
GROUP_CONCAT(DISTINCT product_name ORDER BY product_name) AS product_name
FROM diner_info
WHERE item_rank=1
GROUP BY customer_id;

-- 8. What is the total items and amount spent for each member before they became a member?
SELECT s.customer_id,count(product_name) AS total_items,
SUM(price) AS amount_spent
FROM menu AS m
INNER JOIN sales AS s using(product_id)
INNER JOIN members AS mem using(customer_id)
WHERE order_date < join_date
GROUP BY s.customer_id
ORDER BY customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
#9a.Had the customer joined the loyalty program before making the purchases, total points that each customer would have accrued
SELECT customer_id,
SUM(CASE WHEN product_name = 'sushi' THEN price*20 ELSE price*10 END) AS customer_points
FROM menu AS m
INNER JOIN sales AS s using(product_id)
GROUP BY customer_id
ORDER BY customer_id;

#9b.Total points that each customer has accrued after taking a membership
SELECT s.customer_id,
SUM(CASE WHEN product_name = 'sushi' THEN price*20 ELSE price*10 END) AS customer_points
FROM menu AS m
INNER JOIN sales AS s using(product_id)
INNER JOIN members AS mem using(customer_id)
WHERE order_date >= join_date
GROUP BY s.customer_id
ORDER BY s.customer_id;
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?


WITH program_last_day_cte AS
  (SELECT join_date,DATE_ADD(join_date, INTERVAL 6 DAY) AS program_last_date,customer_id
FROM members)
SELECT s.customer_id,
SUM(CASE WHEN order_date BETWEEN join_date AND program_last_date THEN price*10*2
WHEN order_date NOT BETWEEN join_date AND program_last_date
AND product_name = 'sushi' THEN price*10*2 WHEN order_date NOT BETWEEN join_date AND program_last_date
AND product_name != 'sushi' THEN price*10 END) AS customer_points
FROM menu AS m
INNER JOIN sales AS s ON m.product_id = s.product_id
INNER JOIN program_last_day_cte AS mem ON mem.customer_id = s.customer_id
AND order_date <='2021-01-31'
AND order_date >=join_date
GROUP BY s.customer_id
ORDER BY s.customer_id;

#Bonus Questions
#Join All The Things
#Create basic data tables that Danny and his team can use to quickly 
#derive insights without needing to join the underlying tables using SQL.
 #Fill Member column as 'N' if the purchase was made before becoming a member
 #and 'Y' if the after is amde after joining the membership.
 
 SELECT customer_id,order_date,product_name,price,
IF(order_date >= join_date, 'Y', 'N') AS member
FROM members
RIGHT JOIN sales USING (customer_id)
INNER JOIN menu USING (product_id)
ORDER BY customer_id,order_date;

WITH data_table AS
  (SELECT customer_id,order_date,product_name,price,
IF(order_date >= join_date, 'Y', 'N') AS member
FROM members RIGHT JOIN sales USING (customer_id)
INNER JOIN menu USING (product_id)ORDER BY customer_id,order_date)
SELECT *,IF(member='N', NULL, DENSE_RANK() OVER (PARTITION BY customer_id, member
ORDER BY order_date)) AS ranking
FROM data_table;