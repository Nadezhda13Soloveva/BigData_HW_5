-- Создание таблицы для потоковых данных
CREATE TABLE IF NOT EXISTS sales_stream (
    id SERIAL,
    order_id VARCHAR(255),
    product_id VARCHAR(255),
    customer_id VARCHAR(255),
    product_name VARCHAR(500),
    category VARCHAR(100),
    price NUMERIC(10, 2),
    quantity INTEGER,
    order_date DATE,
    customer_country VARCHAR(100),
    customer_city VARCHAR(200),
    supplier VARCHAR(200),
    supplier_country VARCHAR(100),
    rating NUMERIC(3, 1),
    review_count INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- Индексы для оптимизации запросов отчетов
CREATE INDEX IF NOT EXISTS idx_category ON sales_stream(category);
CREATE INDEX IF NOT EXISTS idx_order_date ON sales_stream(order_date);
CREATE INDEX IF NOT EXISTS idx_customer_id ON sales_stream(customer_id);
CREATE INDEX IF NOT EXISTS idx_product_id ON sales_stream(product_id);
CREATE INDEX IF NOT EXISTS idx_supplier ON sales_stream(supplier);
CREATE INDEX IF NOT EXISTS idx_country ON sales_stream(customer_country);