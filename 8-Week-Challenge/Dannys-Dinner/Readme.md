<h1 align="center">🍜 Danny's Diner SQL Case Study</h1>

<p align="center">
  <i>Part of the <a href="https://8weeksqlchallenge.com/">8 Week SQL Challenge</a> by Danny Ma</i><br>
  <b>Case Study #1 – Danny’s Diner</b>
</p>

---

## 📘 Overview

Danny, the owner of a small Japanese restaurant, wants to analyze customer spending, visiting patterns, and menu preferences.  
Using the sales, menu, and members tables, SQL queries are written to help Danny make data-driven business decisions.

---

## 🧩 Entity Relationship Diagram (ERD)

<p align="center">
  <img src="./danny case 1 ER.png" alt="Danny's Diner ER Diagram" width="500"/>
</p>

| Table | Columns | Description |
|:--|:--|:--|
| **sales** | customer_id, order_date, product_id | Records of customer orders |
| **menu** | product_id, product_name, price | Menu items and prices |
| **members** | customer_id, join_date | Membership details |

---

## 💡 Business Questions & SQL Solutions

All SQL queries for this case study are available here 👉 [Danny_Diner_Case_Study.sql.sql](https://github.com/Basavaraj0127/SQL-PROJECTS/blob/main/Danny%27s%20Diner/Danny_Diner_Case_Study.sql.sql)

Below are the **exact queries** from that file 👇

---

### 1️⃣ What is the total amount each customer spent at the restaurant?


```sql
SELECT customer_id, SUM(price) AS total_amout_spent 
FROM menu 
INNER JOIN sales USING (product_id)
GROUP BY customer_id
ORDER BY total_amout_spent DESC;
```


---

### 2️⃣ How many days has each customer visited the restaurant?


```sql
SELECT customer_id, COUNT(DISTINCT(order_date)) AS no_of_visits
FROM sales
GROUP BY customer_id
ORDER BY customer_id;
```


---

### 3️⃣ What was the first item from the menu purchased by each customer?


```sql
WITH order_info_cte AS (
  SELECT customer_id, order_date, product_name,
         DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date) AS rank_num
  FROM sales s 
  INNER JOIN menu m USING (product_id)
)
SELECT customer_id,
       GROUP_CONCAT(DISTINCT product_name ORDER BY product_name) AS product_name
FROM order_info_cte 
WHERE rank_num = 1 
GROUP BY customer_id;
```


---

### 4️⃣ What is the most purchased item on the menu and how many times was it purchased by all customers?


```sql
SELECT m.product_name, COUNT(*) AS total_purchased
FROM sales s
JOIN menu m USING (product_id)
GROUP BY m.product_name
ORDER BY total_purchased DESC
LIMIT 1;
```

---

### 5️⃣ Which item was the most popular for each customer?


```sql
WITH item_counts AS (
  SELECT s.customer_id, m.product_name, COUNT(*) AS times_purchased,
         RANK() OVER(PARTITION BY s.customer_id ORDER BY COUNT(*) DESC) AS rnk
  FROM sales s
  JOIN menu m ON s.product_id = m.product_id
  GROUP BY s.customer_id, m.product_name
)
SELECT customer_id, product_name, times_purchased
FROM item_counts
WHERE rnk = 1;
```

---

### 6️⃣ Which item was purchased first by the customer after they became a member?


```sql
WITH diner_info AS (
  SELECT product_name,
         s.customer_id,
         order_date,
         join_date,
         m.product_id,
         DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS first_item
  FROM menu AS m
  INNER JOIN sales AS s USING(product_id)
  INNER JOIN members AS mem USING(customer_id)
  WHERE order_date >= join_date
)
SELECT customer_id, product_name, order_date
FROM diner_info
WHERE first_item = 1;
```

---

### 7️⃣ Which item was purchased just before the customer became a member?


```sql
WITH diner_info AS (
  SELECT product_name, s.customer_id, order_date, join_date, m.product_id,
         DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS item_rank
  FROM menu AS m
  INNER JOIN sales AS s USING(product_id)
  INNER JOIN members AS mem USING (customer_id)
  WHERE order_date < join_date
)
SELECT customer_id,
       GROUP_CONCAT(DISTINCT product_name ORDER BY product_name) AS product_name
FROM diner_info
WHERE item_rank = 1
GROUP BY customer_id;
```

---

### 8️⃣ What is the total items and amount spent for each member before they became a member?


```sql
SELECT s.customer_id,
       COUNT(product_name) AS total_items,
       SUM(price) AS amount_spent
FROM menu AS m
INNER JOIN sales AS s USING(product_id)
INNER JOIN members AS mem USING(customer_id)
WHERE order_date < join_date
GROUP BY s.customer_id
ORDER BY customer_id;
```

---

### 9️⃣ If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?


```sql
-- 9a. Points if customers had joined before purchasing
SELECT customer_id,
       SUM(CASE WHEN product_name = 'sushi' THEN price * 20 ELSE price * 10 END) AS customer_points
FROM menu AS m
INNER JOIN sales AS s USING(product_id)
GROUP BY customer_id
ORDER BY customer_id;

-- 9b. Points after taking a membership
SELECT s.customer_id,
       SUM(CASE WHEN product_name = 'sushi' THEN price * 20 ELSE price * 10 END) AS customer_points
FROM menu AS m
INNER JOIN sales AS s USING(product_id)
INNER JOIN members AS mem USING(customer_id)
WHERE order_date >= join_date
GROUP BY s.customer_id
ORDER BY s.customer_id;
```

---

### 🔟 In the first week after a customer joins the program (including join date), they earn 2x points on all items — how many points do customer A and B have at the end of January?


```sql
WITH program_last_day_cte AS (
  SELECT join_date, DATE_ADD(join_date, INTERVAL 6 DAY) AS program_last_date, customer_id
  FROM members
)
SELECT s.customer_id,
       SUM(
         CASE 
           WHEN order_date BETWEEN join_date AND program_last_date THEN price * 10 * 2
           WHEN order_date NOT BETWEEN join_date AND program_last_date AND product_name = 'sushi' THEN price * 10 * 2
           WHEN order_date NOT BETWEEN join_date AND program_last_date AND product_name != 'sushi' THEN price * 10
         END
       ) AS customer_points
FROM menu AS m
INNER JOIN sales AS s ON m.product_id = s.product_id
INNER JOIN program_last_day_cte AS mem ON mem.customer_id = s.customer_id
AND order_date <= '2021-01-31'
AND order_date >= join_date
GROUP BY s.customer_id
ORDER BY s.customer_id;
```

---

## 🏆 Bonus Questions

### 🧮 Join All The Things


```sql
SELECT customer_id, order_date, product_name, price,
       IF(order_date >= join_date, 'Y', 'N') AS member
FROM members
RIGHT JOIN sales USING (customer_id)
INNER JOIN menu USING (product_id)
ORDER BY customer_id, order_date;
```

---

### 🥇 Rank All The Things


```sql
WITH data_table AS (
  SELECT customer_id, order_date, product_name, price,
         IF(order_date >= join_date, 'Y', 'N') AS member
  FROM members 
  RIGHT JOIN sales USING (customer_id)
  INNER JOIN menu USING (product_id)
  ORDER BY customer_id, order_date
)
SELECT *,
       IF(member = 'N', NULL, DENSE_RANK() OVER (PARTITION BY customer_id, member ORDER BY order_date)) AS ranking
FROM data_table;
```

---

## 📊 Key Insights

- **Customer A** spent the most and enjoys **Ramen**.  
- **Customer B** is the most frequent visitor and enjoys all items.  
- **Customer C** prefers **Ramen**.  
- Membership increased engagement and loyalty points.

---

## 📂 Repository Structure

```
📁 Danny's Diner
│
├── Danny_Diner_Case_Study.sql.sql
├── danny case 1 ER.png
└── README.md
```

---

## 🔗 References

- Original Challenge → [8 Week SQL Challenge – Case Study #1](https://8weeksqlchallenge.com/case-study-1/)  
- ER Diagram created using [dbdiagram.io](https://dbdiagram.io)

---

## ✨ Author

**Sumit Kumar**  
📎 [GitHub Profile](https://github.com/suku-na)  
📂 [Project Repository](https://github.com/suku-na/SQL-PROJECTS/tree/main/8-Week-Challenge/Dannys-Dinner)
