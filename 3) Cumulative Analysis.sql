/* 
===============================================================================
CUMULATIVE SALES ANALYSIS
===============================================================================
Purpose : 
    - Tracks monthly total sales and cumulative (running) sales over time

Highlights :
    1. Aggregates sales at the month level
    2. Computes running total of sales to observe progressive growth
    3. Useful for trend monitoring, forecasting, and performance tracking

===================================================================================
*/

SELECT 
    order_date,                                                                 -- Month of the order
    total_sales,                                                                -- Total sales in that month
    SUM(total_sales) OVER (ORDER BY order_date) AS running_total               -- Cumulative sales up to that month
FROM (
    SELECT 
        DATETRUNC(MONTH, order_date) AS order_date,                             -- Truncating to month level
        SUM(sales_amount) AS total_sales                                        -- Monthly aggregated sales
    FROM 
        [gold.fact_sales]
    WHERE 
        DATETRUNC(MONTH, order_date) IS NOT NULL
    GROUP BY 
        DATETRUNC(MONTH, order_date)
) t;

