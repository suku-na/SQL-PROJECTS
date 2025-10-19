select * from customer_nodes;
select * from customer_transactions;
select * from regions;

#A. Customer Journey
#1. How many unique nodes are there on the Data Bank system?
SELECT count(DISTINCT node_id) AS unique_nodes
FROM customer_nodes;

#2. What is the number of nodes per region?
SELECT region_id,region_name,count(node_id) AS node_count
FROM customer_nodes
INNER JOIN regions USING(region_id)
GROUP BY region_id,region_name;

#3. How many customers are allocated to each region?
SELECT region_id,region_name,count(DISTINCT customer_id) AS customer_count
FROM customer_nodes
INNER JOIN regions USING(region_id)
GROUP BY region_id,region_name;

#4. How many days on average are customers reallocated to a different node?
SELECT round(avg(datediff(end_date, start_date)), 2) AS avg_days
FROM customer_nodes
WHERE end_date!='9999-12-31';

#5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
#reallocation days metric: days taken to reallocate to a different node
#Percentile found by partitioning the dataset by regions and arranging it in ascending order of reallocation_days
#95th percentile -> 95% of the values are less than or equal to the current value.
#95th percentile
WITH reallocation_days_cte AS
  (SELECT *,
          (datediff(end_date, start_date)) AS reallocation_days
   FROM customer_nodes
   INNER JOIN regions USING (region_id)
   WHERE end_date!='9999-12-31'),
     percentile_cte AS
  (SELECT *,
          percent_rank() over(PARTITION BY region_id
                              ORDER BY reallocation_days)*100 AS p
   FROM reallocation_days_cte)
SELECT region_id,
       region_name,
       reallocation_days
FROM percentile_cte
WHERE p >95
GROUP BY region_id,region_name,reallocation_days;

#50th percentile

WITH reallocation_days_cte AS
  (SELECT *,
          (datediff(end_date, start_date)) AS reallocation_days
   FROM customer_nodes
   INNER JOIN regions USING (region_id)
   WHERE end_date!='9999-12-31'),
     percentile_cte AS
  (SELECT *,
          percent_rank() over(PARTITION BY region_id
                              ORDER BY reallocation_days)*100 AS p
   FROM reallocation_days_cte)
SELECT region_id,
       region_name,
       reallocation_days
FROM percentile_cte
WHERE p >50
GROUP BY region_id,region_name,reallocation_days;

#B. Data Analysis Questions

#1. What is the unique count and total amount for each transaction type?
SELECT txn_type,
       count(*) AS unique_count,
       sum(txn_amount) AS total_amont
FROM customer_transactions
GROUP BY txn_type;

#2. What is the average total historical deposit counts and amounts for all customers?
SELECT round(count(customer_id)/
               (SELECT count(DISTINCT customer_id)
                FROM customer_transactions)) AS average_deposit_count,
       concat('$', round(avg(txn_amount), 2)) AS average_deposit_amount
FROM customer_transactions
WHERE txn_type = "deposit";

#3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
WITH transaction_count_per_month_cte AS
  (SELECT customer_id,
          month(txn_date) AS txn_month,
          SUM(IF(txn_type="deposit", 1, 0)) AS deposit_count,
          SUM(IF(txn_type="withdrawal", 1, 0)) AS withdrawal_count,
          SUM(IF(txn_type="purchase", 1, 0)) AS purchase_count
   FROM customer_transactions
   GROUP BY customer_id,
            month(txn_date))
SELECT txn_month,
       count(DISTINCT customer_id) as customer_count
FROM transaction_count_per_month_cte
WHERE deposit_count>1
  AND (purchase_count = 1
       OR withdrawal_count = 1)
GROUP BY txn_month;

#4. What is the closing balance for each customer at the end of the month?
WITH txn_monthly_balance_cte AS
  (SELECT customer_id,
          txn_amount,
          month(txn_date) AS txn_month,
          SUM(CASE
                  WHEN txn_type="deposit" THEN txn_amount
                  ELSE -txn_amount
              END) AS net_transaction_amt
   FROM customer_transactions
   GROUP BY customer_id,txn_amount,
            month(txn_date)
   ORDER BY customer_id)
SELECT customer_id,
txn_month,
net_transaction_amt,
sum(net_transaction_amt) over(PARTITION BY customer_id
ORDER BY txn_month ROWS BETWEEN UNBOUNDED preceding AND CURRENT ROW) AS closing_balance
FROM txn_monthly_balance_cte;

#5. What is the percentage of customers who increase their closing balance by more than 5%?


