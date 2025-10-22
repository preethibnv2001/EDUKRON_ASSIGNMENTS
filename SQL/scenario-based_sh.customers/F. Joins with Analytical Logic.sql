-- F. Joins with Analytical Logic (10 Questions)

-- 1.Join SH.CUSTOMERS and SH.SALES to find customers with the highest sales totals.

SELECT c.cust_id,
       c.cust_first_name,
       c.cust_last_name,
       SUM(s.amount_sold) AS total_sales
FROM sh.customers c
JOIN sh.sales s ON c.cust_id = s.cust_id
GROUP BY c.cust_id, c.cust_first_name, c.cust_last_name
ORDER BY total_sales DESC;

-- 2.For each customer, show their total sales amount and their rank within country.

SELECT c.country_id,
       c.cust_id,
       c.cust_first_name,
       c.cust_last_name,
       SUM(s.amount_sold) AS total_sales,
       RANK() OVER (PARTITION BY c.country_id ORDER BY SUM(s.amount_sold) DESC) AS sales_rank
FROM sh.customers c
JOIN sh.sales s ON c.cust_id = s.cust_id
GROUP BY c.country_id, c.cust_id, c.cust_first_name, c.cust_last_name;

-- 3.Find customers who purchased more than average sales amount of their country.

SELECT cust_id,
       cust_first_name,
       cust_last_name,
       country_id,
       total_sales
FROM (
  SELECT c.cust_id,
         c.cust_first_name,
         c.cust_last_name,
         c.country_id,
         SUM(s.amount_sold) AS total_sales,
         AVG(SUM(s.amount_sold)) OVER (PARTITION BY c.country_id) AS avg_country_sales
  FROM sh.customers c
  JOIN sh.sales s ON c.cust_id = s.cust_id
  GROUP BY c.cust_id, c.cust_first_name, c.cust_last_name, c.country_id
)
WHERE total_sales > avg_country_sales;

-- 4.Display top 3 spenders per state.

SELECT * FROM (
  SELECT c.cust_state_province,
         c.cust_id,
         c.cust_first_name,
         c.cust_last_name,
         SUM(s.amount_sold) AS total_sales,
         DENSE_RANK() OVER (PARTITION BY c.cust_state_province ORDER BY SUM(s.amount_sold) DESC) AS state_rank
  FROM sh.customers c
  JOIN sh.sales s ON c.cust_id = s.cust_id
  GROUP BY c.cust_state_province, c.cust_id, c.cust_first_name, c.cust_last_name
)
WHERE state_rank <= 3;

-- 5.Rank customers within each country by total sales quantity.

SELECT c.country_id,
       c.cust_id,
       c.cust_first_name,
       c.cust_last_name,
       SUM(s.quantity_sold) AS total_qty,
       RANK() OVER (PARTITION BY c.country_id ORDER BY SUM(s.quantity_sold) DESC) AS qty_rank
FROM sh.customers c
JOIN sh.sales s ON c.cust_id = s.cust_id
GROUP BY c.country_id, c.cust_id, c.cust_first_name, c.cust_last_name;

-- 6.Calculate each customer’s contribution percentage to country-level sales.

SELECT c.country_id,
       c.cust_id,
       c.cust_first_name,
       c.cust_last_name,
       SUM(s.amount_sold) AS total_sales,
       ROUND(RATIO_TO_REPORT(SUM(s.amount_sold)) OVER (PARTITION BY c.country_id) * 100, 2) AS pct_contribution
FROM sh.customers c
JOIN sh.sales s ON c.cust_id = s.cust_id
GROUP BY c.country_id, c.cust_id, c.cust_first_name, c.cust_last_name;

-- 7.Identify customers whose sales have decreased compared to previous month.

SELECT *
FROM (
  SELECT c.cust_id,
         c.cust_first_name,
         c.cust_last_name,
         TRUNC(s.time_id, 'MM') AS sales_month,
         SUM(s.amount_sold) AS total_sales,
         LAG(SUM(s.amount_sold)) OVER (PARTITION BY c.cust_id ORDER BY TRUNC(s.time_id, 'MM')) AS prev_month_sales
  FROM sh.customers c
  JOIN sh.sales s ON c.cust_id = s.cust_id
  GROUP BY c.cust_id, c.cust_first_name, c.cust_last_name, TRUNC(s.time_id, 'MM')
)
WHERE total_sales < prev_month_sales
ORDER BY cust_id, sales_month;

-- 8.Show customers who have never made a sale.

SELECT c.cust_id,
       c.cust_first_name,
       c.cust_last_name
FROM sh.customers c
LEFT JOIN sh.sales s ON c.cust_id = s.cust_id
WHERE s.cust_id IS NULL;

-- 9.Find correlation between credit limit and total sales (using GROUP BY + analytics).

SELECT c.cust_id,
       c.cust_first_name,
       c.cust_last_name,
       c.cust_credit_limit,
       SUM(s.amount_sold) AS total_sales,
       ROUND(AVG(SUM(s.amount_sold)) OVER (), 2) AS avg_total_sales
FROM sh.customers c
JOIN sh.sales s ON c.cust_id = s.cust_id
GROUP BY c.cust_id, c.cust_first_name, c.cust_last_name, c.cust_credit_limit;

-- 10.Show moving average of monthly sales per customer.

SELECT cust_id,
       cust_first_name,
       cust_last_name,
       sales_month,
       total_sales,
       ROUND(AVG(total_sales) OVER (PARTITION BY cust_id ORDER BY sales_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS moving_avg_3_months
FROM (
  SELECT c.cust_id,
         c.cust_first_name,
         c.cust_last_name,
         TRUNC(s.time_id, 'MM') AS sales_month,
         SUM(s.amount_sold) AS total_sales
  FROM sh.customers c
  JOIN sh.sales s ON c.cust_id = s.cust_id
  GROUP BY c.cust_id, c.cust_first_name, c.cust_last_name, TRUNC(s.time_id, 'MM')
)
ORDER BY cust_id, sales_month;