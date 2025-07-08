-- ===============================
-- 📋 DATABASE OBJECT EXPLORATION
-- ===============================

-- View all tables
SELECT * FROM INFORMATION_SCHEMA.TABLES;

-- View all columns in a specific table
SELECT * 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'gold.dim_customers';

-- Distinct customer countries
SELECT DISTINCT country 
FROM [gold.dim_customers];

-- List of all product categories and subcategories
SELECT category, subcategory, product_name 
FROM [gold.dim_products]  
ORDER BY category, subcategory, product_name;


-- ===============================
-- 📅 TIME RANGE & DEMOGRAPHICS
-- ===============================

-- First and last order dates + total sales range in years
SELECT 
    MIN(order_date) AS first_order,
    MAX(order_date) AS last_order,
    DATEDIFF(YEAR, MIN(order_date), MAX(order_date)) AS order_range_years
FROM [gold.fact_sales];

-- Youngest and oldest customers
SELECT 
    DATEDIFF(YEAR, MIN(birthdate), GETDATE()) AS oldest_customer,
    DATEDIFF(YEAR, MAX(birthdate), GETDATE()) AS youngest_customer 
FROM [gold.dim_customers];


-- ===============================
-- 💰 KEY METRICS
-- ===============================

-- Total sales
SELECT SUM(sales_amount) AS total_sales 
FROM [gold.fact_sales];

-- Total items sold
SELECT SUM(quantity) AS items_sold 
FROM [gold.fact_sales];

-- Total number of orders
SELECT COUNT(DISTINCT order_number) AS total_orders 
FROM [gold.fact_sales];

-- Total number of products
SELECT COUNT(product_id) AS total_products 
FROM [gold.dim_products];

-- Total number of customers
SELECT COUNT(customer_id) AS total_customers 
FROM [gold.dim_customers];

-- Customers who have placed at least one order
SELECT COUNT(DISTINCT customer_key) AS active_customers 
FROM [gold.fact_sales];


-- ===============================
-- 🧾 BUSINESS METRICS REPORT
-- ===============================

SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value 
FROM [gold.fact_sales]
UNION ALL
SELECT 'Total Quantity', SUM(quantity) 
FROM [gold.fact_sales]
UNION ALL
SELECT 'Average Price', AVG(price) 
FROM [gold.fact_sales]
UNION ALL
SELECT 'Total Number of Orders', COUNT(DISTINCT order_number) 
FROM [gold.fact_sales]
UNION ALL
SELECT 'Total Number of Products', COUNT(product_id) 
FROM [gold.dim_products]
UNION ALL
SELECT 'Total Number of Customers', COUNT(customer_key) 
FROM [gold.dim_customers];


-- ===============================
-- 📊 MAGNITUDE ANALYSIS
-- ===============================

-- Customers by country
SELECT country, COUNT(customer_id) AS total_customers 
FROM [gold.dim_customers]
GROUP BY country 
ORDER BY total_customers DESC;

-- Customers by gender
SELECT gender, COUNT(customer_id) AS total_customers 
FROM [gold.dim_customers]
GROUP BY gender 
ORDER BY total_customers DESC;

-- Products by category
SELECT category, COUNT(product_id) AS total_products 
FROM [gold.dim_products]
GROUP BY category 
ORDER BY total_products DESC;

-- Average cost by category
SELECT category, AVG(cost) AS avg_cost 
FROM [gold.dim_products]
GROUP BY category 
ORDER BY avg_cost DESC;

-- Total revenue by category
SELECT 
    p.category,
    SUM(f.sales_amount) AS total_revenue
FROM [gold.fact_sales] f 
LEFT JOIN [gold.dim_products] p ON f.product_key = p.product_key
GROUP BY p.category 
ORDER BY total_revenue DESC;

-- Revenue by customer
SELECT 
    customer_id, 
    first_name, 
    last_name, 
    SUM(sales_amount) AS total_revenue
FROM [gold.fact_sales] f 
LEFT JOIN [gold.dim_customers] c ON f.customer_key = c.customer_key
GROUP BY customer_id, first_name, last_name
ORDER BY total_revenue DESC;

-- Distribution of sold items across countries
SELECT 
    c.country,
    COUNT(f.quantity) AS total_sold
FROM [gold.fact_sales] f 
LEFT JOIN [gold.dim_customers] c ON f.customer_key = c.customer_key
GROUP BY c.country
ORDER BY total_sold DESC;


-- ===============================
-- 🏆 RANKING ANALYSIS
-- ===============================

-- Top 5 products by revenue
SELECT TOP 5
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM [gold.fact_sales] f 
LEFT JOIN [gold.dim_products] p ON f.product_key = p.product_key
GROUP BY p.product_name 
ORDER BY total_revenue DESC;

-- Bottom 5 products by revenue
SELECT TOP 5
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM [gold.fact_sales] f 
LEFT JOIN [gold.dim_products] p ON f.product_key = p.product_key
GROUP BY p.product_name 
ORDER BY total_revenue ASC;

-- Top 10 customers by revenue
SELECT TOP 10
    customer_id,
    first_name,
    last_name,
    SUM(sales_amount) AS total_revenue
FROM [gold.fact_sales] f 
LEFT JOIN [gold.dim_customers] c ON f.customer_key = c.customer_key
GROUP BY customer_id, first_name, last_name
ORDER BY total_revenue DESC;

-- 3 customers with fewest orders
SELECT TOP 3
    c.customer_key,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT order_number) AS order_count_per_customer
FROM [gold.fact_sales] s 
LEFT JOIN [gold.dim_customers] c ON c.customer_key = s.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY order_count_per_customer ASC;
