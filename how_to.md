# Инструкция по запуску

## Шаг 1: Запуск всех сервисов

```
docker compose up -d
```

После этого сервисы запустятся автоматически:

* **PostgreSQL** (localhost:5432) — analyst / analyst_pass

* **Kafka** (localhost:9092)

* **NiFi** (https://localhost:8443) — admin / adminAdmin12345!

* **Metabase** (http://localhost:3000)

* **Data Generator** — автоматически отправит CSV в Kafka


## Шаг 2: Настройка NiFi
### 2.1 Установка PostgreSQL драйвера
```
docker exec -u root nifi curl -L https://jdbc.postgresql.org/download/postgresql-42.6.0.jar \
-o /opt/nifi/nifi-current/lib/postgresql-42.6.0.jar

docker restart nifi
```

### 2.2 Настройка Controller Services
0. Открываем NiFi (https://localhost:8443) и вводим логин и пароль

1. Кликаем на значок меню (3 горизонтальные полоски) -> Controller Settings -> Management Controller Services -> тыкаем на плюсик (+)

2. Добавляем DBCPConnectionPool:

    Название: PostgreSQL-Pool

    Свойства:

        * Database Connection URL: `jdbc:postgresql://postgres:5432/sales_db`

        * Database Driver Class Name: `org.postgresql.Driver`

        * Database Driver Location(s): `/opt/nifi/nifi-current/lib/postgresql-42.6.0.jar`

        * Database User: `analyst`

        * Password: `analyst_pass`

3. Нажимаем на значок молнии (`Enable`)

4. Добавляем новый Controller Service -> JsonTreeReader:

    Свойства:

        * Schema Access Strategy: `Infer Schema`

    Нажимаем `Enable`

### 2.3 Слздаем Flow

1. Добавляем процессор **ConsumeKafka_2_6**:

    Свойства:

        * Kafka Brokers: `kafka:29092`

        * Topic Name: `sales_stream`

        * Group ID: `nifi-sales-group-v2`

        * Auto Offset Reset: `earliest`

2. Добавляем еще один процессор **PutDatabaseRecord**:

    Свойства:

        * Record Reader: `JsonTreeReader`

        * Database Connection Pool: `PostgreSQL-Pool`

        * Table Name: `sales_stream`

        * Translate Field Names: `false` (важно!)

        * Unmatched Field Behavior: `Ignore Unmatched Fields`

        * Unmatched Column Behavior: `Ignore Unmatched Columns`

        * Statement Type: `INSERT`

3. Соединяем success от ConsumeKafka_2_6 -> PutDatabaseRecord

4. У PutDatabaseRecord ставим Auto-terminate на failure и retry

5. Выделяем оба процессора (ctrl + A) -> Start


## Шаг 3: Настройка Metabase 

1. Открываем http://localhost:3000

*Примечание: Может не сразу открыться из-за долгих миграций при первом запуске Metabase, следует подождать несколько минут*

2. Создаем учётную запись

3. Подключаем базу:

    * Тип: PostgreSQL

    * Host: postgres

    * Port: 5432

    * Database: sales_db

    * Username: analyst

    * Password: analyst_pass


## Шаг 4: SQL-запросы отчетов
Т.к. все отчеты созданы как вьюшки в БД, достаточно выполнить следующие запросы
```
-- 1.1 Топ-10 самых продаваемых продуктов
SELECT * FROM top_10_products;

-- 1.2 Общая выручка по категориям продуктов
SELECT * FROM revenue_by_category;

-- 1.3 Средний рейтинг и количество отзывов для каждого продукта
SELECT * FROM product_ratings;

-- 2.1 Топ-10 клиентов с наибольшей общей суммой покупок
SELECT * FROM top_10_customers;

-- 2.2 Распределение клиентов по странам
SELECT * FROM customers_by_country;

-- 2.3 Средний чек для каждого клиента
SELECT * FROM avg_receipt_per_customer;

-- 3.1 Месячные и годовые тренды продаж
SELECT * FROM monthly_sales_trends;

-- 3.2 Сравнение выручки за разные периоды (по годам)
SELECT * FROM yearly_sales_comparison;

-- 3.3 Средний размер заказа по месяцам
SELECT * FROM avg_order_size_monthly;

-- 4.1 Топ-5 магазинов с наибольшей выручкой
SELECT * FROM  top_5_stores;

-- 4.2 Распределение продаж по городам и странам
SELECT * FROM  sales_by_location;

-- 4.3 Средний чек для каждого магазина (города)
SELECT * FROM avg_receipt_per_store;

-- 5.1 Топ-5 поставщиков с наибольшей выручкой
SELECT * FROM top_5_suppliers;

-- 5.2 Средняя цена товаров от каждого поставщика
SELECT * FROM avg_price_per_supplier;

-- 5.3 Распределение продаж по странам поставщиков
SELECT * FROM sales_by_supplier_country;

-- 6.1 Продукты с наивысшим и наименьшим рейтингом
SELECT * FROM  highest_rated_products;

SELECT * FROM lowest_rated_products;

-- 6.2 Корреляция между рейтингом и объемом продаж
SELECT * FROM rating_sales_correlation;

-- 6.3 Продукты с наибольшим количеством отзывов
SELECT * FROM  most_reviewed_products;
```
