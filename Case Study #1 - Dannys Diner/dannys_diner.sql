-- Crear esquema
CREATE DATABASE dannys_diner;

USE dannys_diner;

-- Crear tabla members
CREATE TABLE IF NOT EXISTS members (
    customer_id VARCHAR(1) NOT NULL,
    join_date DATE,
    PRIMARY KEY (customer_id)
)
-- Poblar con datos tabla members
INSERT INTO
    members (customer_id, join_date)
VALUES ('A', '2021-01-07'),
    ('B', '2021-01-09');

-- Crear tabla menu
CREATE TABLE IF NOT EXISTS menu (
    product_id INT NOT NULL,
    product_name VARCHAR(5) NOT NULL,
    price INT NOT NULL,
    PRIMARY KEY (product_id)
);

-- Poblar con datos tabla menu
INSERT INTO
    menu (
        product_id,
        product_name,
        price
    )
VALUES (1, 'sushi', 10),
    (2, 'curry', 15),
    (3, 'ramen', 12);

-- Crear tabla sales
CREATE TABLE IF NOT EXISTS sales (
    customer_id VARCHAR(1) NOT NULL,
    order_date DATE,
    product_id INT NOT NULL
);

-- Poblar con datos tabla sales
INSERT INTO
    sales (
        customer_id,
        order_date,
        product_id
    )
VALUES ('A', '2021-01-01', 1),
    ('A', '2021-01-01', 2),
    ('A', '2021-01-07', 2),
    ('A', '2021-01-10', 3),
    ('A', '2021-01-11', 3),
    ('A', '2021-01-11', 3),
    ('B', '2021-01-01', 2),
    ('B', '2021-01-02', 2),
    ('B', '2021-01-04', 1),
    ('B', '2021-01-11', 1),
    ('B', '2021-01-16', 3),
    ('B', '2021-02-01', 3),
    ('C', '2021-01-01', 3),
    ('C', '2021-01-01', 3),
    ('C', '2021-01-07', 3);

-- 1. What is the total amount each customer spent at the restaurant?
SELECT 
	s.customer_id AS customer
    , SUM(men.price) total_spend
FROM sales AS s
    JOIN menu AS men ON men.product_id = s.product_id
GROUP BY
    customer;

-- 2. How many days has each customer visited the restaurant
SELECT
	customer_id AS customer
    , COUNT(DISTINCT order_date) AS visits
FROM 
	sales AS s
	JOIN menu AS m ON s.product_id = m.product_id
GROUP BY
		customer
;
	
-- 3. What was the first item from the menu purchased by each customer?
WITH CTE AS (
  SELECT
    customer_id
    , order_date
    , product_name
    , RANK() OVER( PARTITION BY customer_id ORDER BY order_date) AS rnk
    , ROW_NUMBER() OVER( PARTITION BY customer_id ORDER BY order_date ASC) AS rn
  FROM
	sales AS s
    INNER JOIN menu AS m ON s.product_id = m.product_id
)
SELECT
  customer_id
  , product_name
FROM
  CTE
WHERE
  rnk = 1
;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT 
  m.product_name AS item
  , COUNT(s.order_date) AS total_purchases
FROM menu AS m 
  JOIN sales AS s ON s.product_id = m.product_id
GROUP BY 
  item
ORDER BY 
  total_purchases DESC
LIMIT 1    
;

-- 5. Which item was the most popular for each customer?
WITH CTE AS (
  SELECT
    customer_id
    , COUNT(order_date) AS total_purchases
    , product_name
    , RANK() OVER( PARTITION BY customer_id ORDER BY order_date) AS rnk
    , ROW_NUMBER() OVER( PARTITION BY customer_id ORDER BY order_date ASC) AS rn
  FROM
	sales AS s
    INNER JOIN menu AS m ON s.product_id = m.product_id
)
SELECT
  customer_id
  , product_name
FROM
  CTE
WHERE
  rnk = 1
;

WITH CTE AS (
SELECT 
  s.customer_id AS customer
  , m.product_name AS item
  , COUNT(s.order_date) AS total_purchases
  , RANK() OVER( PARTITION BY customer_id ORDER BY COUNT(s.order_date) DESC) AS rnk
  , ROW_NUMBER() OVER( PARTITION BY customer_id ORDER BY COUNT(s.order_date) DESC) AS rn
FROM menu AS m 
  JOIN sales AS s ON s.product_id = m.product_id
GROUP BY
  item
  , customer
)
SELECT
  customer
  , item
FROM 
  CTE
WHERE
  rnk = 1
;

-- 6. Which item was purchased first by the customer after they became a member?
    
WITH CTE AS (
SELECT 
 s.order_date AS purchase
 , join_date
 , m.product_name AS item
 , s.customer_id AS customer
 , RANK() OVER( PARTITION BY s.customer_id ORDER BY s.order_date ASC) AS rnk
 , ROW_NUMBER() OVER( PARTITION BY s.customer_id ORDER BY s.order_date ASC) AS rn 
FROM
  menu AS m
  JOIN sales AS s ON s.product_id = m.product_id
  JOIN members AS me ON s.customer_id = me.customer_id
WHERE 
  s.order_date >= me.join_date
)
SELECT
  item
  , customer
FROM 
  CTE
WHERE
  rnk = 1
;

-- 7. Which item was purchased just before the customer became a member?
WITH CTE AS (
  SELECT 
    s.order_date AS purchase
    , join_date
    , m.product_name AS item
    , s.customer_id AS customer
    , RANK() OVER( PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS rnk
    , ROW_NUMBER() OVER( PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS rn 
  FROM
    menu AS m
    JOIN sales AS s ON s.product_id = m.product_id
    JOIN members AS me ON s.customer_id = me.customer_id
  WHERE 
    s.order_date < me.join_date
)
SELECT
  item
  , customer
FROM 
  CTE
WHERE
  rnk = 1
;

-- 8. What is the total items and amount spent for each member before they became a member?
SELECT 
	COUNT( DISTINCT m.product_name) AS total_items,
    s.customer_id AS customer
   , SUM(m.price) AS amount_spent
FROM
    menu AS m
    JOIN sales AS s ON s.product_id = m.product_id
    JOIN members AS me ON s.customer_id = me.customer_id
WHERE
	s.order_date < me.join_date
GROUP BY
	customer
ORDER BY 
	customer,
    amount_spent
;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT
	customer
    , SUM(points) AS total_points
FROM 
  (SELECT
     s.customer_id AS customer,
	 m.product_name,
     m.price,
   CASE 
	WHEN m.product_name = 'sushi' THEN m.price * 20
    ELSE m.price * 10
    END AS points
  FROM 
  sales s 
  JOIN menu m ON s.product_id = m.product_id
  ) AS subquery 
GROUP BY
  customer
;
 
-- Alternative way:
SELECT
   s.customer_id AS customer
   , SUM(CASE 
	     WHEN m.product_name = 'sushi' THEN m.price * 20
         ELSE m.price * 10
         END
         ) AS points
FROM 
  sales s 
  JOIN menu m ON s.product_id = m.product_id
GROUP BY
  customer
;

-- 10. In the first week after a customer joins the program 
-- (including their join date) they earn 2x points on all items, 
-- not just sushi - how many points do customer A and B have at the end of January?
SELECT
   s.customer_id AS customer
   , SUM(
	   CASE 
		 WHEN s.order_date BETWEEN mem.join_date AND mem.join_date + 6 THEN price * 10 * 2
         WHEN product_name = 'sushi' THEN price * 10 * 2 
		 ELSE m.price * 10
         END) AS points
FROM 
  sales s 
  JOIN menu m ON s.product_id = m.product_id
  JOIN members AS mem ON s.customer_id = mem.customer_id
WHERE 
   s.order_date BETWEEN '2021-01-01' AND '2021-01-31' -- filter only january
   AND s.customer_id IN ('A', 'B')
GROUP BY
customer
;

-- Bonus Questions - Join All The Things
SELECT
  s.customer_id,
  s.order_date,
  m.product_name,
  m.price,
  CASE
    WHEN s.order_date >= mem.join_date THEN 'Y'
    WHEN join_date = NULL THEN 'N'
    ELSE 'N' 
    END AS member
FROM 
  sales s 
  LEFT JOIN members AS mem ON s.customer_id = mem.customer_id
  INNER JOIN menu m ON s.product_id = m.product_id
ORDER BY
  s.customer_id,
  s.order_date,
  m.price DESC
;


