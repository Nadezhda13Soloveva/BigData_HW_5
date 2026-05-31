DROP TABLE IF EXISTS sales_stream;

CREATE TABLE sales_stream (
    id                  BIGINT,
    order_id            TEXT,
    product_id          TEXT,
    customer_id         TEXT,
    product_name        TEXT,
    category            TEXT,
    price               NUMERIC(12,2),
    quantity            NUMERIC(10,0),
    order_date          TIMESTAMP,
    customer_country    TEXT,
    customer_city       TEXT,
    supplier            TEXT,
    supplier_country    TEXT,
    rating              NUMERIC(3,2)
);

-- Индексы для отчётов
CREATE INDEX idx_sales_category ON sales_stream(category);
CREATE INDEX idx_sales_order_date ON sales_stream(order_date);
CREATE INDEX idx_sales_country ON sales_stream(customer_country);