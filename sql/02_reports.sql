DROP VIEW IF EXISTS top_10_products;
DROP VIEW IF EXISTS revenue_by_category;
DROP VIEW IF EXISTS product_ratings;
DROP VIEW IF EXISTS top_10_customers;
DROP VIEW IF EXISTS customers_by_country;
DROP VIEW IF EXISTS avg_receipt_per_customer;
DROP VIEW IF EXISTS monthly_sales_trends;
DROP VIEW IF EXISTS yearly_sales_comparison;
DROP VIEW IF EXISTS avg_order_size_monthly;
DROP VIEW IF EXISTS top_5_stores;
DROP VIEW IF EXISTS sales_by_location;
DROP VIEW IF EXISTS avg_receipt_per_store;
DROP VIEW IF EXISTS top_5_suppliers;
DROP VIEW IF EXISTS avg_price_per_supplier;
DROP VIEW IF EXISTS sales_by_supplier_country;
DROP VIEW IF EXISTS highest_rated_products;
DROP VIEW IF EXISTS lowest_rated_products;
DROP VIEW IF EXISTS rating_sales_correlation;
DROP VIEW IF EXISTS most_reviewed_products;

-- 1. Витрина продаж по продуктам
CREATE VIEW top_10_products AS
SELECT 
    product_name,
    category,
    SUM(quantity) AS total_quantity_sold,
    SUM(price * quantity) AS total_revenue,
    COUNT(DISTINCT order_id) AS number_of_orders
FROM sales_stream
GROUP BY product_name, category
ORDER BY total_revenue DESC
LIMIT 10;

CREATE VIEW revenue_by_category AS
SELECT 
    category,
    SUM(price * quantity) AS total_revenue,
    COUNT(DISTINCT order_id) AS number_of_orders,
    SUM(quantity) AS total_items_sold
FROM sales_stream
GROUP BY category
ORDER BY total_revenue DESC;

CREATE VIEW product_ratings AS
SELECT 
    product_name,
    category,
    ROUND(AVG(rating)::numeric, 2) AS avg_rating,
    COUNT(DISTINCT order_id) AS number_of_sales
FROM sales_stream
WHERE rating IS NOT NULL
GROUP BY product_name, category
ORDER BY avg_rating DESC;

-- 2. Витрина продаж по клиентам
CREATE VIEW top_10_customers AS
SELECT 
    customer_id,
    customer_country,
    SUM(price * quantity) AS total_spent,
    COUNT(DISTINCT order_id) AS number_of_orders
FROM sales_stream
GROUP BY customer_id, customer_country
ORDER BY total_spent DESC
LIMIT 10;

CREATE VIEW customers_by_country AS
SELECT 
    customer_country,
    COUNT(DISTINCT customer_id) AS unique_customers,
    SUM(price * quantity) AS total_revenue
FROM sales_stream
GROUP BY customer_country
ORDER BY total_revenue DESC;

CREATE VIEW avg_receipt_per_customer AS
SELECT 
    customer_id,
    ROUND(AVG(price * quantity)::numeric, 2) AS avg_receipt,
    COUNT(DISTINCT order_id) AS number_of_orders
FROM sales_stream
GROUP BY customer_id
ORDER BY avg_receipt DESC;

-- 3. Витрина продаж по времени
CREATE VIEW monthly_sales_trends AS
SELECT 
    DATE_TRUNC('month', order_date) AS month,
    EXTRACT(YEAR FROM order_date) AS year,
    SUM(price * quantity) AS monthly_revenue,
    COUNT(DISTINCT order_id) AS number_of_orders
FROM sales_stream
GROUP BY DATE_TRUNC('month', order_date), EXTRACT(YEAR FROM order_date)
ORDER BY month;

CREATE VIEW yearly_sales_comparison AS
SELECT 
    EXTRACT(YEAR FROM order_date) AS year,
    SUM(price * quantity) AS total_revenue,
    COUNT(DISTINCT order_id) AS number_of_orders
FROM sales_stream
GROUP BY EXTRACT(YEAR FROM order_date)
ORDER BY year;

CREATE VIEW avg_order_size_monthly AS
SELECT 
    DATE_TRUNC('month', order_date) AS month,
    ROUND(AVG(price * quantity)::numeric, 2) AS avg_order_value,
    COUNT(DISTINCT order_id) AS number_of_orders
FROM sales_stream
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month;

-- 4. Витрина продаж по магазинам
CREATE VIEW top_5_stores AS
SELECT 
    customer_city AS store_location,
    customer_country,
    SUM(price * quantity) AS total_revenue,
    COUNT(DISTINCT order_id) AS number_of_orders
FROM sales_stream
GROUP BY customer_city, customer_country
ORDER BY total_revenue DESC
LIMIT 5;

CREATE VIEW sales_by_location AS
SELECT 
    customer_country,
    customer_city,
    SUM(price * quantity) AS total_revenue,
    COUNT(DISTINCT order_id) AS number_of_orders
FROM sales_stream
GROUP BY customer_country, customer_city
ORDER BY total_revenue DESC;

CREATE VIEW avg_receipt_per_store AS
SELECT 
    customer_city AS store_location,
    customer_country,
    ROUND(AVG(price * quantity)::numeric, 2) AS avg_receipt
FROM sales_stream
GROUP BY customer_city, customer_country
ORDER BY avg_receipt DESC;

-- 5. Витрина продаж по поставщикам
CREATE VIEW top_5_suppliers AS
SELECT 
    supplier,
    supplier_country,
    SUM(price * quantity) AS total_revenue,
    COUNT(DISTINCT order_id) AS number_of_orders
FROM sales_stream
GROUP BY supplier, supplier_country
ORDER BY total_revenue DESC
LIMIT 5;

CREATE VIEW avg_price_per_supplier AS
SELECT 
    supplier,
    supplier_country,
    ROUND(AVG(price)::numeric, 2) AS avg_product_price
FROM sales_stream
GROUP BY supplier, supplier_country
ORDER BY avg_product_price DESC;

CREATE VIEW sales_by_supplier_country AS
SELECT 
    supplier_country,
    SUM(price * quantity) AS total_revenue
FROM sales_stream
GROUP BY supplier_country
ORDER BY total_revenue DESC;

-- 6. Витрина качества продукции
CREATE VIEW highest_rated_products AS
SELECT 
    product_name,
    category,
    ROUND(AVG(rating)::numeric, 2) AS avg_rating,
    COUNT(DISTINCT order_id) AS number_of_sales
FROM sales_stream
WHERE rating IS NOT NULL
GROUP BY product_name, category
HAVING AVG(rating) >= 4.0
ORDER BY avg_rating DESC;

CREATE VIEW lowest_rated_products AS
SELECT 
    product_name,
    category,
    ROUND(AVG(rating)::numeric, 2) AS avg_rating,
    COUNT(DISTINCT order_id) AS number_of_sales
FROM sales_stream
WHERE rating IS NOT NULL
GROUP BY product_name, category
HAVING AVG(rating) <= 2.5
ORDER BY avg_rating ASC;

CREATE VIEW rating_sales_correlation AS
SELECT 
    CASE 
        WHEN avg_rating >= 4.0 THEN 'High Rating'
        WHEN avg_rating >= 3.0 THEN 'Medium Rating'
        ELSE 'Low Rating'
    END AS rating_category,
    COUNT(*) AS number_of_products,
    SUM(total_items_sold) AS total_items_sold,
    ROUND(AVG(avg_rating)::numeric, 2) AS avg_rating
FROM (
    SELECT 
        product_id,
        product_name,
        ROUND(AVG(rating)::numeric, 2) AS avg_rating,
        SUM(quantity) AS total_items_sold
    FROM sales_stream
    WHERE rating IS NOT NULL
    GROUP BY product_id, product_name
) AS product_ratings
GROUP BY 
    CASE 
        WHEN avg_rating >= 4.0 THEN 'High Rating'
        WHEN avg_rating >= 3.0 THEN 'Medium Rating'
        ELSE 'Low Rating'
    END
ORDER BY avg_rating DESC;

CREATE VIEW most_reviewed_products AS
SELECT 
    product_name,
    category,
    COUNT(DISTINCT order_id) AS number_of_sales,
    ROUND(AVG(rating)::numeric, 2) AS avg_rating
FROM sales_stream
GROUP BY product_name, category
ORDER BY number_of_sales DESC
LIMIT 10;