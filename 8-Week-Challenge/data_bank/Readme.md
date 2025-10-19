<h1 align="center">🏦 Data Bank SQL Case Study</h1>
<p align="center">
  <i>Part of the <a href="https://8weeksqlchallenge.com/">8 Week SQL Challenge</a></i><br>
  <b>Case Study – Data Bank</b>
</p>

---

## 🧰 Tech Stack
<p align="center">
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/mysql/mysql-original-wordmark.svg" width="60" alt="MySQL"/>
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/vscode/vscode-original.svg" width="50" alt="VS Code"/>
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/github/github-original.svg" width="50" alt="GitHub"/>
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/linux/linux-original.svg" width="50" alt="Linux"/>
  <img src="https://upload.wikimedia.org/wikipedia/commons/7/7f/Microsoft_Office_Excel_%282019–present%29.svg" width="50" alt="Excel"/>
</p>

---

## 📘 Overview
**Data Bank** is a financial dataset tracking customer nodes, transactions, and regional data in a banking system.  
This study delves into **customer journeys, node allocation timings, transaction behaviors, and regional financial activity** to inform business insights and decision-making.

---

## 🧩 Entity Relationship Diagram (ERD)
*(Add ERD image here if available)*

| Table                 | Description                                                                                  |
|-----------------------|----------------------------------------------------------------------------------------------|
| **customer_nodes**        | Tracks customer node allocations with node IDs, region IDs, start and end dates             |
| **customer_transactions** | Contains transactional data including deposits, withdrawals, purchases, their amounts, and dates |
| **regions**               | Lists all the regions with IDs and names related to customer nodes                           |

---

## 💡 Business Questions & SQL Solutions
All queries from [`data-bank-solution-file.sql`](./data-bank-solution-file.sql)

### 1️⃣ How many unique nodes are there on the system?
```sql
SELECT count(DISTINCT node_id) AS unique_nodes
FROM customer_nodes;
```
### 2️⃣ Nodes per region and customers per region
```sql
SELECT region_id, region_name, count(node_id) AS node_count
FROM customer_nodes
INNER JOIN regions USING(region_id)
GROUP BY region_id, region_name;

SELECT region_id, region_name, count(DISTINCT customer_id) AS customer_count
FROM customer_nodes
INNER JOIN regions USING(region_id)
GROUP BY region_id, region_name;
```

### 3️⃣ Average days for customer node reallocation?
```sql
SELECT round(avg(datediff(end_date, start_date)), 2) AS avg_days
FROM customer_nodes
WHERE end_date != '9999-12-31';
```

### 4️⃣ Transaction type counts and amounts
```sql
SELECT txn_type, count(*) AS unique_count, sum(txn_amount) AS total_amount
FROM customer_transactions
GROUP BY txn_type;
```

### 5️⃣ Average deposit counts and amounts
```sql
SELECT round(count(customer_id)/
(SELECT count(DISTINCT customer_id) FROM customer_transactions)) AS average_deposit_count,
concat('$', round(avg(txn_amount), 2)) AS average_deposit_amount
FROM customer_transactions
WHERE txn_type = 'deposit';
```

### 6️⃣ Monthly activity of customers with multiple deposits and withdrawals or purchases
```sql
WITH transaction_count_per_month_cte AS (
SELECT customer_id,
month(txn_date) AS txn_month,
SUM(IF(txn_type='deposit', 1, 0)) AS deposit_count,
SUM(IF(txn_type='withdrawal', 1, 0)) AS withdrawal_count,
SUM(IF(txn_type='purchase', 1, 0)) AS purchase_count
FROM customer_transactions
GROUP BY customer_id, month(txn_date)
)
SELECT txn_month, count(DISTINCT customer_id) AS customer_count
FROM transaction_count_per_month_cte
WHERE deposit_count > 1
AND (purchase_count = 1 OR withdrawal_count = 1)
GROUP BY txn_month;
```

### 7️⃣ Closing balance per customer by month
```sql
WITH txn_monthly_balance_cte AS (
SELECT customer_id,
txn_amount,
month(txn_date) AS txn_month,
SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount ELSE -txn_amount END) AS net_transaction_amt
FROM customer_transactions
GROUP BY customer_id, txn_amount, month(txn_date)
ORDER BY customer_id
)
SELECT customer_id,
txn_month,
net_transaction_amt,
sum(net_transaction_amt) OVER (PARTITION BY customer_id ORDER BY txn_month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS closing_balance
FROM txn_monthly_balance_cte;
```

---

## 📊 Key Insights
- Customer node and regional distributions reveal service reach and customer allocation.  
- Transaction summaries highlight deposit dominance and varied financial activity.  
- Reallocation timing metrics provide a view on customer movement through nodes.  
- Monthly transaction patterns show active engaged customers with multiple transaction types.  
- Closing balances track customer financial health trends over time.

---

## 📂 Repository Structure
```
📁 Data Bank
│
├── data-bank-solution-file.sql
└── README.md
```


---

## 🔗 References
- 8 Week SQL Challenge — [https://8weeksqlchallenge.com/](https://8weeksqlchallenge.com/)

---

## ✨ Author
**Sumit Kumar**  
📎 [GitHub Profile](https://github.com/suku-na)  
📂 [Project Repository](https://github.com/suku-na/SQL-PROJECTS/edit/main/8-Week-Challenge/data_bank)
---

<h3 align="center">⚡ “Data tells a story — and SQL helps us read it better.” ⚡</h3>
<p align="center">
  <em>Thank you for exploring this project — feel free to check my other SQL case studies!</em>
</p>





