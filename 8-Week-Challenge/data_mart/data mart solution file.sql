#Data Mart - Data Cleansing Steps
#In a single query, perform the following operations and generate a new table in the data_mart schema named clean_weekly_sales:
#Convert the week_date to a DATE format
#Add a week_number as the second column for each week_date value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc
#Add a month_number with the calendar month for each week_date value as the 3rd column
#Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values
#Add a new column called age_band after the original segment column using the following mapping on the number inside the segment value
#Add a new demographic column using the following mapping for the first letter in the segment values
#Ensure all null string values with an "unknown" string value in the original segment column as well as the new age_band and demographic columns
#Generate a new avg_transaction column as the sales value divided by transactions rounded to 2 decimal places for each record 

CREATE TABLE data_mart.clean_weekly_sales
  (WITH date_cte AS
     (SELECT *,
             str_to_date(week_date, '%d/%m/%Y') AS formatted_date
      FROM weekly_sales) SELECT formatted_date AS week_date,
                                extract(WEEK
                                        FROM formatted_date) week_number,
                                extract(MONTH
                                        FROM formatted_date) month_number,
                                extract(YEAR
                                        FROM formatted_date) calendar_year,
                                SEGMENT,
                                CASE
                                    WHEN RIGHT(SEGMENT, 1) = '1' THEN 'Young Adults'
                                    WHEN RIGHT(SEGMENT, 1) = '2' THEN 'Middle Aged'
                                    WHEN RIGHT(SEGMENT, 1) in ('3',
                                                               '4') THEN 'Retirees'
                                    ELSE 'unknown'
                                END AS age_band,
                                CASE
                                    WHEN LEFT(SEGMENT, 1) = 'C' THEN 'Couples'
                                    WHEN LEFT(SEGMENT, 1) = 'F' THEN 'Families'
                                    ELSE 'unknown'
                                END AS demographic,
                                ROUND(sales/transactions, 2) avg_transaction,
                                region,
                                platform,
                                customer_type,
                                sales,
                                transactions
   FROM date_cte);
   
   SELECT *FROM clean_weekly_sales;
   DESC clean_weekly_sales;
   
   #Part B .Data Exploration
   #1. What day of the week is used for each week_date value?
SELECT DISTINCT dayname(week_date) AS day_of_week
FROM clean_weekly_sales;

#2. What range of week numbers are missing from the dataset?
#To get the current value of default_week_format variable : SHOW VARIABLES LIKE 'default_week_format';
-- Range 0 to 52

SELECT DISTINCT week(week_date) AS week_number
FROM clean_weekly_sales
ORDER BY week(week_date) ASC;

#3. How many total transactions were there for each year in the dataset?
SELECT year(week_date) AS YEAR,
       sum(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY year(week_date)
ORDER BY 1;

#4. What is the total sales for each region for each month?
SELECT region,
       month_number,
       monthname(week_date) as month_name,
       sum(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY region,month_number,month_name
ORDER BY 1,2;

#5. What is the total count of transactions for each platform
SELECT platform,
       sum(transactions) AS transactions_count
FROM clean_weekly_sales
GROUP BY 1;

#6. What is the percentage of sales for Retail vs Shopify for each month?

#Using GROUP BY and WINDOW FUNCTION

WITH sales_contribution_cte AS
  (SELECT calendar_year,
          month_number,
          platform,
          sum(sales) AS sales_contribution
   FROM clean_weekly_sales
   GROUP BY 1,
            2,
            3
   ORDER BY 1,
            2),
     total_sales_cte AS
  (SELECT *,
          sum(sales_contribution) over(PARTITION BY calendar_year, month_number) AS total_sales
   FROM sales_contribution_cte)
SELECT calendar_year,
       month_number,
       ROUND(sales_contribution/total_sales*100, 2) AS retail_percent,
       100-ROUND(sales_contribution/total_sales*100, 2) AS shopify_percent
FROM total_sales_cte
WHERE platform = "Retail"
ORDER BY 1,2;

#Using GROUP BY AND CASE statements

WITH sales_cte AS
  (SELECT calendar_year,
          month_number,
          SUM(CASE
                  WHEN platform="Retail" THEN sales
              END) AS retail_sales,
          SUM(CASE
                  WHEN platform="Shopify" THEN sales
              END) AS shopify_sales,
          sum(sales) AS total_sales
   FROM clean_weekly_sales
   GROUP BY 1,
            2
   ORDER BY 1,
            2)
SELECT calendar_year,
       month_number,
       ROUND(retail_sales/total_sales*100, 2) AS retail_percent,
       ROUND(shopify_sales/total_sales*100, 2) AS shopify_percent
FROM sales_cte;

#7. What is the percentage of sales by demographic for each year in the dataset?
WITH sales_contribution_cte AS
  (SELECT calendar_year,
          demographic,
          sum(sales) AS sales_contribution
   FROM clean_weekly_sales
   GROUP BY 1,
            2
   ORDER BY 1),
     total_sales_cte AS
  (SELECT *,
          sum(sales_contribution) over(PARTITION BY calendar_year) AS total_sales
   FROM sales_contribution_cte)
SELECT calendar_year,
       demographic,
       ROUND(100*sales_contribution/total_sales, 2) AS percent_sales_contribution
FROM total_sales_cte
GROUP BY 1,2;

#8. Which age_band and demographic values contribute the most to Retail sales?
SELECT age_band,
       demographic,
       ROUND(100*sum(sales)/
               (SELECT SUM(sales)
                FROM clean_weekly_sales
                WHERE platform="Retail"), 2) AS retail_sales_percentage
FROM clean_weekly_sales
WHERE platform="Retail"
GROUP BY 1,
         2
ORDER BY 3 DESC;

#9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
#Let's try this mathematically. Consider average of (4,4,4,4,4,4) = (4*6)/6 = 4 and average(5) = 5 Average of averages = (4+5)/2 = 4.5 Average of all numbers = (24+5)/ = 4.1428
#Hence, we can not use avg_transaction column to find the average transaction size for each year and sales platform, because the result will be incorrect if we calculate average of an average to calculate the average.

SELECT calendar_year,
       platform,
       ROUND(SUM(sales)/SUM(transactions), 2) AS correct_avg,
       ROUND(AVG(avg_transaction), 2) AS incorrect_avg
FROM clean_weekly_sales
GROUP BY 1,
         2
ORDER BY 1,
         2;
