create database mini;
use mini;

-- SQL II - Mini Project _________________________________________________________

# Composite data of a business organisation, confined to ‘sales and delivery’ domain is given for the period of last decade. 
# From the given data retrieve solutions for the given scenario.
-- 1. Join all the tables and create a new table called combined_table. (market_fact, cust_dimen, orders_dimen, prod_dimen, shipping_dimen)
create view combined_table as 

(select cd.cust_id,cd.customer_name,od.ord_id,pd.prod_id,sd.ship_id,mf.sales,mf.discount,mf.order_quantity,
mf.profit,mf.shipping_cost,mf.product_base_margin,cd.province,cd.region,cd.customer_segment,od.order_id,od.order_date,od.order_priority,
pd.product_category,pd.product_sub_category,
sd.ship_mode,sd.ship_date
from market_fact mf inner join cust_dimen cd
on mf.cust_id = cd.cust_id
inner join orders_dimen od
on mf.ord_id = od.ord_id
inner join prod_dimen pd
on mf.prod_id = pd.prod_id
inner join shipping_dimen sd
on mf.ship_id = sd.ship_id);

select * from combined_table;

-- 2. Find the top 3 customers who have the maximum number of orders
select cust_id,customer_name,count(ord_id)Total
from combined_table
group by cust_id,customer_name
order by Total desc
limit 3;
-- 3. Create a new column Days Taken For Delivery that contains the date difference of Order_Date and Ship_Date.
select customer_name,order_date,ship_date,datediff(str_to_date(ship_date,'%d-%m-%Y'),str_to_date(order_date,'%d-%m-%Y')) 'Days taken for Delivery'
from combined_table;

create or replace view combined_table as(
SELECT mf.ord_id,mf.prod_id,mf.ship_id,mf.cust_id,mf.sales,mf.discount,mf.order_quantity,mf.profit,mf.shipping_cost,
mf.product_base_margin,cd.customer_name,
cd.province,cd.region,cd.customer_segment,od.order_id,od.order_date,od.order_priority,pd.product_category,pd.product_sub_category,
sd.ship_mode,sd.ship_date,datediff(str_to_date(ship_date,'%d-%m-%Y'),str_to_date(order_date,'%d-%m-%Y')) DaysTakenForDelivery
FROM market_fact mf 
inner join cust_dimen cd on mf.cust_id=cd.cust_id inner join orders_dimen od on od.ord_id=mf.ord_id inner join prod_dimen pd
on pd.prod_id=mf.prod_id inner join shipping_dimen sd on  sd.ship_id=mf.ship_id);

select order_date,ship_date,datediff(str_to_date(ship_date,'%d-%m-%Y'),str_to_date(order_date,'%d-%m-%Y')) from combined_table;
-- 4. Find the customer whose order took the maximum time to get delivered.
select customer_name,DaysTakenForDelivery 
from combined_table 
where DaysTakenForDelivery=(select max(DaysTakenForDelivery) from combined_table);

-- 5. Retrieve total sales made by each product from the data (use Windows function)
select distinct Prod_id,round(sum(sales) over (partition by Prod_id 
order by Prod_id)) as prod_tot_sales 
from combined_table;

-- 6. Retrieve total profit made from each product from the data (use windows function)
select distinct Prod_id,round(sum(Profit) over(partition by  Prod_id),2) as tot_profit 
from combined_table;

-- 7. Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011
create or replace view tea_vw as 
(select distinct cust_id from combined_table where year(str_to_date(order_date,'%d-%m-%Y'))<2011);


create or replace view tea as(
select distinct cust_id from combined_table where cust_id not in (select cust_id from tem_vw) and month(str_to_date(order_date,'%d-%m-%Y'))=1
and year(str_to_date(order_date,'%d-%m-%Y'))=2011);

# count unique customers in january

select count(distinct cust_id) from tea;

select count(distinct cust_id) as unique_customers from combined_table where MONTH(Order_Date) = 1 AND YEAR(Order_Date) = 2011;

#how many of them came back every month in 2011

select count(cust_id) from combined_table where cust_id in (select cust_id from tea) 
and year(str_to_date(order_date,'%d-%m-%Y'))=2011
group by cust_id having count(distinct month(str_to_date(order_date,'%d-%m-%Y')))=12;
-- 8. Retrieve month-by-month customer retention rate since the start of the business.(using views)

# Tips:
#1: Create a view where each user’s visits are logged by month, allowing for the possibility that these will have occurred over multiple # years since whenever business started operations
# 2: Identify the time lapse between each visit. So, for each person and for each month, we see when the next visit is.
# 3: Calculate the time gaps between visits
# 4: categorise the customer with time gap 1 as retained, >1 as irregular and NULL as churned
# 5: calculate the retention month wise

create or replace view retn as(
select cust_id,month(str_to_date(order_date,'%d-%m-%Y')) as month,
ifnull(
case 
when TIMESTAMPDIFF(month,str_to_date(order_date,'%d-%m-%Y'),lead(str_to_date(order_date,'%d-%m-%Y')) 
over(partition by cust_id))=1 then 'Retained'
when TIMESTAMPDIFF(month,str_to_date(order_date,'%d-%m-%Y'),lead(str_to_date(order_date,'%d-%m-%Y')) 
over(partition by cust_id))>1 then 'irregular'
when TIMESTAMPDIFF(month,str_to_date(order_date,'%d-%m-%Y'),lead(str_to_date(order_date,'%d-%m-%Y')) 
over(partition by cust_id)) is null then 'churned'

end ,'churned')
as retention_category
from combined_table group by order_date order by month);
 
 select month,count(*) as retention_rate from retn where retention_category='churned' group by month;
