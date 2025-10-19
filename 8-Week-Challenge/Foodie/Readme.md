<h1 align="center">🍽️ Foodie-Fi SQL Case Study</h1>

<p align="center">
  <i>Part of the <a href="https://8weeksqlchallenge.com/">8 Week SQL Challenge</a> by Danny Ma</i><br>
  <b>Case Study #3 – Foodie-Fi</b>
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
**Foodie-Fi** is a subscription-based streaming platform for food enthusiasts 🍕🍣🍔.  
Danny wants to understand **customer behavior, subscription changes, churn patterns, and revenue** to guide business decisions.  
This project analyzes subscription lifecycle data to uncover actionable insights.

---

## 🧩 Entity Relationship Diagram (ERD)
<p align="center">
  <img src="./foodie_fi_ER.png" alt="Foodie-Fi ER Diagram" width="500"/>
</p>

| Table | Description |
|:--|:--|
| **plans** | Contains plan details (`plan_id`, `plan_name`, `price`) |
| **subscriptions** | Records customers' plan start dates and transitions |
| **customers** | Optional table with customer details |

---

## 💡 Business Questions & SQL Solutions
All queries are from [`foodie_fi.sql`](./foodie_fi.sql). Below are the questions and SQL solutions.

### 1️⃣ How many customers have ever subscribed to Foodie-Fi?
```sql
SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM subscriptions;

### 2️⃣ What is the distribution of customers across different plan types?
```sql
SELECT p.plan_name, COUNT(s.customer_id) AS total_customers
FROM subscriptions s
JOIN plans p ON s.plan_id = p.plan_id
GROUP BY p.plan_name
ORDER BY total_customers DESC;

