/* 
===============================================================================
PRODUCT COST SEGMENTATION ANALYSIS
===============================================================================
Purpose : 
    - Segments products into defined cost brackets
    - Counts how many products fall into each price range

Highlights :
    1. Uses CASE logic to define product cost bands
    2. Aggregates product counts per cost range
    3. Supports inventory analysis, pricing strategy, and market targeting

===================================================================================
*/

-- Optional: Preview data and inspect cost distribution
SELECT * FROM [gold.dim_products];
SELECT MAX(cost), MIN(cost) FROM [gold.dim_products];

-- Step 1: Assign each product to a cost segment
WITH product_cost_range AS (
    SELECT 
        product_id,
        cost,
        CASE 
            WHEN cost BETWEEN 0 AND 100 THEN '0-100'
            WHEN cost BETWEEN 101 AND 500 THEN '101-500'
            WHEN cost BETWEEN 501 AND 1000 THEN '501-1000'
            WHEN cost BETWEEN 1001 AND 1500 THEN '1001-1500'
            WHEN cost BETWEEN 1501 AND 2000 THEN '1501-2000'
            ELSE '2000+'
        END AS cost_range
    FROM 
        [gold.dim_products]
)

-- Step 2: Count products in each cost segment
SELECT 
    cost_range,
    COUNT(*) AS product_count
FROM 
    product_cost_range
GROUP BY 
    cost_range
ORDER BY 
    product_count DESC;


-- Group customers into 3 groups based on their spending behavior
-- VIP     - At least 12 months of history and spending more than 5000
-- Regular - At least 12 months of history but spending 5000 or less
-- New     - Lifespan less than 12 months
-- Also, find the total number of customers in each group

WITH customer_data AS (
    SELECT 
        c.customer_id AS customer_id,
        s.customer_key AS customer_key,
        SUM(s.sales_amount) AS total_spent,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS months_active
    FROM 
        [gold.fact_sales] s
    LEFT JOIN 
        [gold.dim_customers] c ON s.customer_key = c.customer_key
    WHERE 
        order_date IS NOT NULL
    GROUP BY 
        s.customer_key, c.customer_id
),

customer_flag AS (
    SELECT  
        customer_id,
        CASE 
            WHEN months_active >= 12 AND total_spent > 5000 THEN 'VIP'
            WHEN months_active >= 12 AND total_spent <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS flag
    FROM 
        customer_data
)

SELECT 
    flag,
    COUNT(customer_id) AS total_customers
FROM 
    customer_flag
GROUP BY 
    flag;
