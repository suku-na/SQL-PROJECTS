<h1 align="center">🛒 Data Mart SQL Case Study</h1>

<p align="center">
  <i>Part of the <a href="https://8weeksqlchallenge.com/">8 Week SQL Challenge</a> by Danny Ma</i><br>
  <b>Case Study #5 – Data Mart</b>
</p>

---

## 📘 Overview

**Data Mart** is a supermarket analytics case study that focuses on **data cleansing, transformation, and analysis of weekly sales data**.  
The goal is to clean the raw transactional data and derive meaningful insights related to **sales performance, customer demographics, and platform-based trends**.

This project demonstrates SQL proficiency in:
- Data cleaning and feature creation  
- Aggregations and analytical functions  
- Use of CTEs and window functions  

---

## 🧱 Database Schema

The schema creation and sample data are defined in this file 👉  
[`Data mart schema.sql`](https://github.com/Basavaraj0127/SQL-PROJECTS/blob/main/Data%20Mart/Data%20mart%20schema.sql)

*(Open it to view all CREATE TABLE and INSERT statements.)*

---

## 💡 Complete SQL Solutions

All the analytical SQL queries for this case study are in the solution file 👉  
[`data mart solution file.sql`](https://github.com/Basavaraj0127/SQL-PROJECTS/blob/main/Data%20Mart/data%20mart%20solution%20file.sql)


## A. Data Cleansing Steps

#### Create a cleaned version of the weekly_sales table with additional derived columns:
#### - week_number, month_number, calendar_year
#### - age_band, demographic, avg_transaction
```sql
CREATE TABLE data_mart.clean_weekly_sales AS
WITH date_cte AS (
  SELECT *,
         STR_TO_DATE(week_date, '%d/%m/%Y') AS formatted_date
  FROM weekly_sales
)
SELECT formatted_date AS week_date,
       EXTRACT(WEEK FROM formatted_date) AS week_number,
       EXTRACT(MONTH FROM formatted_date) AS month_number,
       EXTRACT(YEAR FROM formatted_date) AS calendar_year,
       segment,
       CASE 
         WHEN RIGHT(segment,1)='1' THEN 'Young Adults'
         WHEN RIGHT(segment,1)='2' THEN 'Middle Aged'
         WHEN RIGHT(segment,1) IN ('3','4') THEN 'Retirees'
         ELSE 'unknown' END AS age_band,
       CASE 
         WHEN LEFT(segment,1)='C' THEN 'Couples'
         WHEN LEFT(segment,1)='F' THEN 'Families'
         ELSE 'unknown' END AS demographic,
       ROUND(sales/transactions,2) AS avg_transaction,
       region, platform, customer_type, sales, transactions
FROM date_cte;
```

## B. Data Exploration

### 1. What day of the week is used for each week_date value?
```sql
SELECT DISTINCT DAYNAME(week_date) AS day_of_week
FROM clean_weekly_sales;
```

### 2. What range of week numbers are missing from the dataset?
```sql
SELECT DISTINCT WEEK(week_date) AS week_number
FROM clean_weekly_sales
ORDER BY week_number;
```

### 3. How many total transactions were there for each year?
```
SELECT YEAR(week_date) AS year, SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY year
ORDER BY year;
```

### 4. What is the total sales for each region for each month?
```sql
SELECT region, month_number, MONTHNAME(week_date) AS month_name, SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY region, month_number, month_name
ORDER BY 1,2;
```

### 5. What is the total count of transactions for each platform?
```sql
SELECT platform, SUM(transactions) AS transactions_count
FROM clean_weekly_sales
GROUP BY platform;
```

### 6. What is the percentage of sales for Retail vs Shopify for each month?
```sql
WITH sales_cte AS (
  SELECT calendar_year, month_number,
         SUM(CASE WHEN platform='Retail' THEN sales END) AS retail_sales,
         SUM(CASE WHEN platform='Shopify' THEN sales END) AS shopify_sales,
         SUM(sales) AS total_sales
  FROM clean_weekly_sales
  GROUP BY 1,2
)
SELECT calendar_year, month_number,
       ROUND(retail_sales/total_sales*100,2) AS retail_percent,
       ROUND(shopify_sales/total_sales*100,2) AS shopify_percent
FROM sales_cte;
```

### 7. What is the percentage of sales by demographic for each year?
```sql
WITH sales_contribution AS (
  SELECT calendar_year, demographic, SUM(sales) AS sales_contribution
  FROM clean_weekly_sales
  GROUP BY 1,2
),
total_sales AS (
  SELECT *, SUM(sales_contribution) OVER(PARTITION BY calendar_year) AS total_sales
  FROM sales_contribution
)
SELECT calendar_year, demographic,
       ROUND(100*sales_contribution/total_sales,2) AS percent_sales_contribution
FROM total_sales;
```

### 8. Which age_band and demographic values contribute the most to Retail sales?
```sql
SELECT age_band, demographic,
       ROUND(100*SUM(sales)/(SELECT SUM(sales)
                             FROM clean_weekly_sales
                             WHERE platform='Retail'),2) AS retail_sales_percentage
FROM clean_weekly_sales
WHERE platform='Retail'
GROUP BY age_band, demographic
ORDER BY 3 DESC;
```

### 9. Can we use avg_transaction to calculate average transaction size?
# No, averages of averages are inaccurate — correct method shown below:
```sql
SELECT calendar_year, platform,
       ROUND(SUM(sales)/SUM(transactions),2) AS correct_avg,
       ROUND(AVG(avg_transaction),2) AS incorrect_avg
FROM clean_weekly_sales
GROUP BY calendar_year, platform;
```

## 📂 Repository Structure
```
📁 Data Mart
└── README.md
├── Data mart schema.sql
├── data mart solution file.sql
```
---

## 🔗 References
- 8 Week SQL Challenge — [https://8weeksqlchallenge.com/](https://8weeksqlchallenge.com/)

---

## ✨ Author
**Sumit Kumar**  
📎 [GitHub Profile](https://github.com/suku-na)  
📂 [Project Repository](https://github.com/suku-na/SQL-PROJECTS/edit/main/8-Week-Challenge/data_mart)
---

<h3 align="center">⚡ “Data tells a story — and SQL helps us read it better.” ⚡</h3>
<p align="center">
  <em>Thank you for exploring this project — feel free to check my other SQL case studies!</em>
</p>
