with cte AS
(
    select cust_city, cust_credit_limit,
    row_number()
    OVER (PARTITION BY cust_city
    order by cust_credit_limit desc) AS RN
    from sh.customers
)
select * from cte
where RN = 2

-------------------------------------------------------------------
desc sh.customers;
with ranked as(
    select 
    cust_id,
    cust_first_name,
    cust_last_name,
    cust_credit_limit,
    row_number() over ( order by cust_credit_limit DESC) as RN
    FROM sh.customers
)
select
    cust_id,
    cust_first_name,
    cust_last_name,
    cust_credit_limit,
    CASE
        WHEN RN>=5 then 'Premium Tier'
        else 'Standard Tier'
    End as tier
from ranked
order by cust_credit_limit desc;