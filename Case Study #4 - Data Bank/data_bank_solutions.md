# Data Bank Case
![](Data_Bank.png)

## Quick links 
[Queries Script](data_bank.sql)

[A. Customer Nodes Exploration Solutions](#a-customer-nodes-exploration) 

[B. Customer Transactions Solutions](#b-customer-transactions)    

## ER-Diagram
![ER Diagram](er_data_bank.png)

### A. Customer Nodes Exploration
1. How many unique nodes are there on the Data Bank system?

```sql
SELECT
   COUNT(DISTINCT node_id)
FROM
   customer_nodes

+ ---------------------------- +
| COUNT(DISTINCT node_id)      |
+ ---------------------------- +
| 5                            |
+ ---------------------------- +
```
   
2. What is the number of nodes per region?

```sql
SELECT 
   r.region_name,
   COUNT(DISTINCT cn.node_id) AS node_count
FROM
   customer_nodes AS cn
    JOIN regions AS r
     ON cn.region_id = r.region_id
GROUP BY 
    r.region_name

+ ---------------- + --------------- +
| region_name      | node_count      |
+ ---------------- + --------------- +
| Africa           | 5               |
| America          | 5               |
| Asia             | 5               |
| Australia        | 5               |
| Europe           | 5               |
+ ---------------- + --------------- +
```
3. How many customers are allocated to each region?

```sql
 SELECT 
   r.region_name,
   COUNT(DISTINCT cn.customer_id) AS customers
FROM
   customer_nodes AS cn
   JOIN regions AS r
   ON cn.region_id = r.region_id
GROUP BY
   r.region_name

+ ---------------- + -------------- +
| region_name      | customers      |
+ ---------------- + -------------- +
| Africa           | 102            |
| America          | 105            |
| Asia             | 95             |
| Australia        | 110            |
| Europe           | 88             |
+ ---------------- + -------------- +
```
4. How many days on average are customers reallocated to a different node?

```sql
SELECT 
   customer_id AS customer,
   node_id AS node,
   ROUND(AVG(DATEDIFF(end_date, start_date)),0) AS avg_days
FROM
   customer_nodes
GROUP BY
   customer_id,
   node_id
ORDER BY
   customer,
   node
   LIMIT 15

+ ------------- + --------- + ------------- +
| customer      | node      | avg_days      |
+ ------------- + --------- + ------------- +
| 1             | 2         | 971528        |
| 1             | 3         | 20            |
| 1             | 4         | 6             |
| 1             | 5         | 11            |
| 2             | 2         | 4             |
| 2             | 3         | 17            |
| 2             | 4         | 1457281       |
| 2             | 5         | 14            |
| 3             | 1         | 0             |
| 3             | 2         | 2914519       |
| 3             | 3         | 17            |
| 3             | 4         | 17            |
| 3             | 5         | 16            |
| 4             | 3         | 728644        |
| 4             | 4         | 18            |
+ ------------- + --------- + ------------- +
```
5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

```sql
WITH OrderedData AS (
    SELECT 
        r.region_name,
        DATEDIFF(cn.end_date, cn.start_date) AS reallocation_days,
        ROW_NUMBER() OVER (PARTITION BY r.region_name ORDER BY DATEDIFF(cn.end_date, cn.start_date)) AS row_num,
        COUNT(*) OVER (PARTITION BY r.region_name) AS total_rows
    FROM 
        customer_nodes AS cn
    JOIN 
        regions AS r 
        ON cn.region_id = r.region_id
),
PercentileIndices AS (
    SELECT 
        region_name,
        FLOOR(0.50 * (total_rows - 1)) AS p50_index, -- Median (50th percentile)
        FLOOR(0.80 * (total_rows - 1)) AS p80_index, -- 80th percentile
        FLOOR(0.95 * (total_rows - 1)) AS p95_index  -- 95th percentile
    FROM 
        OrderedData
    GROUP BY 
        region_name, total_rows
)
SELECT
    od.region_name,
    CASE 
        WHEN pi.p50_index = od.row_num - 1 THEN 'Median (50th)'
        WHEN pi.p80_index = od.row_num - 1 THEN '80th Percentile'
        WHEN pi.p95_index = od.row_num - 1 THEN '95th Percentile'
    END AS percentile,
    od.reallocation_days
FROM 
    OrderedData AS od
JOIN 
    PercentileIndices AS pi 
    ON od.region_name = pi.region_name
WHERE 
    od.row_num - 1 IN (pi.p50_index, pi.p80_index, pi.p95_index)
ORDER BY 
    od.region_name, percentile

+ ---------------- + --------------- + ---------------------- +
| region_name      | percentile      | reallocation_days      |
+ ---------------- + --------------- + ---------------------- +
| Africa           | 80th Percentile | 27                     |
| Africa           | 95th Percentile | 2914535                |
| Africa           | Median (50th)   | 17                     |
| America          | 80th Percentile | 27                     |
| America          | 95th Percentile | 2914534                |
| America          | Median (50th)   | 18                     |
| Asia             | 80th Percentile | 27                     |
| Asia             | 95th Percentile | 2914538                |
| Asia             | Median (50th)   | 17                     |
| Australia        | 80th Percentile | 28                     |
| Australia        | 95th Percentile | 2914533                |
| Australia        | Median (50th)   | 17                     |
| Europe           | 80th Percentile | 28                     |
| Europe           | 95th Percentile | 2914527                |
| Europe           | Median (50th)   | 18                     |
+ ---------------- + --------------- + ---------------------- +
```
### B. Customer Transactions
1. What is the unique count and total amount for each transaction type?

```sql
SELECT
   txn_type,
   COUNT(txn_date) txn_count,
   SUM(txn_amount) AS total_amount
FROM
   customer_transactions
GROUP BY
   txn_type

+ ------------- + -------------- + ----------------- +
| txn_type      | txn_count      | total_amount      |
+ ------------- + -------------- + ----------------- +
| deposit       | 2671           | 1359168           |
| withdrawal    | 1580           | 793003            |
| purchase      | 1617           | 806537            |
+ ------------- + -------------- + ----------------- +
```
2. What is the average total historical deposit counts and amounts for all customers?

```sql
WITH CUSTOMER_DEPOSIT_STATS AS (
SELECT
    customer_id,
    COUNT(txn_date) AS deposit_count,
    SUM(txn_amount) AS amount_per_customer
FROM
    customer_transactions
WHERE 
    txn_type = 'deposit'
GROUP BY
    customer_id
)
SELECT 
    AVG(deposit_count) AS avg_deposit_count,
    AVG(amount_per_customer)
FROM 
    CUSTOMER_DEPOSIT_STATS

+ ---------------------- + ----------------------------- +
| avg_deposit_count      | AVG(amount_per_customer)      |
+ ---------------------- + ----------------------------- +
| 5.3420                 | 2718.3360                     |
+ ---------------------- + ----------------------------- +
```
3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?

```sql
WITH MONTHLY_TRANSACTIONS AS (
    SELECT 
        customer_id,
        MONTH(txn_date) AS month,  
        SUM(CASE WHEN txn_type = 'deposit' THEN 1 END) AS deposit_count,
        SUM(CASE WHEN txn_type = 'purchase' THEN 1 END) AS purchase_count,
        SUM(CASE WHEN txn_type = 'withdrawal' THEN 1 END) AS withdrawal_count
    FROM 
        customer_transactions
    GROUP BY 
        customer_id, MONTH(txn_date)  
)
SELECT
    CASE 
        WHEN month = 1 THEN 'January'
        WHEN month = 2 THEN 'February'
        WHEN month = 3 THEN 'March'
        WHEN month = 4 THEN 'April'
        WHEN month = 5 THEN 'May'
        WHEN month = 6 THEN 'June'
        WHEN month = 7 THEN 'July'
        WHEN month = 8 THEN 'August'
        WHEN month = 9 THEN 'September'
        WHEN month = 10 THEN 'October'
        WHEN month = 11 THEN 'November'
        WHEN month = 12 THEN 'December'
    END AS month_name,  
    COUNT(DISTINCT customer_id) AS customer_count
FROM 
   MONTHLY_TRANSACTIONS
WHERE
   deposit_count > 1
   AND (purchase_count >= 1 OR withdrawal_count >= 1)
GROUP BY 
   month  
ORDER BY 
   month

+ --------------- + ------------------- +
| month_name      | customer_count      |
+ --------------- + ------------------- +
| January         | 168                 |
| February        | 181                 |
| March           | 192                 |
| April           | 70                  |
+ --------------- + ------------------- +
```

4. What is the closing balance for each customer at the end of the month?

```sql
WITH CTE AS (
SELECT 
   DATE_FORMAT(txn_date, '%Y-%m-01') AS txn_month,
   txn_date,
   customer_id,
   SUM((CASE WHEN txn_type ='deposit' THEN txn_amount ELSE 0 END) - (CASE WHEN txn_type <> 'deposit' THEN txn_amount ELSE 0 END)) AS balance
FROM
   customer_transactions
GROUP BY
   txn_month,
   txn_date,
   customer_id
  ),
BALANCES AS (
SELECT
     *,
     SUM(balance) OVER (PARTITION BY customer_id ORDER BY txn_date) AS running_sum, -- cumulative sum
     ROW_NUMBER() OVER (PARTITION BY customer_id, txn_month ORDER BY txn_date DESC) AS rn
FROM CTE
ORDER BY
	 txn_date
 )
 SELECT
    customer_id,
    LAST_DAY(txn_month) AS end_of_month,
    running_sum AS closing_balance
 FROM 
    BALANCES
 WHERE rn = 1
 ORDER BY 
    customer_id,
    end_of_month
LIMIT 15

+ ---------------- + ----------------- + -------------------- +
| customer_id      | end_of_month      | closing_balance      |
+ ---------------- + ----------------- + -------------------- +
| 1                | 2020-01-31        | 312                  |
| 1                | 2020-03-31        | -640                 |
| 2                | 2020-01-31        | 549                  |
| 2                | 2020-03-31        | 610                  |
| 3                | 2020-01-31        | 144                  |
| 3                | 2020-02-29        | -821                 |
| 3                | 2020-03-31        | -1222                |
| 3                | 2020-04-30        | -729                 |
| 4                | 2020-01-31        | 848                  |
| 4                | 2020-03-31        | 655                  |
| 5                | 2020-01-31        | 954                  |
| 5                | 2020-03-31        | -1923                |
| 5                | 2020-04-30        | -2413                |
| 6                | 2020-01-31        | 733                  |
| 6                | 2020-02-29        | -52                  |
+ ---------------- + ----------------- + -------------------- +
```
5. What is the percentage of customers who increase their closing balance by more than 5%?

```sql

> WITH CTE AS (
SELECT 
   DATE_FORMAT(txn_date, '%Y-%m-01') AS txn_month,
   txn_date,
   customer_id,
   SUM((CASE WHEN txn_type ='deposit' THEN txn_amount ELSE 0 END) - (CASE WHEN txn_type <> 'deposit' THEN txn_amount ELSE 0 END)) AS balance
FROM
   customer_transactions
GROUP BY
   txn_month,
   txn_date,
   customer_id
  ),
BALANCES AS (
SELECT
     *,
     SUM(balance) OVER (PARTITION BY customer_id ORDER BY txn_date) AS running_sum, -- cumulative sum
     ROW_NUMBER() OVER (PARTITION BY customer_id, txn_month ORDER BY txn_date DESC) AS rn
FROM CTE
ORDER BY
	 txn_date
 ),
 CLOSING_BALANCES AS (
 SELECT
    customer_id,
    LAST_DAY(txn_month) AS end_of_month,
    LAST_DAY(DATE_SUB(txn_date, INTERVAL 1 MONTH)) AS previous_end_of_month,
    running_sum as closing_balance
 FROM 
    BALANCES
 WHERE rn = 1
 ORDER BY 
	end_of_month
),
PERCENT_INCREASE AS (
SELECT 
CB1.customer_id,
CB1.end_of_month,
CB1.closing_balance,
CB2.closing_balance as next_month_closing_balance,
(CB2.closing_balance / CB1.closing_balance) -1 as percentage_increase,
CASE WHEN (CB2.closing_balance > CB1.closing_balance AND 
(CB2.closing_balance / CB1.closing_balance) -1 > 0.05) THEN 1 ELSE 0 END as percentage_increase_flag
FROM CLOSING_BALANCES as CB1
INNER JOIN CLOSING_BALANCES as CB2 on CB1.end_of_month = CB2.previous_end_of_month 
AND CB1.customer_id = CB2.customer_id
WHERE CB1.closing_balance <> 0
)
SELECT 
SUM(percentage_increase_flag) / COUNT(percentage_increase_flag) * 100 AS percentage_of_customers_increasing_balance
FROM PERCENT_INCREASE

+ ----------------------------------------------- +
| percentage_of_customers_increasing_balance      |
+ ----------------------------------------------- +
| 20.9664                                         |
+ ----------------------------------------------- +
```
