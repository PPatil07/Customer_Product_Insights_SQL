/* 
===============================================================================
TIME-BASED SALES TREND ANALYSIS
===============================================================================
Purpose : 
    - Analyzes yearly changes in key performance metrics over time

Highlights : 
    1. Calculates annual total sales, total quantity sold, and unique customers
    2. Helps identify business growth, seasonality, or shifts in customer behavior
===================================================================================
*/

SELECT 
    YEAR(order_date) AS order_year,                         -- Year of the order
    SUM(sales_amount) AS total_sales,                       -- Total sales in that year
    COUNT(DISTINCT customer_key) AS total_customers,        -- Unique customers in that year
    SUM(quantity) AS total_quantity                         -- Total quantity sold in that year
FROM 
    [gold.fact_sales]
WHERE 
    order_date IS NOT NULL
GROUP BY 
    YEAR(order_date)
ORDER BY 
    YEAR(order_date);
