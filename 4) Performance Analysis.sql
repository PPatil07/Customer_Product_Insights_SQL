/* 
===============================================================================
PRODUCT PERFORMANCE ANALYSIS (YEARLY)
===============================================================================
Purpose : 
    - Analyzes annual product sales performance in two ways:
        1. Against product’s average historical sales
        2. Against previous year's sales (YoY change)

Highlights :
    1. Calculates yearly sales for each product
    2. Flags if current year sales are above or below average
    3. Computes YoY sales change and classifies trend as Increase/Decrease

===================================================================================
*/

WITH yearly_product_sales AS (
    /*---------------------------------------------------------------
      Step 1: Aggregate product-level sales by year
    ----------------------------------------------------------------*/
    SELECT
        YEAR(order_date) AS order_year,
        product_name,
        SUM(sales_amount) AS current_sales
    FROM 
        [gold.fact_sales] s
    LEFT JOIN 
        [gold.dim_products] p ON s.product_key = p.product_key
    WHERE 
        YEAR(order_date) IS NOT NULL
    GROUP BY 
        YEAR(order_date), product_name
)

SELECT 
    order_year,                                                           -- Year of the sale
    product_name,                                                         -- Product name
    current_sales,                                                        -- Sales in that year

    -- Average sales of this product across all years
    AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales_year,

    -- Difference from average sales
    current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,

    -- Flag based on average comparison
    CASE 
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Average'
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Average'
        ELSE 'Average'
    END AS avg_change_flag,

    -- Previous year's sales for this product
    LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS prev_year_sales,

    -- Difference from previous year
    current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py_sales,

    -- Flag based on YoY change
    CASE 
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
        ELSE 'No Change'
    END AS py_change_flag

FROM 
    yearly_product_sales
ORDER BY 
    product_name, order_year;
