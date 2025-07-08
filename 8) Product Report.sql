/* 
===============================================================================
PRODUCT REPORT
===============================================================================
Purpose : 
     - This report consolidates key product-level metrics and performance insights

Highlights : 
     1. Extracts core fields such as product identifiers, names, and sales data
     2. Segments products into performance-based categories (High, Mid, Low)
     3. Aggregates product-level metrics: 
        - total orders 
        - total sales 
        - total quantity sold 
        - count of unique customers 
        - lifespan (in months) 
     4. Calculates valuable KPIs:
        - recency (months since last order)
        - average order revenue
        - average monthly revenue

===================================================================================
===================================================================================*/

CREATE VIEW Product_Report AS
WITH base_query AS (
    /*------------------------------------------------
      1) Base Query : Retrieves core columns from tables
    --------------------------------------------------*/ 
    SELECT 
        f.order_number,
        f.product_key,
        f.order_date,
        f.sales_amount,
        f.quantity,
        f.customer_key,
        p.product_id,
        p.product_name,
        p.category,
        p.subcategory
    FROM 
        [gold.fact_sales] f
    LEFT JOIN 
        [gold.dim_products] p ON f.product_key = p.product_key
    WHERE 
        order_date IS NOT NULL
), 

product_segmentation AS ( 
    /*-------------------------------------------------------
      2) Aggregate Product-level Metrics
    --------------------------------------------------------*/
    SELECT 
        product_id,
        product_key,
        product_name,
        COUNT(order_number) AS total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT customer_key) AS count_of_customers,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
        MAX(order_date) AS last_ordered
    FROM 
        base_query
    GROUP BY 
        product_id,
        product_key,
        product_name
)

/*-------------------------------------------------------
  3) Final Query : Combines product KPIs and segments
--------------------------------------------------------*/
SELECT 
    product_id,
    product_key,
    product_name,
    total_orders,
    total_sales,
    total_quantity,
    count_of_customers,
    lifespan,

    -- Revenue Class based on total sales
    CASE 
        WHEN total_sales <= 457818 THEN 'Low_Performers'
        WHEN total_sales <= 915636 THEN 'Mid-Range'
        ELSE 'High-Performers'
    END AS revenue_class,

    -- Recency in months
    DATEDIFF(MONTH, last_ordered, GETDATE()) AS recency,

    -- Average Order Revenue
    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_revenue,

    -- Average Monthly Revenue
    CASE 
        WHEN lifespan = 0 THEN 0
        ELSE total_sales / lifespan
    END AS avg_monthly_revenue

FROM 
    product_segmentation;

-- Preview the report
SELECT * FROM Product_Report;
