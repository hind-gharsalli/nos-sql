-- 1. Create Keyspace
CREATE KEYSPACE IF NOT EXISTS ecommerce
WITH REPLICATION = {
    'class': 'SimpleStrategy',
    'replication_factor': 1
};

USE ecommerce;

-- 2. Create User UDT
CREATE TYPE IF NOT EXISTS user_type (
    user_id int,
    user_name text,
    city text
);

-- 3. Create Product UDT
CREATE TYPE IF NOT EXISTS product_type (
    product_name text,
    price double,
    quantity int
);

-- 4. Analytics Table: Sales by Product
CREATE TABLE IF NOT EXISTS sales_by_product (
    product text PRIMARY KEY,
    total_quantity int,
    total_revenue double,
    users set<frozen<user_type>>
);

-- 5. Analytics Table: Sales by User
CREATE TABLE IF NOT EXISTS sales_by_user (
    user_id int PRIMARY KEY,
    user_name text,
    total_orders int,
    total_revenue double,
    products set<frozen<product_type>>
);

-- 6. Optional Raw Orders Table (for reference / detailed queries)
CREATE TABLE IF NOT EXISTS orders_by_id (
    order_id int PRIMARY KEY,
    user_id int,
    user_name text,
    user_city text,
    date text,
    items list<frozen<tuple<text, double, int>>>
);
