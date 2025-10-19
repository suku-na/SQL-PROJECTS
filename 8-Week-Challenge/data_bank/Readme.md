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

