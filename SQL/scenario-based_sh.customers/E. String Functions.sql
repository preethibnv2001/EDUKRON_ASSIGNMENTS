-- E. String Functions (10 Questions)

-- 1.Show customers whose first and last name start with the same letter.

SELECT cust_id,
       cust_first_name,
       cust_last_name
FROM sh.customers
WHERE UPPER(SUBSTR(cust_first_name, 1, 1)) = UPPER(SUBSTR(cust_last_name, 1, 1));

-- 2.Display full names in “Last, First” format.

SELECT cust_id,
       cust_last_name || ', ' || cust_first_name AS full_name
FROM sh.customers;

-- 3.Find customers whose last name ends with 'SON'.

SELECT cust_id,
       cust_first_name,
       cust_last_name
FROM sh.customers
WHERE UPPER(cust_last_name) LIKE '%SON';

-- 4.Display length of each customer’s full name.

SELECT cust_id,
       cust_first_name,
       cust_last_name,
       LENGTH(cust_first_name || ' ' || cust_last_name) AS full_name_length
FROM sh.customers;

-- 5.Replace vowels in customer names with '*'.

SELECT cust_id,
       REGEXP_REPLACE(cust_first_name, '[AEIOUaeiou]', '*') AS masked_first_name,
       REGEXP_REPLACE(cust_last_name, '[AEIOUaeiou]', '*')  AS masked_last_name
FROM sh.customers;

-- 6.Show customers whose income level description contains ‘90’.

SELECT cust_id,
       cust_first_name,
       cust_last_name,
       cust_income_level
FROM sh.customers
WHERE cust_income_level LIKE '%90%';

-- 7.Display initials of each customer (first letters of first and last name).

SELECT cust_id,
       cust_first_name,
       cust_last_name,
       UPPER(SUBSTR(cust_first_name, 1, 1)) || UPPER(SUBSTR(cust_last_name, 1, 1)) AS initials
FROM sh.customers;

-- 8.Concatenate city and state to create full address.

SELECT cust_id,
       cust_first_name,
       cust_last_name,
       cust_city || ', ' || cust_state_province AS full_address
FROM sh.customers;

-- 9.Extract numeric value from income level using REGEXP_SUBSTR.

SELECT cust_id,
       cust_income_level,
       REGEXP_SUBSTR(cust_income_level, '[0-9]+') AS extracted_number
FROM sh.customers;

-- 10.Count how many customers have a 3-letter first name.

SELECT COUNT(*) AS three_letter_first_names
FROM sh.customers
WHERE LENGTH(cust_first_name) = 3;