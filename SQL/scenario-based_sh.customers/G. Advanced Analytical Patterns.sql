-- G. Advanced Analytical Patterns (10 Questions)

-- 1.Compute z-score normalization of customer credit limits.

SELECT cust_id,
       cust_first_name,
       cust_last_name,
       cust_credit_limit,
       ROUND((cust_credit_limit - AVG(cust_credit_limit) OVER ()) /
             STDDEV(cust_credit_limit) OVER (), 2) AS z_score
FROM sh.customers;

-- 2.Calculate the Gini coefficient of credit limit inequality per country.

WITH country_credit AS (
    SELECT country_id,
           cust_id,
           cust_credit_limit
    FROM sh.customers
),
ranked AS (
    SELECT country_id,
           cust_id,
           cust_credit_limit,
           SUM(cust_credit_limit) OVER (PARTITION BY country_id ORDER BY cust_credit_limit ASC
                                        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_credit,
           SUM(cust_credit_limit) OVER (PARTITION BY country_id) AS total_credit,
           ROW_NUMBER() OVER (PARTITION BY country_id ORDER BY cust_credit_limit ASC) AS rn,
           COUNT(*) OVER (PARTITION BY country_id) AS total_customers
    FROM country_credit
)
SELECT country_id,
       ROUND(1 - SUM(cum_credit / total_credit) / MAX(total_customers), 4) AS gini_coeff
FROM ranked
GROUP BY country_id;


-- 3.Find customers whose credit limit is above the 75th percentile and below the 90th percentile.

WITH percentiles AS (
    SELECT 
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY cust_credit_limit) AS p75,
        PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY cust_credit_limit) AS p90
    FROM sh.customers
)
SELECT c.cust_id,
       c.cust_first_name,
       c.cust_last_name,
       c.cust_credit_limit
FROM sh.customers c
CROSS JOIN percentiles p
WHERE c.cust_credit_limit > p.p75
  AND c.cust_credit_limit < p.p90
ORDER BY c.cust_credit_limit;

-- 4.Use analytical functions to compute the rank difference between two states.

WITH state_ranks AS (
    SELECT cust_state_province,
           cust_id,
           cust_first_name,
           cust_last_name,
           SUM(cust_credit_limit) AS total_credit,
           RANK() OVER (PARTITION BY cust_state_province ORDER BY SUM(cust_credit_limit) DESC) AS state_rank
    FROM sh.customers
    GROUP BY cust_state_province, cust_id, cust_first_name, cust_last_name
)
SELECT a.cust_id,
       a.cust_first_name,
       a.cust_last_name,
       a.state_rank AS rank_state1,
       b.state_rank AS rank_state2,
       ABS(a.state_rank - b.state_rank) AS rank_diff
FROM state_ranks a
JOIN state_ranks b ON a.cust_id = b.cust_id
WHERE a.cust_state_province = 'State1'
  AND b.cust_state_province = 'State2';


-- 5.Find the median and interquartile range of credit limit per state.

SELECT cust_state_province,
       PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY cust_credit_limit) AS median_credit,
       PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY cust_credit_limit) -
       PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY cust_credit_limit) AS iqr_credit
FROM sh.customers
GROUP BY cust_state_province
ORDER BY cust_state_province;

-- 6.Identify outliers in credit limit using IQR method.

WITH stats AS (
    SELECT cust_state_province,
           PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY cust_credit_limit) AS q1,
           PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY cust_credit_limit) AS q3
    FROM sh.customers
    GROUP BY cust_state_province
)
SELECT c.cust_id,
       c.cust_first_name,
       c.cust_last_name,
       c.cust_credit_limit,
       s.cust_state_province
FROM sh.customers c
JOIN stats s ON c.cust_state_province = s.cust_state_province
WHERE c.cust_credit_limit < s.q1 - 1.5 * (s.q3 - s.q1)
   OR c.cust_credit_limit > s.q3 + 1.5 * (s.q3 - s.q1)
ORDER BY c.cust_state_province, c.cust_credit_limit;

-- 7.Calculate credit limit growth per customer over years (if historical data exists).

SELECT c.cust_id,
       c.cust_first_name,
       c.cust_last_name,
       EXTRACT(YEAR FROM s.time_id) AS year,
       SUM(s.amount_sold) AS total_sales,
       LAG(SUM(s.amount_sold)) OVER (PARTITION BY c.cust_id ORDER BY EXTRACT(YEAR FROM s.time_id)) AS prev_year_sales,
       SUM(s.amount_sold) - LAG(SUM(s.amount_sold)) OVER (PARTITION BY c.cust_id ORDER BY EXTRACT(YEAR FROM s.time_id)) AS growth
FROM sh.sales s
JOIN sh.customers c ON c.cust_id = s.cust_id
GROUP BY c.cust_id, c.cust_first_name, c.cust_last_name, EXTRACT(YEAR FROM s.time_id)
ORDER BY c.cust_id, year;

-- 8.Create a running average of credit limit by customer ID.

SELECT cust_id,
       cust_first_name,
       cust_last_name,
       cust_credit_limit,
       AVG(cust_credit_limit) OVER (PARTITION BY cust_id ORDER BY cust_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_avg
FROM sh.customers
ORDER BY cust_id;

-- 9.Compute total cumulative credit per income group sorted by rank.

SELECT cust_income_level,
       cust_id,
       cust_credit_limit,
       SUM(cust_credit_limit) OVER (PARTITION BY cust_income_level ORDER BY cust_credit_limit ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_credit
FROM sh.customers
ORDER BY cust_income_level, cust_credit_limit;

-- 10.Generate a leaderboard view showing top N customers dynamically using analytic functions.

SELECT *
FROM (
    SELECT c.cust_id,
           c.cust_first_name,
           c.cust_last_name,
           SUM(s.amount_sold) AS total_sales,
           RANK() OVER (ORDER BY SUM(s.amount_sold) DESC) AS sales_rank
    FROM sh.customers c
    JOIN sh.sales s ON c.cust_id = s.cust_id
    GROUP BY c.cust_id, c.cust_first_name, c.cust_last_name
)
WHERE sales_rank <= 10   -- Change N here for top N customers
ORDER BY sales_rank;