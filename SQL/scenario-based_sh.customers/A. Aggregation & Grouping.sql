-- A. Aggregation & Grouping (20 Questions)

desc sh.customers;

-- 1.Find the total, average, minimum, and maximum credit limit of all customers.

SELECT 
    SUM(cust_credit_limit)   AS total_credit_limit,
    AVG(cust_credit_limit)   AS avg_credit_limit,
    MIN(cust_credit_limit)   AS min_credit_limit,
    MAX(cust_credit_limit)   AS max_credit_limit
FROM sh.customers;

-- 2.Count the number of customers in each income level.

SELECT 
    cust_income_level,
    COUNT(*) AS customer_count
FROM sh.customers
GROUP BY cust_income_level
ORDER BY cust_income_level;

-- 3.Show total credit limit by state and country.

SELECT 
    c.cust_state_province,
    co.country_name,
    SUM(c.cust_credit_limit) AS total_credit_limit
FROM sh.customers c
JOIN sh.countries co 
    ON c.country_id = co.country_id
GROUP BY 
    c.cust_state_province,
    co.country_name
ORDER BY 
    co.country_name,
    c.cust_state_province;

-- 4.Display average credit limit for each marital status and gender combination.

SELECT 
    cust_marital_status,
    cust_gender,
    AVG(cust_credit_limit) AS avg_credit_limit
FROM sh.customers
GROUP BY 
    cust_marital_status,
    cust_gender
ORDER BY 
    cust_marital_status,
    cust_gender;

-- 5.Find the top 3 states with the highest average credit limit.

SELECT 
    cust_state_province,
    AVG(cust_credit_limit) AS avg_credit_limit
FROM sh.customers
GROUP BY cust_state_province
ORDER BY avg_credit_limit DESC
FETCH FIRST 3 ROWS ONLY;

-- 6.Find the country with the maximum total customer credit limit.

SELECT country_name,
       SUM(cust_credit_limit) AS total_credit_limit
FROM sh.customers c
JOIN sh.countries co 
    ON c.country_id = co.country_id
GROUP BY country_name
ORDER BY total_credit_limit DESC
FETCH FIRST 1 ROW ONLY;

-- 7.Show the number of customers whose credit limit exceeds their state average.

SELECT COUNT(*) AS customers_above_state_avg
FROM sh.customers c
JOIN (
    SELECT cust_state_province, AVG(cust_credit_limit) AS state_avg
    FROM sh.customers
    GROUP BY cust_state_province
) state_avg_table
ON c.cust_state_province = state_avg_table.cust_state_province
WHERE c.cust_credit_limit > state_avg_table.state_avg;

-- 8.Calculate total and average credit limit for customers born after 1980.

SELECT 
    SUM(cust_credit_limit) AS total_credit_limit,
    AVG(cust_credit_limit) AS avg_credit_limit
FROM sh.customers
WHERE cust_year_of_birth > 1980;

-- 9.Find states having more than 50 customers.

SELECT 
    cust_state_province,
    COUNT(*) AS customer_count
FROM sh.customers
GROUP BY cust_state_province
HAVING COUNT(*) > 50
ORDER BY customer_count DESC;

-- 10.List countries where the average credit limit is higher than the global average.

SELECT co.country_name,
       AVG(c.cust_credit_limit) AS avg_credit_limit
FROM sh.customers c
JOIN sh.countries co
    ON c.country_id = co.country_id
GROUP BY co.country_name
HAVING AVG(c.cust_credit_limit) > (
    SELECT AVG(cust_credit_limit) 
    FROM sh.customers
)
ORDER BY avg_credit_limit DESC;

-- 11.Calculate the variance and standard deviation of customer credit limits by country.

SELECT 
    co.country_name,
    VARIANCE(c.cust_credit_limit) AS credit_variance,
    STDDEV(c.cust_credit_limit) AS credit_stddev
FROM sh.customers c
JOIN sh.countries co
    ON c.country_id = co.country_id
GROUP BY co.country_name
ORDER BY co.country_name;

-- 12.Find the state with the smallest range (max–min) in credit limits.

SELECT cust_state_province,
       MAX(cust_credit_limit) - MIN(cust_credit_limit) AS credit_range
FROM sh.customers
GROUP BY cust_state_province
ORDER BY credit_range ASC
FETCH FIRST 1 ROW ONLY;

-- 13.Show the total number of customers per income level and the percentage contribution of each.

SELECT 
    cust_income_level,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage_contribution
FROM sh.customers
GROUP BY cust_income_level
ORDER BY customer_count DESC;

-- 14.For each income level, find how many customers have NULL credit limits.

SELECT 
    cust_income_level,
    COUNT(*) AS null_credit_count
FROM sh.customers
WHERE cust_credit_limit IS NULL
GROUP BY cust_income_level
ORDER BY cust_income_level;

-- 15.Display countries where the sum of credit limits exceeds 10 million.

SELECT 
    co.country_name,
    SUM(c.cust_credit_limit) AS total_credit_limit
FROM sh.customers c
JOIN sh.countries co 
    ON c.country_id = co.country_id
GROUP BY co.country_name
HAVING SUM(c.cust_credit_limit) > 10000000
ORDER BY total_credit_limit DESC;

-- 16.Find the state that contributes the highest total credit limit to its country.

SELECT country_name, cust_state_province, total_credit_limit
FROM (
    SELECT co.country_name,
           c.cust_state_province,
           SUM(c.cust_credit_limit) AS total_credit_limit,
           RANK() OVER (PARTITION BY co.country_name ORDER BY SUM(c.cust_credit_limit) DESC) AS rnk
    FROM sh.customers c
    JOIN sh.countries co 
        ON c.country_id = co.country_id
    GROUP BY co.country_name, c.cust_state_province
)
WHERE rnk = 1
ORDER BY country_name;

-- 17.Show total credit limit per year of birth, sorted by total descending.

SELECT 
    cust_year_of_birth,
    SUM(cust_credit_limit) AS total_credit_limit
FROM sh.customers
GROUP BY cust_year_of_birth
ORDER BY total_credit_limit DESC;

-- 18.Identify customers who hold the maximum credit limit in their respective country.

SELECT cust_id,
       cust_first_name,
       cust_last_name,
       country_name,
       cust_credit_limit
FROM (
    SELECT c.cust_id,
           c.cust_first_name,
           c.cust_last_name,
           co.country_name,
           c.cust_credit_limit,
           RANK() OVER (PARTITION BY co.country_id ORDER BY c.cust_credit_limit DESC) AS rnk
    FROM sh.customers c
    JOIN sh.countries co
        ON c.country_id = co.country_id
)
WHERE rnk = 1
ORDER BY country_name;

-- 19.Show the difference between maximum and average credit limit per country.

SELECT 
    co.country_name,
    MAX(c.cust_credit_limit) - AVG(c.cust_credit_limit) AS max_avg_difference
FROM sh.customers c
JOIN sh.countries co
    ON c.country_id = co.country_id
GROUP BY co.country_name
ORDER BY max_avg_difference DESC;

-- 20.Display the overall rank of each state based on its total credit limit (using GROUP BY + analytic rank).

SELECT 
    cust_state_province,
    SUM(cust_credit_limit) AS total_credit_limit,
    RANK() OVER (ORDER BY SUM(cust_credit_limit) DESC) AS state_rank
FROM sh.customers
GROUP BY cust_state_province
ORDER BY state_rank;