# Foddie Fi Case
![](Foodie_Fi.png)

## Quick links 
[Queries Script](foodie_fi.sql)

[A. Customer Journey Solutions](#a-customer-journey) 

[B. Data Analysis Questions Solutions](#b-data-analysis-questions)    

## ER-Diagram
![ER Diagram](er_foodie_fi.png)

## Case Study Questions
Each of the following case study questions can be answered using a single SQL statement: 
### A. Customer Journey
1. Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.
Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!

```sql
SELECT
   s.customer_id,
   p.plan_name,
   s.start_date
FROM
   subscriptions AS s
   JOIN plans AS p
    ON s.plan_id = p.plan_id
WHERE
   customer_id <= 8
;

SELECT
   s.customer_id,
   p.plan_name,
   s.start_date
FROM
   subscriptions AS s
   JOIN plans AS p
    ON s.plan_id = p.plan_id
WHERE
   customer_id <= 8

+ ---------------- + -------------- + --------------- +
| customer_id      | plan_name      | start_date      |
+ ---------------- + -------------- + --------------- +
| 1                | trial          | 2020-08-01      |
| 1                | basic monthly  | 2020-08-08      |
| 2                | trial          | 2020-09-20      |
| 2                | pro annual     | 2020-09-27      |
| 3                | trial          | 2020-01-13      |
| 3                | basic monthly  | 2020-01-20      |
| 4                | trial          | 2020-01-17      |
| 4                | basic monthly  | 2020-01-24      |
| 4                | churn          | 2020-04-21      |
| 5                | trial          | 2020-08-03      |
| 5                | basic monthly  | 2020-08-10      |
| 6                | trial          | 2020-12-23      |
| 6                | basic monthly  | 2020-12-30      |
| 6                | churn          | 2021-02-26      |
| 7                | trial          | 2020-02-05      |
| 7                | basic monthly  | 2020-02-12      |
| 7                | pro monthly    | 2020-05-22      |
| 8                | trial          | 2020-06-11      |
| 8                | basic monthly  | 2020-06-18      |
| 8                | pro monthly    | 2020-08-03      |
+ ---------------- + -------------- + --------------- +
```
The 8 customers start with the trial plan, and after a week, they upgrade to the basic monthly plan, except for one customer who moves directly to the annual pro plan. Only two customers canceled the service: customer 4 after nearly 4 months of basic monthly service, and customer 6 who only stayed for 2 months with the basic monthly service.

### B. Data Analysis Questions
1. How many customers has Foodie-Fi ever had?

```sql
 SELECT 
   COUNT(DISTINCT s.customer_id) AS customer_count
FROM 
   subscriptions AS s

+ ------------------- +
| customer_count      |
+ ------------------- +
| 1000                |
+ ------------------- +
```
2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

```sql
SELECT 
    DATE_FORMAT(s.start_date, '%y-%m-01') AS month,
	COUNT(s.customer_id) AS customer_count
FROM
   subscriptions AS s
   JOIN plans AS p
    ON s.plan_id = p.plan_id
WHERE 
    p.plan_name = 'trial'
GROUP BY
    month 
ORDER BY 
	month

+ ---------- + ------------------- +
| month      | customer_count      |
+ ---------- + ------------------- +
| 20-01-01   | 88                  |
| 20-02-01   | 68                  |
| 20-03-01   | 94                  |
| 20-04-01   | 81                  |
| 20-05-01   | 88                  |
| 20-06-01   | 79                  |
| 20-07-01   | 89                  |
| 20-08-01   | 88                  |
| 20-09-01   | 87                  |
| 20-10-01   | 79                  |
| 20-11-01   | 75                  |
| 20-12-01   | 84                  |
+ ---------- + ------------------- +
```
3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

```sql
> SELECT
   YEAR(start_date) AS year,
   COUNT(p.plan_name) AS count_of_events,
   p.plan_name AS plan_name
FROM
    subscriptions AS s
JOIN 
    plans AS p
ON 
    s.plan_id = p.plan_id
WHERE 
    YEAR(s.start_date) > 2020
GROUP BY
	p.plan_name,
    year

+ --------- + -------------------- + -------------- +
| year      | count_of_events      | plan_name      |
+ --------- + -------------------- + -------------- +
| 2021      | 71                   | churn          |
| 2021      | 60                   | pro monthly    |
| 2021      | 63                   | pro annual     |
| 2021      | 8                    | basic monthly  |
+ --------- + -------------------- + -------------- +
```
4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

```sql
SELECT
 (
 SELECT 
	 COUNT(DISTINCT customer_id) 
  FROM
    subscriptions 
WHERE plan_id = 4
) AS customers_who_have_churned,
ROUND(100 * (
 SELECT 
	 COUNT(DISTINCT customer_id) 
  FROM
    subscriptions 
WHERE plan_id = 4
)  / COUNT(DISTINCT customer_id), 1) AS percentage_of_customers_who_churned
FROM
    subscriptions

+ ------------------------------- + ---------------------------------------- +
| customers_who_have_churned      | percentage_of_customers_who_churned      |
+ ------------------------------- + ---------------------------------------- +
| 307                             | 30.7                                     |
+ ------------------------------- + ---------------------------------------- +
```
5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

```sql
WITH CTE AS (
SELECT 
   s.customer_id AS customer,
   p.plan_name AS plan_name,
   ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY s.start_date ASC) AS rn
FROM
    subscriptions s
    JOIN plans AS p
     ON s.plan_id = p.plan_id
)
SELECT 
     COUNT(DISTINCT customer) AS churned_after_trial_customers,
     ROUND(100 * COUNT( DISTINCT customer) / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions), 0) AS percent_churn_after_trial
FROM
    CTE
WHERE 
    rn = 2 AND plan_name = 'churn'

+ ---------------------------------- + ------------------------------ +
| churned_after_trial_customers      | percent_churn_after_trial      |
+ ---------------------------------- + ------------------------------ +
| 92                                 | 9                              |
+ ---------------------------------- + ------------------------------ +
```
6. What is the number and percentage of customer plans after their initial free trial?

```sql
 WITH CTE AS (
SELECT 
   s.customer_id AS customer,
   p.plan_name AS plan_name,
   ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY s.start_date ASC) AS rn
FROM
    subscriptions s
    JOIN plans AS p
     ON s.plan_id = p.plan_id
)
SELECT 
     plan_name,
     COUNT(DISTINCT customer) AS customer_count,
     ROUND(100 * COUNT( DISTINCT customer) / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions), 0) AS customer_percent_after_trial
FROM
    CTE
WHERE 
    rn = 2 
GROUP BY 
    plan_name

+ -------------- + ------------------- + --------------------------------- +
| plan_name      | customer_count      | customer_percent_after_trial      |
+ -------------- + ------------------- + --------------------------------- +
| basic monthly  | 546                 | 55                                |
| churn          | 92                  | 9                                 |
| pro annual     | 37                  | 4                                 |
| pro monthly    | 325                 | 33                                |
+ -------------- + ------------------- + --------------------------------- +
```
7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

```sql
WITH CTE AS (   
SELECT
    s.customer_id AS customer,
	p.plan_name AS plan_name,
    ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY s.start_date DESC) AS rn,
	s.start_date AS start_date
FROM
	subscriptions s
	JOIN plans p
	  ON s.plan_id = p.plan_id
WHERE 
   start_date <= '2020-12-31'
)
SELECT  
    plan_name,
    COUNT(customer) AS customer_count,
    ROUND(100 * COUNT( DISTINCT customer) / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions), 1) AS percent
FROM 
    CTE
WHERE 
    rn = 1
GROUP BY
    plan_name

+ -------------- + ------------------- + ------------ +
| plan_name      | customer_count      | percent      |
+ -------------- + ------------------- + ------------ +
| basic monthly  | 224                 | 22.4         |
| churn          | 236                 | 23.6         |
| pro annual     | 195                 | 19.5         |
| pro monthly    | 326                 | 32.6         |
| trial          | 19                  | 1.9          |
+ -------------- + ------------------- + ------------ +
```
8. How many customers have upgraded to an annual plan in 2020?

```sql
SELECT 
   COUNT(DISTINCT s.customer_id) AS annual_upgrade_customers
FROM 
   subscriptions s
   JOIN plans p
    ON p.plan_id = s.plan_id
WHERE 
  p.plan_name = 'pro annual' 
  AND YEAR(s.start_date) = 2020

+ ----------------------------- +
| annual_upgrade_customers      |
+ ----------------------------- +
| 195                           |
+ ----------------------------- +
```

9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

```sql
WITH TRIAL AS (
SELECT 
   customer_id,
   start_date AS trial_start
FROM 
   subscriptions
WHERE
   plan_id = 0
),
ANNUAL AS (
SELECT 
   customer_id,
   start_date AS annual_plan_start
FROM 
   subscriptions
WHERE
   plan_id = 3
)
SELECT
   AVG(DATEDIFF(annual_plan_start, trial_start)) AS avg_days_from_trial_to_annual_plan
FROM
   TRIAL AS T
    JOIN ANNUAL AS A
     ON T.customer_id = A.customer_id

+ --------------------------------------- +
| avg_days_from_trial_to_annual_plan      |
+ --------------------------------------- +
| 104.6202                                |
+ --------------------------------------- +
```
10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

```sql
WITH TRIAL AS (
SELECT 
   customer_id,
   start_date AS trial_start
FROM 
   subscriptions
WHERE
   plan_id = 0
),
ANNUAL AS (
SELECT 
   customer_id,
   start_date AS annual_plan_start
FROM 
   subscriptions
WHERE
   plan_id = 3
),
DIFFS AS (
SELECT
   CASE
    WHEN DATEDIFF(annual_plan_start, trial_start) BETWEEN 0 AND 30 THEN '0-30'
    WHEN DATEDIFF(annual_plan_start, trial_start) BETWEEN 31 AND 60 THEN '31-60'
    WHEN DATEDIFF(annual_plan_start, trial_start) BETWEEN 61 AND 90 THEN '61-90'
    WHEN DATEDIFF(annual_plan_start, trial_start) BETWEEN 91 AND 120 THEN '91-120'
    WHEN DATEDIFF(annual_plan_start, trial_start) BETWEEN 121 AND 150 THEN '121-150'
    WHEN DATEDIFF(annual_plan_start, trial_start) BETWEEN 151 AND 180 THEN '151-180'
    WHEN DATEDIFF(annual_plan_start, trial_start) BETWEEN 181 AND 210 THEN '181-210'
    WHEN DATEDIFF(annual_plan_start, trial_start) BETWEEN 211 AND 240 THEN '211-240'
    WHEN DATEDIFF(annual_plan_start, trial_start) BETWEEN 241 AND 270 THEN '241-270'
    WHEN DATEDIFF(annual_plan_start, trial_start) BETWEEN 271 AND 300 THEN '271-300'
    WHEN DATEDIFF(annual_plan_start, trial_start) BETWEEN 301 AND 330 THEN '301-330'
    WHEN DATEDIFF(annual_plan_start, trial_start) BETWEEN 331 AND 360 THEN '331-360'
    END AS bin,
    COUNT(T.customer_id) AS customer_count,
    CASE
    WHEN DATEDIFF(annual_plan_start, trial_start) BETWEEN 0 AND 30 THEN 1
    WHEN DATEDIFF(annual_plan_start, trial_start) BETWEEN 31 AND 60 THEN 2
    WHEN DATEDIFF(annual_plan_start, trial_start) BETWEEN 61 AND 90 THEN 3
    WHEN DATEDIFF(annual_plan_start, trial_start) BETWEEN 91 AND 120 THEN 4
    WHEN DATEDIFF(annual_plan_start, trial_start) BETWEEN 121 AND 150 THEN 5
    WHEN DATEDIFF(annual_plan_start, trial_start) BETWEEN 151 AND 180 THEN 6
    WHEN DATEDIFF(annual_plan_start, trial_start) BETWEEN 181 AND 210 THEN 7
    WHEN DATEDIFF(annual_plan_start, trial_start) BETWEEN 211 AND 240 THEN 8
    WHEN DATEDIFF(annual_plan_start, trial_start) BETWEEN 241 AND 270 THEN 9
    WHEN DATEDIFF(annual_plan_start, trial_start) BETWEEN 271 AND 300 THEN 10
    WHEN DATEDIFF(annual_plan_start, trial_start) BETWEEN 301 AND 330 THEN 11
    WHEN DATEDIFF(annual_plan_start, trial_start) BETWEEN 331 AND 360 THEN 12
    END AS bin_order
FROM
   TRIAL AS T
    JOIN ANNUAL AS A
     ON T.customer_id = A.customer_id
GROUP BY
    bin, 
    bin_order
)
SELECT 
    bin,
    customer_count
FROM 
    DIFFS
ORDER BY 
    bin_order

+ -------- + ------------------- +
| bin      | customer_count      |
+ -------- + ------------------- +
| 0-30     | 49                  |
| 31-60    | 24                  |
| 61-90    | 34                  |
| 91-120   | 35                  |
| 121-150  | 42                  |
| 151-180  | 36                  |
| 181-210  | 26                  |
| 211-240  | 4                   |
| 241-270  | 5                   |
| 271-300  | 1                   |
| 301-330  | 1                   |
| 331-360  | 1                   |
+ -------- + ------------------- +
```
11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

```sql
WITH BASIC AS (
SELECT 
   customer_id,
   plan_id AS basic_plan,
   start_date AS basic_start_date
FROM 
   subscriptions
WHERE
   plan_id = 1 
   AND YEAR(start_date) = 2020
),
PRO AS (
SELECT
   customer_id,
   plan_ID AS pro_plan,
   start_date AS pro_start_date
FROM 
   subscriptions 
WHERE
   plan_id = 2 
   AND YEAR(start_date) = 2020
)
SELECT
   COUNT(P.customer_id) AS downgraded_customer_count 
FROM
   BASIC B
   INNER JOIN PRO P
     ON B.customer_id = P.customer_id
WHERE 
    pro_start_date < basic_start_date

+ ------------------------------ +
| downgraded_customer_count      |
+ ------------------------------ +
| 0                              |
+ ------------------------------ +
```
Another way to structure the query is by using the LEAD function.

```sql
-- To obtain the start_date of the next plan from the subsequent row relative to the current row.
WITH next_plan_cte AS (
SELECT customer_id,
       plan_id,
       start_date,
       LEAD(plan_id) OVER(PARTITION BY customer_id ORDER BY plan_id) AS next_plan
FROM subscriptions
)
SELECT COUNT(customer_id) AS downgraded_customer_count 
FROM next_plan_cte
WHERE start_date <= '2020-12-31'
	AND plan_id = 2 AND next_plan = 1;

+ ------------------------------ +
| downgraded_customer_count      |
+ ------------------------------ +
| 0                              |
+ ------------------------------ +
```