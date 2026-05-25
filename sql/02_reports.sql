-- ==========================================
-- 1. ВИТРИНА ПРОДАЖ ПО ПРОДУКТАМ
-- ==========================================

-- 1.1 Топ-10 самых продаваемых продуктов
CREATE OR REPLACE VIEW top_10_products AS
SELECT 
    product_name,
    category,
    SUM(quantity) AS total_quantity_sold,
    SUM(price * quantity) AS total_revenue,
    COUNT(DISTINCT order_id) AS number_of_orders
FROM sales_stream
GROUP BY product_name, category
ORDER BY total_quantity_sold DESC
LIMIT 10;

-- 1.2 Общая выручка по категориям продуктов
CREATE OR REPLACE VIEW revenue_by_category AS
SELECT 
    category,
    SUM(price * quantity) AS total_revenue,
    COUNT(DISTINCT order_id) AS number_of_orders,
    SUM(quantity) AS total_items_sold
FROM sales_stream
GROUP BY category
ORDER BY total_revenue DESC;

-- 1.3 Средний рейтинг и количество отзывов для каждого продукта
CREATE OR REPLACE VIEW product_ratings AS
SELECT 
    product_name,
    category,
    ROUND(AVG(rating)::numeric, 2) AS avg_rating,
    SUM(review_count) AS total_reviews,
    COUNT(DISTINCT order_id) AS number_of_sales
FROM sales_stream
GROUP BY product_name, category
ORDER BY avg_rating DESC;

-- ==========================================
-- 2. ВИТРИНА ПРОДАЖ ПО КЛИЕНТАМ
-- ==========================================

-- 2.1 Топ-10 клиентов с наибольшей общей суммой покупок
CREATE OR REPLACE VIEW top_10_customers AS
SELECT 
    customer_id,
    SUM(price * quantity) AS total_spent,
    COUNT(DISTINCT order_id) AS number_of_orders,
    SUM(quantity) AS total_items_bought
FROM sales_stream
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 10;

-- 2.2 Распределение клиентов по странам
CREATE OR REPLACE VIEW customers_by_country AS
SELECT 
    customer_country,
    COUNT(DISTINCT customer_id) AS unique_customers,
    SUM(price * quantity) AS total_revenue,
    COUNT(DISTINCT order_id) AS number_of_orders
FROM sales_stream
GROUP BY customer_country
ORDER BY unique_customers DESC;

-- 2.3 Средний чек для каждого клиента
CREATE OR REPLACE VIEW avg_receipt_per_customer AS
SELECT 
    customer_id,
    ROUND(AVG(price * quantity)::numeric, 2) AS avg_receipt,
    COUNT(DISTINCT order_id) AS number_of_orders,
    SUM(price * quantity) AS total_spent
FROM sales_stream
GROUP BY customer_id
ORDER BY avg_receipt DESC;

-- ==========================================
-- 3. ВИТРИНА ПРОДАЖ ПО ВРЕМЕНИ
-- ==========================================

-- 3.1 Месячные и годовые тренды продаж
CREATE OR REPLACE VIEW monthly_sales_trends AS
SELECT 
    DATE_TRUNC('month', order_date) AS month,
    EXTRACT(YEAR FROM order_date) AS year,
    SUM(price * quantity) AS monthly_revenue,
    COUNT(DISTINCT order_id) AS number_of_orders,
    SUM(quantity) AS items_sold
FROM sales_stream
GROUP BY DATE_TRUNC('month', order_date), EXTRACT(YEAR FROM order_date)
ORDER BY month;

-- 3.2 Сравнение выручки за разные периоды (по годам)
CREATE OR REPLACE VIEW yearly_sales_comparison AS
SELECT 
    EXTRACT(YEAR FROM order_date) AS year,
    SUM(price * quantity) AS total_revenue,
    COUNT(DISTINCT order_id) AS number_of_orders,
    ROUND(AVG(price * quantity)::numeric, 2) AS avg_order_value
FROM sales_stream
GROUP BY EXTRACT(YEAR FROM order_date)
ORDER BY year;

-- 3.3 Средний размер заказа по месяцам
CREATE OR REPLACE VIEW avg_order_size_monthly AS
SELECT 
    DATE_TRUNC('month', order_date) AS month,
    ROUND(AVG(price * quantity)::numeric, 2) AS avg_order_value,
    ROUND(AVG(quantity)::numeric, 2) AS avg_items_per_order,
    COUNT(DISTINCT order_id) AS number_of_orders
FROM sales_stream
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month;

-- ==========================================
-- 4. ВИТРИНА ПРОДАЖ ПО МАГАЗИНАМ
-- ==========================================

-- 4.1 Топ-5 магазинов с наибольшей выручкой
CREATE OR REPLACE VIEW top_5_stores AS
SELECT 
    customer_city AS store_location,
    customer_country,
    SUM(price * quantity) AS total_revenue,
    COUNT(DISTINCT order_id) AS number_of_orders,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM sales_stream
GROUP BY customer_city, customer_country
ORDER BY total_revenue DESC
LIMIT 5;

-- 4.2 Распределение продаж по городам и странам
CREATE OR REPLACE VIEW sales_by_location AS
SELECT 
    customer_country,
    customer_city,
    SUM(price * quantity) AS total_revenue,
    COUNT(DISTINCT order_id) AS number_of_orders,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM sales_stream
GROUP BY customer_country, customer_city
ORDER BY total_revenue DESC;

-- 4.3 Средний чек для каждого магазина (города)
CREATE OR REPLACE VIEW avg_receipt_per_store AS
SELECT 
    customer_city AS store_location,
    customer_country,
    ROUND(AVG(price * quantity)::numeric, 2) AS avg_receipt,
    COUNT(DISTINCT order_id) AS number_of_orders
FROM sales_stream
GROUP BY customer_city, customer_country
ORDER BY avg_receipt DESC;

-- ==========================================
-- 5. ВИТРИНА ПРОДАЖ ПО ПОСТАВЩИКАМ
-- ==========================================

-- 5.1 Топ-5 поставщиков с наибольшей выручкой
CREATE OR REPLACE VIEW top_5_suppliers AS
SELECT 
    supplier,
    supplier_country,
    SUM(price * quantity) AS total_revenue,
    COUNT(DISTINCT order_id) AS number_of_orders,
    COUNT(DISTINCT product_id) AS unique_products
FROM sales_stream
GROUP BY supplier, supplier_country
ORDER BY total_revenue DESC
LIMIT 5;

-- 5.2 Средняя цена товаров от каждого поставщика
CREATE OR REPLACE VIEW avg_price_per_supplier AS
SELECT 
    supplier,
    supplier_country,
    ROUND(AVG(price)::numeric, 2) AS avg_product_price,
    COUNT(DISTINCT product_id) AS unique_products,
    SUM(quantity) AS total_items_sold
FROM sales_stream
GROUP BY supplier, supplier_country
ORDER BY avg_product_price DESC;

-- 5.3 Распределение продаж по странам поставщиков
CREATE OR REPLACE VIEW sales_by_supplier_country AS
SELECT 
    supplier_country,
    SUM(price * quantity) AS total_revenue,
    COUNT(DISTINCT supplier) AS number_of_suppliers,
    COUNT(DISTINCT order_id) AS number_of_orders
FROM sales_stream
GROUP BY supplier_country
ORDER BY total_revenue DESC;

-- ==========================================
-- 6. ВИТРИНА КАЧЕСТВА ПРОДУКЦИИ
-- ==========================================

-- 6.1 Продукты с наивысшим и наименьшим рейтингом
CREATE OR REPLACE VIEW highest_rated_products AS
SELECT 
    product_name,
    category,
    ROUND(AVG(rating)::numeric, 2) AS avg_rating,
    SUM(review_count) AS total_reviews,
    SUM(quantity) AS total_sold
FROM sales_stream
GROUP BY product_name, category
HAVING AVG(rating) >= 4.5
ORDER BY avg_rating DESC;

CREATE OR REPLACE VIEW lowest_rated_products AS
SELECT 
    product_name,
    category,
    ROUND(AVG(rating)::numeric, 2) AS avg_rating,
    SUM(review_count) AS total_reviews,
    SUM(quantity) AS total_sold
FROM sales_stream
GROUP BY product_name, category
HAVING AVG(rating) <= 2.5
ORDER BY avg_rating;

-- 6.2 Корреляция между рейтингом и объемом продаж
CREATE OR REPLACE VIEW rating_sales_correlation AS
SELECT 
    CASE 
        WHEN AVG(rating) >= 4.0 THEN 'High Rating (4-5)'
        WHEN AVG(rating) >= 3.0 THEN 'Medium Rating (3-4)'
        ELSE 'Low Rating (1-3)'
    END AS rating_category,
    COUNT(DISTINCT product_id) AS number_of_products,
    SUM(quantity) AS total_items_sold,
    ROUND(AVG(rating)::numeric, 2) AS avg_rating,
    ROUND(AVG(price * quantity)::numeric, 2) AS avg_revenue_per_sale
FROM sales_stream
GROUP BY 
    CASE 
        WHEN AVG(rating) >= 4.0 THEN 'High Rating (4-5)'
        WHEN AVG(rating) >= 3.0 THEN 'Medium Rating (3-4)'
        ELSE 'Low Rating (1-3)'
    END
ORDER BY avg_rating DESC;

-- 6.3 Продукты с наибольшим количеством отзывов
CREATE OR REPLACE VIEW most_reviewed_products AS
SELECT 
    product_name,
    category,
    SUM(review_count) AS total_reviews,
    ROUND(AVG(rating)::numeric, 2) AS avg_rating,
    SUM(quantity) AS total_sold
FROM sales_stream
GROUP BY product_name, category
ORDER BY total_reviews DESC
LIMIT 20;