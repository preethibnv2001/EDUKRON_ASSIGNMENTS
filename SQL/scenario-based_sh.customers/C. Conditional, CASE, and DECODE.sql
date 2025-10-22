-- C. Conditional, CASE, and DECODE (10 Questions)

-- 1.Categorize customers into income tiers: Platinum, Gold, Silver, Bronze.

SELECT cust_id,
       cust_first_name,
       cust_last_name,
       cust_income_level,
       CASE cust_income_level
            WHEN 'A: Above 150,000' THEN 'Platinum'
            WHEN 'B: 100,000 - 149,999' THEN 'Gold'
            WHEN 'C: 70,000 - 99,999' THEN 'Silver'
            ELSE 'Bronze'
       END AS income_tier
FROM sh.customers;

-- 2.Display “High”, “Medium”, or “Low” income categories based on credit limit.

SELECT cust_id,
       cust_first_name,
       cust_last_name,
       cust_credit_limit,
       CASE 
            WHEN cust_credit_limit >= 50000 THEN 'High'
            WHEN cust_credit_limit BETWEEN 20000 AND 49999 THEN 'Medium'
            ELSE 'Low'
       END AS credit_category
FROM sh.customers;

-- 3.Replace NULL income levels with “Unknown” using NVL.

SELECT cust_id,
       cust_first_name,
       cust_last_name,
       NVL(cust_income_level, 'Unknown') AS income_level
FROM sh.customers;

-- 4.Show customer details and mark whether they have above-average credit limit or not.

SELECT cust_id,
       cust_first_name,
       cust_last_name,
       cust_credit_limit,
       CASE 
            WHEN cust_credit_limit > (SELECT AVG(cust_credit_limit) FROM sh.customers)
            THEN 'Above Average'
            ELSE 'Below or Equal to Average'
       END AS credit_status
FROM sh.customers;

-- 5.Use DECODE to convert marital status codes (S/M/D) into full text.

SELECT cust_id,
       cust_first_name,
       cust_last_name,
       DECODE(cust_marital_status,
              'S', 'Single',
              'M', 'Married',
              'D', 'Divorced',
              'Unknown') AS marital_status_full
FROM sh.customers;

-- 6.Use CASE to show age group (≤30, 31–50, >50) from CUST_YEAR_OF_BIRTH.

SELECT cust_id,
       cust_first_name,
       cust_last_name,
       cust_year_of_birth,
       CASE 
            WHEN EXTRACT(YEAR FROM SYSDATE) - cust_year_of_birth <= 30 THEN '≤30'
            WHEN EXTRACT(YEAR FROM SYSDATE) - cust_year_of_birth BETWEEN 31 AND 50 THEN '31–50'
            ELSE '>50'
       END AS age_group
FROM sh.customers;

-- 7.Label customers as “Old Credit Holder” or “New Credit Holder” based on year of birth < 1980.

SELECT cust_id,
       cust_first_name,
       cust_last_name,
       cust_year_of_birth,
       CASE 
            WHEN cust_year_of_birth < 1980 THEN 'Old Credit Holder'
            ELSE 'New Credit Holder'
       END AS credit_holder_type
FROM sh.customers;

-- 8.Create a loyalty tag — “Premium” if credit limit > 50,000 and income_level = ‘E’.

SELECT cust_id,
       cust_first_name,
       cust_last_name,
       cust_income_level,
       cust_credit_limit,
       CASE 
            WHEN cust_credit_limit > 50000 AND cust_income_level = 'E: 50,000 - 69,999'
            THEN 'Premium'
            ELSE 'Standard'
       END AS loyalty_tag
FROM sh.customers;

-- 9.Assign grades (A–F) based on credit limit range using CASE.

SELECT cust_id,
       cust_first_name,
       cust_last_name,
       cust_credit_limit,
       CASE 
            WHEN cust_credit_limit >= 80000 THEN 'A'
            WHEN cust_credit_limit BETWEEN 60000 AND 79999 THEN 'B'
            WHEN cust_credit_limit BETWEEN 40000 AND 59999 THEN 'C'
            WHEN cust_credit_limit BETWEEN 20000 AND 39999 THEN 'D'
            WHEN cust_credit_limit BETWEEN 10000 AND 19999 THEN 'E'
            ELSE 'F'
       END AS credit_grade
FROM sh.customers;

-- 10.Show country, state, and number of premium customers using conditional aggregation.

SELECT country_id,
       cust_state_province,
       COUNT(CASE 
                 WHEN cust_credit_limit > 50000 
                      AND cust_income_level = 'E: 50,000 - 69,999'
                 THEN 1
            END) AS premium_customers
FROM sh.customers
GROUP BY country_id, cust_state_province
ORDER BY country_id, cust_state_province;