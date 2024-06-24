# Fassos Data Analysis Project

## Overview

This project analyzes the operational data of Fassos, a food delivery service, to gain insights into customer preferences, driver efficiency, order patterns, and ingredient optimization.

 NOTE - Click this Link to read The Comment For Each Query    
 https://github.com/shreedhar13/Fassos_Data_Cleaning_And_Analysis_Using_SQL_Queries/blob/main/SQL_Script_For_Data_Cleaning_and_analysis.sql

## Goals of Data Analysis

1. Understand customer preferences regarding ingredients in their orders.
2. Evaluate driver efficiency and identify areas for improvement.
3. Analyze order patterns to optimize delivery schedules and staffing.
4. Optimize ingredient usage to reduce waste and operational costs.

## Insights Drawn from the Project

1. **Customer Behavior Insights:**
   - Majority of customers prefer to either include extras or exclude certain ingredients in their rolls rather than opting for the default options.
   - There's a significant number of repeat customers who have consistently made changes to their orders in the past.

2. **Driver Efficiency Insights:**
   - Drivers have varying average times to pick up orders from the headquarters, indicating potential areas for training or operational improvements.
   - Analyzing successful order delivery percentages helps identify top-performing drivers and those who may need additional support or training.

3. **Order Patterns and Preferences:**
   - Peak ordering hours are observed in the evening, suggesting a higher demand during dinner hours. This insight can guide staffing and resource allocation.
   - Orders with both exclusions and extras are relatively common, highlighting the importance of flexibility in menu offerings.

4. **Ingredient Optimization:**
   - Understanding which ingredients are most frequently included or excluded allows for better inventory management and menu planning.
   - By optimizing ingredient usage, Fassos can potentially reduce waste and operational costs.

5. **Operational Efficiency Gains:**
   - Insights into delivery times and distances traveled help optimize delivery routes and improve overall efficiency.
   - Identifying trends such as delivery speed and duration provides actionable insights for enhancing service levels and customer satisfaction.

6. **Goals Achieved:**
   - Improved customer experience through personalized orders and efficient service.
   - Enhanced driver performance and operational efficiency through data-driven decision-making.
   - Better resource utilization and cost savings through optimized ingredient usage and delivery logistics.

7. **Future Directions:**
   - Implement real-time analytics to monitor and adjust operations dynamically.
   - Explore predictive analytics to anticipate customer preferences and optimize inventory management further.
   - Expand analysis to include customer feedback data for a more comprehensive view of service quality and customer satisfaction.
  
## Queries and Outputs

### Data Cleaning Part
# A) Customer_orders
```sql
-- Update customer_orders: Set 'not_include_items' to '0' where it's null or empty
UPDATE customer_orders
SET not_include_items = '0'
WHERE not_include_items IS NULL OR not_include_items = '';

-- Update customer_orders: Set 'extra_items_included' to '0' where it's null, 'NaN', or empty
UPDATE customer_orders
SET extra_items_included = '0'
WHERE extra_items_included IS NULL OR extra_items_included = 'NaN' OR extra_items_included = '';
```

# A) driver_order
```sql
UPDATE driver_order
SET distance = 0 
WHERE distance IS NULL;

UPDATE driver_order
SET duration = 0
WHERE duration IS NULL;

UPDATE driver_order
SET cancellation = 0
WHERE cancellation = '' OR cancellation = 'NaN' OR cancellation IS NULL;

UPDATE driver_order
SET cancellation = 1
WHERE cancellation IN ('Cancellation', 'Customer Cancellation');

-- Clean 'distance' in driver_order: Remove 'km' and trim spaces
UPDATE driver_order
SET distance = TRIM(REPLACE(distance, 'km', ''))
WHERE distance LIKE '%km%';

-- Clean 'duration' in driver_order: Extract numeric value for duration in minutes
UPDATE driver_order
SET duration = TRIM(LEFT(duration, POSITION('m' IN duration) - 1))
WHERE duration LIKE '%min%';
```


### Query 1: How many rolls were ordered?

```sql
select count(*) from customer_orders;  
```
```sh
// insert image for output table
```

### Query 2: Total orders for each roll?

```sql
SELECT rolls.roll_name, COUNT(customer_orders.order_id) AS total_orders
FROM customer_orders
JOIN rolls ON customer_orders.roll_id = rolls.roll_id
GROUP BY rolls.roll_name;
```
// insert image for output table

### Query 3: Total orders for each roll with breakdown by date?

```sql
            SELECT rolls.roll_name, DATE(customer_orders.order_date) AS order_date, COUNT(customer_orders.order_id) AS total_orders
            FROM customer_orders
            JOIN rolls ON customer_orders.roll_id = rolls.roll_id
            GROUP BY rolls.roll_name, DATE(customer_orders.order_date)
            ORDER BY order_date;
```
// insert image for output table

### Query 4: How many Unique customer orders were made ?

```sql
select count(*) from (select distinct customer_id from customer_orders) as t;
```
// insert image for output table

### Query 5: How many successful orders were delivered by each driver?

```sql
            with cte as (
                        select driver_id ,
                                            case
                                                when cancellation like 'C%' then 0
                                                else 1
                                                end as successful_orders
                        from driver_order
                        )
            select SUM(successful_order_per_driver) as total_successful_order
            from (select driver_id , SUM(successful_orders) as successful_order_per_driver
                from cte
                group by driver_id) temp;
```
// insert image for output table

### Query 6: how many,each type of roll is delivered?

```sql
            select roll_id , count(*) as successfully_delivered_order_per_roll_type 
            from customer_orders 
            where order_id IN  (

                                select order_id from ( select * , case
                                                                when cancellation in ('Cancellation', 'Customer Cancellation') then 'c' 
                                                                else 'nc'
                                                                end as order_cancel_details
                                                from driver_order
                                            ) temp
                                where order_cancel_details = 'nc'
                
                                )
            group by roll_id;
```
// insert image for output table

### Query 7: Hom many veg and no-veg rolls are ordered by each customer?

```sql
            select customer_id , sum(veg_roll) as veg_roll , sum(Non_veg_roll) as non_veg_roll
            from
                (
                select customer_id , roll_id , if(roll_id = 1 , count(roll_id) , 0) as veg_roll , if(roll_id = 2 , count(roll_id) , 0) as Non_veg_roll
                from customer_orders 
                group by customer_id , roll_id
                ) temp
            group by customer_id;

             -- OR --

            select t1.* , t2.roll_name
            from
                (
                select customer_id , roll_id , count(roll_id) count
                from customer_orders
                group by customer_id , roll_id 
                ) t1
                inner join    rolls t2    on  t1.roll_id = t2.roll_id;
```
// insert image for output table

### Query 8: all successfully delivered orders?

```sql
select * from driver_order where cancellation in ('','NaN') or cancellation is null
```
// insert image for output table

### Query 9: cancelled orders

```sql
 select * from driver_order where cancellation not in ('','NaN') 
```
// insert image for output table

### Query 10:  max_no_of_orders_made_by_each_user_and_those_are_delivered_successfully

```sql
            select customer_id,count(*) max_no_of_orders_made_by_each_user_and_those_are_delivered_successfully 
            from customer_orders natural join driver_order
            where cancellation is null or cancellation not like '%C%'
            group by customer_id
            order by max_no_of_orders_made_by_each_user_and_those_are_delivered_successfully DESC;
```
// insert image for output table

### Query 10: max no of rolls which are delivered in single order..(ie;on sme order_id how many rolls are ordered)

```sql
            select order_id , count(*) rolls_delivered_successfully_per_order_id
            from customer_orders natural join driver_order
            where cancellation is null or cancellation not like '%C%'
            group by order_id

            -- OR --
                --or applying rank on rolls_delivered_successfully_per_order_id
            select * , rank() over(order by rolls_delivered_successfully_per_order_id desc) rnk
            from 
            (
            select order_id , count(*) rolls_delivered_successfully_per_order_id
            from customer_orders natural join driver_order
            where cancellation is null or cancellation not like '%C%'
            group by order_id
            ) temp1;
```
// insert image for output table

### Query 11: highest order made id

```sql
            select * 
            from
                (
                select * , rank() over(order by rolls_delivered_successfully_per_order_id desc) rnk
                from 
                    (
                    select order_id , count(*) rolls_delivered_successfully_per_order_id
                    from customer_orders natural join driver_order
                    where cancellation is null or cancellation not like '%C%'
                    group by order_id
                    ) temp1
            ) temp2
            where rnk =1 ;
```
// insert image for output table

### Query 12:  for each customer , how many delivered rolls had at least 1 change and how many had no changes?

```sql

            with temp_customer_orders (order_id,customer_id , roll_id , not_include_items , extra_items_included , order_date) as
                    (
                        select order_id , customer_id , roll_id ,
                                                                    case 
                                                                    when not_include_items is null or not_include_items = '' then '0'
                                                                    else not_include_items
                                                                    end as new_not_include_items ,
                                                                    case
                                                                    when extra_items_included = 'NaN' or extra_items_included = '' or extra_items_included is null then '0'
                                                                    else extra_items_included
                                                                    end as new_extra_items_included , order_date from customer_orders
                    )
                ,  temp_driver_order ( order_id , driver_id , pickup_time , distance , duration , new_cancellation) as
                    (
                        select order_id , driver_id , pickup_time , distance , duration , case 
                                                                                            when cancellation in ('cancellation','Customer Cancellation') then 1
                                                                                            when cancellation is null or cancellation ='NaN' or cancellation = '' then 0
                                                                                            else cancellation
                                                                                        end as new_cancellation from driver_order
                    )
            
            select * , case when recipe = 'Change' then 1 else 0 end as atleas_1_change_add_or_remove_ingradient , case when recipe ='No-Change' then 1 else 0 end as no_changes
            from
            (
                SELECT * , case when not_include_items = '0' and extra_items_included = '0' then 'No-Change' else 'Change' end as recipe
                FROM  temp_driver_order t1 natural join temp_customer_orders t2
                where new_cancellation = 0
            ) alias_for_derived_table_it_is_must ;
```
// insert image for output table

### Query 13: total changes made by each user out of all orders thaey made in past ?

```sql

            with temp_customer_orders (order_id,customer_id , roll_id , not_include_items , extra_items_included , order_date) as
                    (
                        select order_id , customer_id , roll_id ,
                                                                    case 
                                                                    when not_include_items is null or not_include_items = '' then '0'
                                                                    else not_include_items
                                                                    end as new_not_include_items ,
                                                                    case
                                                                    when extra_items_included = 'NaN' or extra_items_included = '' or extra_items_included is null then '0'
                                                                    else extra_items_included
                                                                    end as new_extra_items_included , order_date from customer_orders
                    )
                ,  temp_driver_order ( order_id , driver_id , pickup_time , distance , duration , new_cancellation) as
                    (
                        select order_id , driver_id , pickup_time , distance , duration , case 
                                                                                            when cancellation in ('cancellation','Customer Cancellation') then 1
                                                                                            when cancellation is null or cancellation ='NaN' or cancellation = '' then 0
                                                                                            else cancellation
                                                                                        end as new_cancellation from driver_order
                    )
            
            
            select customer_id , SUM(atleast_1_change_add_or_remove_ingradient) as total_changes_done_in_past  , sum(no_changes) total_no_changes_in_Past , count(*) as total_orders_in_past
            from
                (
                        select * , case when recipe = 'Change' then 1 else 0 end as atleast_1_change_add_or_remove_ingradient , case when recipe ='No-Change' then 1 else 0 end as no_changes
                        from
                                    (
                                        SELECT * , case when not_include_items = '0' and extra_items_included = '0' then 'No-Change' else 'Change' end as recipe
                                        FROM  temp_driver_order t1 natural join temp_customer_orders t2
                                        where new_cancellation = 0
                                    ) alias_for_derived_table_it_is_must
                ) temp2
            group by customer_id ;
```
// insert image for output table

### Query 14: How many rolls were delivered that had both exclusion and extras?

```sql

                select * 
                from
                (
                select count(*) excluded_and_included_atleast_one_ingradient
                from driver_order natural join customer_orders
                where cancellation <> 1 and  not_include_items <> 0 and extra_items_included <> 0 
                ) t1
                join
                (       select count(*) either_excluded_or_included_atleast_one_ingradient
                        from
                        (
                            (select *
                            from driver_order natural inner join customer_orders
                            where cancellation <> 1 )
                            except 
                            (select *
                            from driver_order natural join customer_orders
                            where cancellation <> 1 and  not_include_items <> 0 and extra_items_included <> 0 )
                        ) t
                ) t2 ;

                -- OR --

                select modification as modification_in_roll , count(*) as count
                from
                (
                    select * , case when not_include_items = 0 and extra_items_included = 0 then 'as_it_is_want'
                                    when not_include_items = 0 and extra_items_included <> 0 then 'Included_extras'
                                    when not_include_items <> 0 and extra_items_included = 0 then 'excluded'
                                    else 'included_and_excluded'
                                    end as modification
                    from driver_order natural join customer_orders
                    where cancellation <> 1
                ) t
                group by modification;
```
// insert image for output table

### Query 15: what was the total no of rolls ordered for each hour of the day?

```sql
            -- { See   (https://dev.mysql.com/doc/refman/8.4/en/date-and-time-functions.html#function_hour),,,to see date time function present in mysql }

                select hour_range_for_order as hour_range_for_order  , count(*) as total_no_of_order_made_in_this_hour_range
                from
                (
                    select * , concat(   hour(order_date) ,'-', hour(order_date)+1  ) as hour_range_for_order
                    from customer_orders
                ) t
                group by hour_range_for_order
```
// insert image for output table

### Query 16: what was the no of orders "in_total", for each day of the week ...?

```sql
                select DAY_name , count(*) count
                from
                (
                    select * , dayname(order_date) as DAY_name
                    from customer_orders
                ) every_derived_table_must_have_alias_name_otherwise_error_will_thrown
                group by DAY_name  ;

                -- OR

                select DAY_name , hour_range_for_order , count(order_id) count
                from
                (
                    select * , dayname(order_date) as DAY_name , concat(   hour(order_date) ,'-', hour(order_date)+1  ) as hour_range_for_order
                    from customer_orders
                ) every_derived_table_must_have_alias_name_otherwise_error_will_thrown
                group by DAY_name , hour_range_for_order ;
```
// insert image for output table

### Query 17: what was the avg time in minutes it took for each  driver  to arrive  at the fassos HQ(head quarter) to pickup the order?	

```sql
                select *
                from
                (select driver_id , count(*) as Total_orrders_delivered_Successfully_in_past
                from driver_order natural join  customer_orders
                where pickup_time is not null
                group by driver_id
                ) sample1

                natural join

                (
                select driver_id , concat(average_time_gap_from_order_to_pickup_the_parcel_in_minutes , '  Minute')  average_time_gap_from_order_to_pickup_the_parcel_by_an_driver_in_minutes
                from
                (
                select driver_id , ceil (avg(time_gap_between_order_and_pickup_time) ) as average_time_gap_from_order_to_pickup_the_parcel_in_minutes 
                from
                (
                select * , abs(minute_part_of_pickup - minute_of_order) as time_gap_between_order_and_pickup_time
                from
                (
                    select *, minute(pickup_time) as minute_part_of_pickup , minute(order_date) as minute_of_order 
                    from driver_order natural join customer_orders
                    where pickup_time is not null
                ) temp
                ) temp2
                group by driver_id
                )temp3
                )sample2 ;

```
// insert image for output table

### Query 18: is there any relation ship between no of rolls and how long the order takes to prepare ?

```sql
                select order_id , count(*) as No_of_rolls_ordered_on_this_order_id , truncate(sum(time_gap_between_order_and_pickup_time) / count(*) , 0 )  as         AVG_time_require_to_prepare_this__order_in_minutes
                from
                (
                        select * , abs(minute_part_of_pickup - minute_part_of_order) as time_gap_between_order_and_pickup_time
                        from
                        (
                            select *, minute(pickup_time) as minute_part_of_pickup , minute(order_date) as minute_part_of_order 
                            from driver_order natural join customer_orders
                            where pickup_time is not null
                        ) temp
                ) temp1
                group by order_id ;
```
// insert image for output table

### Query 19: what was the average distance travelled for each customer?

```sql
        -- A)Avg distance travelled by each driver
                select driver_id , avg(decimal_distanec_in_km)
                from
                (
                select * , cast(trim(replace(lower(d1.distance) , 'km' , '')) as decimal(4,2) ) as decimal_distanec_in_km
                from driver_order d1
                where cancellation <> 1
                ) temp
                group by driver_id ;

        -- B)Avg distance Travelled for each customer
                select customer_id , avg(decimal_distanec_in_km)
                from
                (
                select * , cast(trim(replace(lower(d1.distance) , 'km' , '')) as decimal(4,2) ) as decimal_distanec_in_km
                from driver_order d1 natural join customer_orders
                where cancellation <> 1
                ) temp
                group by customer_id ;

```
// insert image for output table

### Query 20:  what was the difference bn longest and shortest delivery times for all orders?

```sql
                select driver_id , max(duration_in_minute) , min(duration_in_minute) ,  max(duration_in_minute) -  min(duration_in_minute)
                from
                (
                    select * , case
                                when duration like '%min%' then cast(trim(left(duration , position('m' in  duration ) - 1 )) as decimal) 
                                else cast(duration as decimal)
                                end as duration_in_minute
                    from driver_order
                    where cancellation <> 1
                ) temp
                group by driver_id ;
```
// insert image for output table

### Query 21: Max duration time taken and minimum duration time taken to deliver order in past

```sql
                select max(duration_in_minute) , min(duration_in_minute)
                from
                (
                    select * , case
                                when duration like '%min%' then cast(trim(left(duration , position('m' in  duration ) - 1 )) as decimal) 
                                else cast(duration as decimal)
                                end as duration_in_minute
                    from driver_order
                    where cancellation <> 1
                ) temp ;
```
// insert image for output table

### Query 22: Order details of Max duration time taken and minimum duration time taken to deliver order in past

```sql
                select *
                from
                (

                    select * , case
                                when duration like '%min%' then cast(trim(left(duration , position('m' in  duration ) - 1 )) as decimal) 
                                else cast(duration as decimal)
                                end as duration_in_minute
                    from driver_order
                    where cancellation <> 1

                ) temp  Natural join customer_orders
                where duration_in_minute in (40 , 10) ;
```
// insert image for output table

### Query 23: what was the avg speed for each driver for each delivery and do you notice any trend for these values?

```sql
                select order_id , decimal_distanec_in_km , duration_in_minute  ,(decimal_distanec_in_km / duration_in_minute ) as speed_require_to_reach_destiny_in_KM_Per_Minute
                from
                (
                    select * , case
                                when duration like '%min%' then cast(trim(left(duration , position('m' in  duration ) - 1 )) as decimal) 
                                else cast(duration as decimal)
                                end as duration_in_minute ,
                            cast(trim(replace(lower(distance) , 'km' , '')) as decimal(4,2) ) as decimal_distanec_in_km
                    from driver_order
                    where cancellation <> 1
                ) temp ;
```
// insert image for output table

### Query 24:  what is successful order delivery percentage for each driver?

```sql
                select * , (successfully_delivered_orders * 100 / total_no_of_orders_got_to_deliver )  as success_rate
                from
                (
                    select driver_id ,  sum(successfully_delivered_orders) as successfully_delivered_orders  , count(*) as total_no_of_orders_got_to_deliver
                    from
                    (
                        select *  , case
                                        when cancellation = 0 then 1
                                        else 0
                                        end as successfully_delivered_orders
                        from driver_order
                    ) temp
                    group by driver_id
                ) temp2 ;

```

### Query 24:  Most used ingredients for each roll:

```sql
                SELECT r.roll_name, i.ingredients_name
                FROM rolls_recipes rr
                JOIN rolls r ON rr.roll_id = r.roll_id
                JOIN ingredients i ON FIND_IN_SET(i.ingredients_id, rr.ingredients)
                ORDER BY r.roll_name, i.ingredients_name;

```
// insert image for output table

## These insights and goals achieved demonstrate the value of data analysis in improving operational performance, customer satisfaction, and overall business outcomes for Fassos.
