/* 
===============================================================================
PART-TO-WHOLE ANALYSIS: CATEGORY-WISE SALES CONTRIBUTION
===============================================================================
Purpose : 
    - Identifies how much each product category contributes to overall sales

Highlights :
    1. Aggregates total sales per category
    2. Calculates each category's % contribution to the grand total
    3. Useful for Pareto analysis and identifying dominant segments

===================================================================================
*/

-- Preview raw tables (optional checks)
SELECT * FROM [gold.dim_products];
SELECT * FROM [gold.fact_sales];

-- Step 1: Aggregate sales by product category
WITH category_sales AS (
    SELECT 
        p.category,
        SUM(s.sales_amount) AS categorywise_sales
    FROM 
        [gold.fact_sales] s
    LEFT JOIN 
        [gold.dim_products] p ON s.product_key = p.product_key
    GROUP BY 
        p.category
)

-- Step 2: Calculate total sales contribution of each category
SELECT 
    category,
    CONCAT(
        ROUND(
            (CAST(categorywise_sales AS FLOAT) / 
             SUM(categorywise_sales) OVER()) * 100, 2
        ), 
        '%'
    ) AS total_sales_contribution
FROM 
    category_sales;
