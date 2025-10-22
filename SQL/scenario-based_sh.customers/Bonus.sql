-- Bonus: Scenario-Based SQL on SH.CUSTOMERS

-- 1.Display the top 5 customers with the highest credit limit.

SELECT *
FROM sh.customers
ORDER BY cust_credit_limit DESC
FETCH FIRST 5 ROWS ONLY;

-- 2.Find customers having the same income level as the customer with the maximum credit limit.

SELECT *
FROM sh.customers
WHERE cust_income_level IN (
    SELECT cust_income_level
    FROM sh.customers
    WHERE cust_credit_limit = (SELECT MAX(cust_credit_limit) FROM sh.customers)
);

-- 3.Display customers who have a credit limit higher than the average credit limit of all customers.

SELECT *
FROM sh.customers
WHERE cust_credit_limit > (SELECT AVG(cust_credit_limit) FROM sh.customers);

-- 4.Rank all customers based on their credit limit in descending order and display rank along with name.

SELECT cust_id,
       cust_first_name,
       cust_last_name,
       cust_credit_limit,
       RANK() OVER (ORDER BY cust_credit_limit DESC) AS credit_rank
FROM sh.customers;

-- 5.Find customers who belong to the top 3 credit limit ranks in each income level.

SELECT cust_id,
       cust_first_name,
       cust_last_name,
       cust_income_level,
       cust_credit_limit
FROM (
    SELECT cust_id,
           cust_first_name,
           cust_last_name,
           cust_income_level,
           cust_credit_limit,
           RANK() OVER (PARTITION BY cust_income_level ORDER BY cust_credit_limit DESC) AS rank_in_income
    FROM sh.customers
)
WHERE rank_in_income <= 3
ORDER BY cust_income_level, rank_in_income;

-- 6.Categorize customers into “Platinum”, “Gold”, and “Standard” tiers based on their credit limit ranges.

SELECT cust_id,
       cust_first_name,
       cust_last_name,
       cust_credit_limit,
       CASE 
           WHEN cust_credit_limit >= 70000 THEN 'Platinum'
           WHEN cust_credit_limit >= 40000 THEN 'Gold'
           ELSE 'Standard'
       END AS tier
FROM sh.customers
ORDER BY cust_credit_limit DESC;

-- 7.Display each customer’s credit limit along with the previous and next customer’s limit (using LAG and LEAD).

SELECT cust_id,
       cust_first_name,
       cust_last_name,
       cust_credit_limit,
       LAG(cust_credit_limit) OVER (ORDER BY cust_credit_limit DESC) AS prev_limit,
       LEAD(cust_credit_limit) OVER (ORDER BY cust_credit_limit DESC) AS next_limit
FROM sh.customers;

-- 8.Find customers whose credit limit difference from the previous customer is more than 10,000.

WITH limits AS (
    SELECT cust_id,
           cust_first_name,
           cust_last_name,
           cust_credit_limit,
           LAG(cust_credit_limit) OVER (ORDER BY cust_credit_limit DESC) AS prev_limit
    FROM sh.customers
)
SELECT *
FROM limits
WHERE cust_credit_limit - prev_limit > 10000;

-- 9.Display the highest, lowest, and average credit limit per income level.

SELECT cust_income_level,
       MAX(cust_credit_limit) AS max_limit,
       MIN(cust_credit_limit) AS min_limit,
       AVG(cust_credit_limit) AS avg_limit
FROM sh.customers
GROUP BY cust_income_level;

-- 10.Find the youngest and oldest customers (based on CUST_YEAR_OF_BIRTH).

SELECT *
FROM sh.customers
WHERE cust_year_of_birth = (SELECT MIN(cust_year_of_birth) FROM sh.customers)
   OR cust_year_of_birth = (SELECT MAX(cust_year_of_birth) FROM sh.customers);

-- 11.Display customers who belong to the same city as the customer “David Lee”.

SELECT *
FROM sh.customers
WHERE cust_city = (SELECT cust_city FROM sh.customers WHERE cust_first_name='David' AND cust_last_name='Lee');

-- 12.For each state, display the top 2 customers by credit limit.

SELECT cust_id,
       cust_first_name,
       cust_last_name,
       cust_state_province,
       cust_credit_limit,
       state_rank
FROM (
    SELECT cust_id,
           cust_first_name,
           cust_last_name,
           cust_state_province,
           cust_credit_limit,
           RANK() OVER (PARTITION BY cust_state_province ORDER BY cust_credit_limit DESC) AS state_rank
    FROM sh.customers
)
WHERE state_rank <= 2
ORDER BY cust_state_province, state_rank;

-- 13.Show customers whose names start and end with the same letter.

SELECT *
FROM sh.customers
WHERE UPPER(SUBSTR(cust_first_name,1,1)) = UPPER(SUBSTR(cust_first_name,-1,1))
   OR UPPER(SUBSTR(cust_last_name,1,1)) = UPPER(SUBSTR(cust_last_name,-1,1));

-- 14.Create a ranking of customers within each country by credit limit.

SELECT cust_id,
       cust_first_name,
       cust_last_name,
       country_id,
       cust_credit_limit,
       RANK() OVER (PARTITION BY country_id ORDER BY cust_credit_limit DESC) AS country_rank
FROM sh.customers
ORDER BY country_id, country_rank;

-- 15.Find customers whose credit limit is below the minimum of their income category.

SELECT *
FROM sh.customers c
WHERE cust_credit_limit < (
    SELECT MIN(cust_credit_limit)
    FROM sh.customers
    WHERE cust_income_level = c.cust_income_level
);

-- 16.Display the percentage contribution of each customer’s credit limit compared to total credit limit of their country.

SELECT cust_id,
       cust_first_name,
       cust_last_name,
       country_id,
       cust_credit_limit,
       ROUND(RATIO_TO_REPORT(cust_credit_limit) OVER (PARTITION BY country_id) * 100,2) AS pct_contribution
FROM sh.customers;

-- 17.Split customers into 4 quartiles (Q1–Q4) based on their credit limit using NTILE(4).

SELECT cust_id,
       cust_first_name,
       cust_last_name,
       cust_credit_limit,
       NTILE(4) OVER (ORDER BY cust_credit_limit DESC) AS quartile
FROM sh.customers
ORDER BY quartile, cust_credit_limit DESC;

-- 18.Display customers whose last name has more than 7 characters and income level is “E: 90,000–109,999”.

SELECT *
FROM sh.customers
WHERE LENGTH(cust_last_name) > 7
  AND cust_income_level = 'E: 90,000–109,999';

-- 19.For each marital status, find the customer with the maximum credit limit.

SELECT cust_id,
       cust_first_name,
       cust_last_name,
       cust_marital_status,
       cust_credit_limit
FROM (
    SELECT cust_id,
           cust_first_name,
           cust_last_name,
           cust_marital_status,
           cust_credit_limit,
           RANK() OVER (PARTITION BY cust_marital_status ORDER BY cust_credit_limit DESC) AS rank_ms
    FROM sh.customers
)
WHERE rank_ms = 1
ORDER BY cust_marital_status;

-- 20.Identify customers whose credit limit equals the department average of their state (using analytical average).

SELECT *
FROM (
    SELECT c.*,
           AVG(cust_credit_limit) OVER (PARTITION BY cust_state_province) AS state_avg
    FROM sh.customers c
)
WHERE cust_credit_limit = state_avg;