--B. Analytical / Window Functions (30 Questions)

desc sh.CUSTOMERS;
select * from sh.CUSTOMERS;

-- 1. Assign row numbers to customers ordered by credit limit descending.
SELECT cust_id, cust_first_name, cust_last_name, cust_credit_limit,
       ROW_NUMBER() OVER (ORDER BY cust_credit_limit DESC) AS row_num
FROM sh.customers;

-- 2. Rank customers within each state by credit limit.
SELECT cust_id, cust_state_province, cust_credit_limit,
       RANK() OVER (PARTITION BY cust_state_province ORDER BY cust_credit_limit DESC) AS state_rank
FROM sh.customers;

-- 3. Use DENSE_RANK() to find the top 5 credit holders per country.
SELECT * FROM (
  SELECT cust_id, country_id, cust_credit_limit,
         DENSE_RANK() OVER (PARTITION BY country_id ORDER BY cust_credit_limit DESC) AS rnk
  FROM sh.customers
)
WHERE rnk <= 5;

-- 4. Divide customers into 4 quartiles based on their credit limit using NTILE(4).
SELECT cust_id, cust_credit_limit,
       NTILE(4) OVER (ORDER BY cust_credit_limit DESC) AS quartile
FROM sh.customers;

-- 5. Calculate a running total of credit limits ordered by customer_id.
SELECT cust_id, cust_credit_limit,
       SUM(cust_credit_limit) OVER (ORDER BY cust_id) AS running_total
FROM sh.customers;

-- 6. Show cumulative average credit limit by country.
SELECT country_id, cust_id, cust_credit_limit,
       AVG(cust_credit_limit) OVER (PARTITION BY country_id ORDER BY cust_id) AS cumulative_avg
FROM sh.customers;

-- 7. Compare each customer’s credit limit to the previous one using LAG().
SELECT cust_id, cust_credit_limit,
       LAG(cust_credit_limit) OVER (ORDER BY cust_id) AS prev_credit_limit
FROM sh.customers;

-- 8. Show next customer’s credit limit using LEAD().
SELECT cust_id, cust_credit_limit,
       LEAD(cust_credit_limit) OVER (ORDER BY cust_id) AS next_credit_limit
FROM sh.customers;

-- 9. Display the difference between each customer’s credit limit and the previous one.
SELECT cust_id, cust_credit_limit,
       cust_credit_limit - LAG(cust_credit_limit) OVER (ORDER BY cust_id) AS diff_prev
FROM sh.customers;

-- 10. For each country, display the first and last credit limit.
SELECT cust_id, country_id, cust_credit_limit,
       FIRST_VALUE(cust_credit_limit) OVER (PARTITION BY country_id ORDER BY cust_credit_limit ASC) AS first_credit,
       LAST_VALUE(cust_credit_limit) OVER (PARTITION BY country_id ORDER BY cust_credit_limit ASC
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_credit
FROM sh.customers;

-- 11. Compute percentage rank (PERCENT_RANK()) based on credit limit.
SELECT cust_id, cust_credit_limit,
       PERCENT_RANK() OVER (ORDER BY cust_credit_limit DESC) AS pct_rank
FROM sh.customers;

-- 12. Show each customer’s position in percentile (CUME_DIST()).
SELECT cust_id, cust_credit_limit,
       CUME_DIST() OVER (ORDER BY cust_credit_limit DESC) AS percentile_position
FROM sh.customers;

-- 13. Display the difference between the maximum and current credit limit.
SELECT cust_id, cust_credit_limit,
       MAX(cust_credit_limit) OVER () - cust_credit_limit AS diff_from_max
FROM sh.customers;

-- 14. Rank income levels by their average credit limit.

SELECT c.cust_id, c.cust_credit_limit, (m.max_credit - c.cust_credit_limit) AS diff_from_max
FROM sh.customers c
CROSS JOIN (
  SELECT MAX(cust_credit_limit) AS max_credit
  FROM sh.customers
) m;

-- 15. Average credit limit over the last 10 customers (sliding window).
SELECT cust_id, cust_credit_limit,
       AVG(cust_credit_limit) OVER (ORDER BY cust_id ROWS BETWEEN 9 PRECEDING AND CURRENT ROW) AS moving_avg_10
FROM sh.customers;

-- 16. For each state, cumulative total of credit limits ordered by city.
SELECT cust_state_province, cust_city, cust_id, cust_credit_limit,
       SUM(cust_credit_limit) OVER (PARTITION BY cust_state_province ORDER BY cust_city) AS cumulative_state_total
FROM sh.customers;

-- 17. Find customers whose credit limit equals the median credit limit (use PERCENTILE_CONT(0.5)).
SELECT cust_id, cust_credit_limit
FROM sh.customers
WHERE cust_credit_limit = (
  SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY cust_credit_limit) FROM sh.customers
);

-- 18. Top 3 credit holders per state using ROW_NUMBER() and PARTITION BY..
SELECT * FROM (
  SELECT cust_id, cust_state_province, cust_credit_limit,
         ROW_NUMBER() OVER (PARTITION BY cust_state_province ORDER BY cust_credit_limit DESC) AS rn
  FROM sh.customers
)
WHERE rn <= 3;

-- 19. Customers whose credit limit increased compared to previous (LAG).
SELECT cust_id, cust_credit_limit,
       CASE WHEN cust_credit_limit > LAG(cust_credit_limit) OVER (ORDER BY cust_id) THEN 'Increased' ELSE 'Not Increased' END AS status
FROM sh.customers;

-- 20. Moving average of credit limits with a window of 3.
SELECT cust_id, cust_credit_limit,
       AVG(cust_credit_limit) OVER (ORDER BY cust_id ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg_3
FROM sh.customers;

-- 21. Cumulative percentage of total credit limit per country.
SELECT country_id, cust_id, cust_credit_limit,
       SUM(cust_credit_limit) OVER (PARTITION BY country_id ORDER BY cust_credit_limit DESC) /
       SUM(cust_credit_limit) OVER (PARTITION BY country_id) AS cumulative_pct
FROM sh.customers;

-- 22. Rank customers by age (derived from year of birth).
SELECT cust_id, cust_year_of_birth,
       RANK() OVER (ORDER BY cust_year_of_birth) AS age_rank
FROM sh.customers;

-- 23. Difference in age between current and previous customer in same state.
SELECT cust_id, cust_state_province, cust_year_of_birth,
       cust_year_of_birth - LAG(cust_year_of_birth) OVER (PARTITION BY cust_state_province ORDER BY cust_id) AS diff_age
FROM sh.customers;

-- 24. Show how ties are treated differently by RANK() and DENSE_RANK().
SELECT cust_id, cust_credit_limit,
       RANK() OVER (ORDER BY cust_credit_limit DESC) AS rnk,
       DENSE_RANK() OVER (ORDER BY cust_credit_limit DESC) AS dense_rnk
FROM sh.customers;

-- 25. Compare each state’s average credit limit with country average.
SELECT country_id, cust_state_province,
       AVG(cust_credit_limit) OVER (PARTITION BY cust_state_province) AS avg_state,
       AVG(cust_credit_limit) OVER (PARTITION BY country_id) AS avg_country
FROM sh.customers;

-- 26. Total credit per state and rank within country.
SELECT country_id, cust_state_province,
       SUM(cust_credit_limit) AS total_credit,
       RANK() OVER (PARTITION BY country_id ORDER BY SUM(cust_credit_limit) DESC) AS state_rank
FROM sh.customers
GROUP BY country_id, cust_state_province;

-- 27. Customers above the 90th percentile of their income level.
SELECT cust_id, cust_income_level, cust_credit_limit
FROM sh.customers c
WHERE cust_credit_limit > (
  SELECT PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY cust_credit_limit)
  FROM sh.customers s
  WHERE s.cust_income_level = c.cust_income_level
);

-- 28. Top 3 and bottom 3 customers per country by credit limit.
SELECT * FROM (
  SELECT cust_id, country_id, cust_credit_limit,
         ROW_NUMBER() OVER (PARTITION BY country_id ORDER BY cust_credit_limit DESC) AS top_rn,
         ROW_NUMBER() OVER (PARTITION BY country_id ORDER BY cust_credit_limit ASC) AS bottom_rn
  FROM sh.customers
)
WHERE top_rn <= 3 OR bottom_rn <= 3;

-- 29. Rolling sum of 5 customers’ credit limit within each country.
SELECT cust_id, country_id, cust_credit_limit,
       SUM(cust_credit_limit) OVER (PARTITION BY country_id ORDER BY cust_id ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS rolling_sum_5
FROM sh.customers;

-- 30. For each marital status, most and least wealthy customers.
SELECT cust_marital_status, cust_id, cust_credit_limit,
       FIRST_VALUE(cust_id) OVER (PARTITION BY cust_marital_status ORDER BY cust_credit_limit DESC) AS richest_customer,
       LAST_VALUE(cust_id) OVER (PARTITION BY cust_marital_status ORDER BY cust_credit_limit DESC
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS least_customer
FROM sh.customers;