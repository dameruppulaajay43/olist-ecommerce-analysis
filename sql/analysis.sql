CREATE DATABASE olist;
USE olist;
select * from orders


ALTER TABLE orders ALTER COLUMN order_id VARCHAR(50) NOT NULL;
ALTER TABLE orders ALTER COLUMN customer_id VARCHAR(50) NOT NULL;
ALTER TABLE customers ALTER COLUMN customer_id VARCHAR(50) NOT NULL;
ALTER TABLE customers ALTER COLUMN customer_unique_id VARCHAR(50) NOT NULL;
ALTER TABLE order_items ALTER COLUMN order_id VARCHAR(50) NOT NULL;
ALTER TABLE order_items ALTER COLUMN product_id VARCHAR(50) NOT NULL;
ALTER TABLE order_payments ALTER COLUMN order_id VARCHAR(50) NOT NULL;
ALTER TABLE order_reviews ALTER COLUMN order_id VARCHAR(50) NOT NULL;
ALTER TABLE products ALTER COLUMN product_id VARCHAR(50) NOT NULL;
ALTER TABLE products ALTER COLUMN product_category_name VARCHAR(100) NULL;
ALTER TABLE product_category_name_translation ALTER COLUMN product_category_name VARCHAR(100) NOT NULL;

CREATE INDEX ix_orders_order_id      ON orders(order_id);
CREATE INDEX ix_orders_customer_id   ON orders(customer_id);
CREATE INDEX ix_customers_customer_id ON customers(customer_id);
CREATE INDEX ix_items_order_id       ON order_items(order_id);
CREATE INDEX ix_items_product_id     ON order_items(product_id);
CREATE INDEX ix_payments_order_id    ON order_payments(order_id);
CREATE INDEX ix_reviews_order_id     ON order_reviews(order_id);
CREATE INDEX ix_products_product_id  ON products(product_id);

-- How many orders per status?
SELECT order_status, COUNT(*) AS orders
FROM orders GROUP BY order_status ORDER BY orders DESC;

-- Date range
SELECT MIN(order_purchase_timestamp) AS first_order,
       MAX(order_purchase_timestamp) AS last_order
FROM orders;

--Monthly revenue and orders
SELECT FORMAT(o.order_purchase_timestamp, 'yyyy-MM') AS [month],
       COUNT(DISTINCT o.order_id) AS orders,
       ROUND(SUM(p.payment_value), 2) AS revenue
FROM orders o
JOIN order_payments p ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY FORMAT(o.order_purchase_timestamp, 'yyyy-MM')
ORDER BY [month];

--Month-over-month growth (window function)
WITH monthly AS (
    SELECT FORMAT(o.order_purchase_timestamp, 'yyyy-MM') AS [month],
           SUM(p.payment_value) AS revenue
    FROM orders o
    JOIN order_payments p ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY FORMAT(o.order_purchase_timestamp, 'yyyy-MM')
)
SELECT [month],
       ROUND(revenue, 2) AS revenue,
       ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY [month]))
             / NULLIF(LAG(revenue) OVER (ORDER BY [month]), 0), 1) AS mom_growth_pct
FROM monthly
ORDER BY [month];

--Top 10 categories by revenue
SELECT TOP 10
       COALESCE(t.product_category_name_english, pr.product_category_name, 'unknown') AS category,
       ROUND(SUM(oi.price), 2) AS revenue,
       COUNT(DISTINCT oi.order_id) AS orders
FROM order_items oi
JOIN orders o   ON oi.order_id = o.order_id AND o.order_status = 'delivered'
JOIN products pr ON oi.product_id = pr.product_id
LEFT JOIN product_category_name_translation t
       ON pr.product_category_name = t.product_category_name
GROUP BY COALESCE(t.product_category_name_english, pr.product_category_name, 'unknown')
ORDER BY revenue DESC;


--Top 3 categories per year (RANK)
WITH cat AS (
    SELECT YEAR(o.order_purchase_timestamp) AS yr,
           COALESCE(t.product_category_name_english, pr.product_category_name, 'unknown') AS category,
           SUM(oi.price) AS revenue
    FROM order_items oi
    JOIN orders o   ON oi.order_id = o.order_id AND o.order_status = 'delivered'
    JOIN products pr ON oi.product_id = pr.product_id
    LEFT JOIN product_category_name_translation t
           ON pr.product_category_name = t.product_category_name
    GROUP BY YEAR(o.order_purchase_timestamp),
             COALESCE(t.product_category_name_english, pr.product_category_name, 'unknown')
)
SELECT yr, category, ROUND(revenue, 2) AS revenue, rnk
FROM (SELECT *, RANK() OVER (PARTITION BY yr ORDER BY revenue DESC) AS rnk FROM cat) x
WHERE rnk <= 3
ORDER BY yr, rnk;


--Delivery time and late rate by state
SELECT c.customer_state,
       COUNT(*) AS orders,
       ROUND(AVG(CAST(DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date) AS FLOAT)), 1) AS avg_delivery_days,
       ROUND(100.0 * SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END) / COUNT(*), 1) AS late_pct
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered' AND o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_delivery_days DESC;

--Does late delivery hurt reviews?

WITH r AS (
    SELECT order_id, AVG(CAST(review_score AS FLOAT)) AS score
    FROM order_reviews GROUP BY order_id
),
d AS (
    SELECT order_id,
           CASE WHEN order_delivered_customer_date > order_estimated_delivery_date
                THEN 'Late' ELSE 'On time' END AS delivery_status
    FROM orders
    WHERE order_status = 'delivered' AND order_delivered_customer_date IS NOT NULL
)
SELECT d.delivery_status, COUNT(*) AS orders, ROUND(AVG(r.score), 2) AS avg_review
FROM d JOIN r ON d.order_id = r.order_id
GROUP BY d.delivery_status;

--One-time vs repeat customers
WITH cust AS (
    SELECT c.customer_unique_id,
           COUNT(DISTINCT o.order_id) AS orders,
           SUM(p.payment_value) AS spend
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN order_payments p ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT CASE WHEN orders = 1 THEN 'One-time' ELSE 'Repeat' END AS customer_type,
       COUNT(*) AS customers,
       ROUND(SUM(spend), 2) AS revenue,
       ROUND(100.0 * SUM(spend) / SUM(SUM(spend)) OVER (), 1) AS revenue_share_pct
FROM cust
GROUP BY CASE WHEN orders = 1 THEN 'One-time' ELSE 'Repeat' END;


--Payment methods
SELECT payment_type,
       COUNT(DISTINCT order_id) AS orders,
       ROUND(SUM(payment_value), 2) AS revenue,
       ROUND(AVG(payment_value), 2) AS avg_per_payment
FROM order_payments
GROUP BY payment_type
ORDER BY revenue DESC;