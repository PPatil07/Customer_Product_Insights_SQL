--explore all objects in the database 
select * from INFORMATION_SCHEMA.TABLES;

--explore all columns in the database  

select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME='gold.dim_customers';

--explore all countries our customers come from 

select distinct country from [gold.dim_customers] 

--explore all categories 'The Major Division' 

select category,subcategory,product_name from [gold.dim_products]  order by 1,2,3 

--find the date of first and last order
--how many years of sales are available

   select min(order_date) as first_order ,
   max(order_date) as last_order,
   DATEDIFF(year,min(order_date),max(order_date)) as order_range_years
   from [gold.fact_sales] 

--find the youngest and oldest customer 

select datediff(year,min(birthdate),getdate()) as oldest_customer ,
       datediff(year,max(birthdate),getdate()) as youngest_customer 
from [gold.dim_customers] 

--find the total sales 

select sum(sales_amount) as total_sales from [gold.fact_sales] 

--find how many items are sold 

select sum(quantity) as items_sold from [gold.fact_sales]

--find the total number of orders 

select count(distinct order_number) as total_orders from [gold.fact_sales] 

--find the total number of products 
select count(product_id) as total_products from [gold.dim_products]

--find the total number of customers 

select count(customer_id) as total_customers from [gold.dim_customers] 

--find the total number of customers that has placed an order 

select count( distinct customer_key) from [gold.fact_sales]

--generate a report that shows all key metrics of business 

select 'Total Sales' as measure_name ,sum(sales_amount) as measure_value from [gold.fact_sales] 
union all 
select 'Total Quanity' ,sum(quantity) from [gold.fact_sales]
union all 
select 'Average Price', avg(price) from [gold.fact_sales] 
union all 
select 'total number of orders' ,count(distinct order_number) from [gold.fact_sales]
union all 
select 'total no of products',count(product_id) from [gold.dim_products]
union all 
select 'total no of customers' ,count(customer_key) from [gold.dim_customers] 


--MAGNITUDE ANALYSIS 

--find the total number of customers by countries 

select country,count(customer_id) as total_customers 
from [gold.dim_customers] 
group by country 
order by total_customers desc 

--find total customers by gender 

select gender,count(customer_id) as total_customers 
from [gold.dim_customers] 
group by gender
order by total_customers desc 

--find total products by category 

select category,count(product_id) as total_products 
from [gold.dim_products] 
group by category 
order by total_products desc 

--what is the average cost in each category 

select category,avg(cost) as avg_cost 
from [gold.dim_products]
group by category 
order by avg_cost desc 

--what is the total revenue generated for each category 

select p.category,
sum(f.sales_amount) as total_revenue
from [gold.fact_sales] f left join [gold.dim_products] p 
on  f.product_key=p.product_key
group by p.category 
order by total_revenue desc

--what is the total revenue generated for each customer

select customer_id,first_name,last_name,sum(sales_amount) as total_revenue
from [gold.fact_sales] f left join [gold.dim_customers] c 
on f.customer_key=c.customer_key
group by customer_id,first_name,last_name
order by total_revenue desc  

--what is the distribution of sold items across countries 

select c.country ,
count(f.quantity) total_sold
from [gold.fact_sales] f left join [gold.dim_customers] c 
on f.customer_key=c.customer_key
group by c.country
order by total_sold desc


--RANKING ANALYSIS 

--which 5 products generate the highest revenue 

select TOP 5
p.product_name,
sum(f.sales_amount) as total_revenue
from [gold.fact_sales] f left join [gold.dim_products] p 
on  f.product_key=p.product_key
group by p.product_name 
order by total_revenue desc 


--which are the 5 worst performing products in terms of sales?
select TOP 5
p.product_name,
sum(f.sales_amount) as total_revenue
from [gold.fact_sales] f left join [gold.dim_products] p 
on  f.product_key=p.product_key
group by p.product_name 
order by total_revenue asc


--find the top 10 customers who have generated highest revenue 

select top 10 
 customer_id,first_name,last_name,sum(sales_amount) as total_revenue
from [gold.fact_sales] f left join [gold.dim_customers] c 
on f.customer_key=c.customer_key
group by customer_id,first_name,last_name
order by total_revenue desc  

--the 3 customers with the fewest orders placed 

select top 3 
c.customer_key,
c.first_name,
c.last_name,
count(distinct order_number) as order_count_per_customer 
from [gold.fact_sales] s left join [gold.dim_customers] c 
on c.customer_key=s.customer_key
group by c.customer_key,c.first_name,c.last_name
order by order_count_per_customer