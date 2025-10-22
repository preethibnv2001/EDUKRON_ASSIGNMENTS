-- D. Date & Conversion Functions (10 Questions)

-- 1.Convert CUST_YEAR_OF_BIRTH to age as of today.

SELECT cust_id,
       cust_first_name,
       cust_last_name,
       cust_year_of_birth,
       EXTRACT(YEAR FROM SYSDATE) - cust_year_of_birth AS age
FROM sh.customers;

-- 2.Display all customers born between 1980 and 1990.

SELECT cust_id,
       cust_first_name,
       cust_last_name,
       cust_year_of_birth
FROM sh.customers
WHERE cust_year_of_birth BETWEEN 1980 AND 1990
ORDER BY cust_year_of_birth;

-- 3.Format date of birth into “Month YYYY” using TO_CHAR.

SELECT cust_id,
       cust_first_name,
       cust_last_name,
       TO_CHAR(TO_DATE(cust_year_of_birth, 'YYYY'), 'Month YYYY') AS formatted_birth
FROM sh.customers;

-- 4.Convert income level text (like 'A: Below 30,000') to numeric lower limit.

SELECT cust_id,
       cust_income_level,
       TO_NUMBER(
         REGEXP_SUBSTR(cust_income_level, '[0-9]+', 1, 1)
       ) AS income_lower_limit
FROM sh.customers;

-- 5.Display customer birth decades (e.g., 1960s, 1970s).

SELECT cust_id,
       cust_first_name,
       cust_last_name,
       cust_year_of_birth,
       FLOOR(cust_year_of_birth / 10) * 10 || 's' AS birth_decade
FROM sh.customers;

-- 6.Show customers grouped by age bracket (10-year intervals).

SELECT (TRUNC((EXTRACT(YEAR FROM SYSDATE) - cust_year_of_birth)/10)*10) AS age_bracket_start,
       COUNT(*) AS total_customers
FROM sh.customers
GROUP BY TRUNC((EXTRACT(YEAR FROM SYSDATE) - cust_year_of_birth)/10)*10
ORDER BY age_bracket_start;

-- 7.Convert country_id to uppercase and state name to lowercase.

SELECT UPPER(TO_CHAR(country_id)) AS country_id_upper,
       LOWER(cust_state_province) AS state_lower,
       cust_first_name,
       cust_last_name
FROM sh.customers;

-- 8.Show customers where credit limit > average of their birth decade.

SELECT c.cust_id,
       c.cust_first_name,
       c.cust_last_name,
       c.cust_credit_limit,
       (FLOOR(c.cust_year_of_birth / 10) * 10) AS birth_decade
FROM sh.customers c
WHERE c.cust_credit_limit > (
    SELECT AVG(c2.cust_credit_limit)
    FROM sh.customers c2
    WHERE FLOOR(c2.cust_year_of_birth / 10) * 10 = FLOOR(c.cust_year_of_birth / 10) * 10
);

-- 9.Convert all numeric credit limits to currency format $999,999.00.

SELECT cust_id,
       cust_first_name,
       cust_last_name,
       TO_CHAR(cust_credit_limit, '$999,999.00') AS formatted_credit_limit
FROM sh.customers;

-- 10.Find customers whose credit limit was NULL and replace with average (using NVL).

SELECT cust_id,
       cust_first_name,
       cust_last_name,
       NVL(cust_credit_limit, (SELECT AVG(cust_credit_limit) FROM sh.customers)) AS adjusted_credit_limit
FROM sh.customers;