#Faasos is online food serving platform,,like zomato and swiggt,,but this will serve only rolls
#VVVVIIIIMMPPPP
#Note: derived table or subquery must have alias name.....
#Describe table_name ->applicable for only ,,present tavles or predefined table ..not applicabe for derived table,,,(like using with clause fr creating temporary table for current query scope)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#See (https://www.w3schools.com/mysql/mysql_ref_functions.asp),,,all SQL inbuilt functions and clause are present.....alter||
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

create database Faasos_DB;
use Faasos_DB;
show tables;

#1)Creating Driver Table....YYYY-MM-DD,,,in this format mysql will accept dates.reg_date->date on which drivers are onboarded.orFaasos recruited the drivers..from ths date they are starts working to faasos
drop table if exists driver;
CREATE TABLE driver(driver_id integer,reg_date date); 
INSERT INTO driver (driver_id, reg_date) 
VALUES 
    (1, '2021-01-01'),
    (2, '2021-01-03'),
    (3, '2021-01-08'),
    (4, '2021-01-15');


#2)Creating ingredients Table
drop table if exists ingredients;
CREATE TABLE ingredients(ingredients_id integer,ingredients_name varchar(60)); 

INSERT INTO ingredients(ingredients_id ,ingredients_name) 
 VALUES (1,'BBQ Chicken'),
(2,'Chilli Sauce'),
(3,'Chicken'),
(4,'Cheese'),
(5,'Kebab'),
(6,'Mushrooms'),
(7,'Onions'),
(8,'Egg'),
(9,'Peppers'),
(10,'schezwan sauce'),
(11,'Tomatoes'),
(12,'Tomato Sauce');

#3)
drop table if exists rolls;
CREATE TABLE rolls(roll_id integer,roll_name varchar(30)); 

INSERT INTO rolls(roll_id ,roll_name) 
 VALUES (1	,'Non Veg Roll'),
(2	,'Veg Roll');


#4)
drop table if exists rolls_recipes;
CREATE TABLE rolls_recipes(roll_id integer,ingredients varchar(24)); 

INSERT INTO rolls_recipes(roll_id ,ingredients) 
 VALUES (1,'1,2,3,4,5,6,8,10'),
(2,'4,6,7,9,11,12');


#5)
#datetime should be in yyyy-mm-dd format,,bydefault
drop table if exists driver_order;
CREATE TABLE driver_order(order_id integer,driver_id integer,pickup_time datetime,distance VARCHAR(7),duration VARCHAR(10),cancellation VARCHAR(23));
INSERT INTO driver_order(order_id,driver_id,pickup_time,distance,duration,cancellation) 
 VALUES(1,1,'2021-01-01 18:15:34','20km','32 minutes',''),
(2,1,'2021-01-01 19:10:54','20km','27 minutes',''),
(3,1,'2021-01-03 12:37:00','13.4km','20 mins','NaN'),
(4,2,'2021-01-04 13:53:03','23.4','40','NaN'),
(5,3,'2021-01-08 21:10:57','10','15','NaN'),
(6,3,null,null,null,'Cancellation'),
(7,2,'2021-01-08 21:30:45','25km','25mins',null),
(8,2,'2021-01-10 15:02:00','23.4 km','15 minute',null),
(9,2,null,null,null,'Customer Cancellation'),
(10,1,'2021-01-11 18:50:20','10km','10minutes',null);

#6)
drop table if exists customer_orders;
CREATE TABLE customer_orders(order_id integer,customer_id integer,roll_id integer,not_include_items VARCHAR(4),extra_items_included VARCHAR(4),order_date datetime);
INSERT INTO customer_orders(order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date)
values (1,101,1,'','','2021-01-01  18:05:02'),
(2,101,1,'','','2021-01-01 19:00:52'),
(3,102,1,'','','2021-01-02 23:51:23'),
(3,102,2,'','NaN','2021-01-02 23:51:23'),
(4,103,1,'4','','2021-01-04 13:23:46'),
(4,103,1,'4','','2021-01-04 13:23:46'),
(4,103,2,'4','','2021-01-04 13:23:46'),
(5,104,1,null,'1','2021-01-08 21:00:29'),
(6,101,2,null,null,'2021-01-08 21:03:13'),
(7,105,2,null,'1','2021-01-08 21:20:29'),
(8,102,1,null,null,'2021-01-09 23:54:33'),
(9,103,1,'4','1,5','2021-01-10 11:22:59'),
(10,104,1,null,null,'2021-01-11 18:34:49'),
(10,104,1,'2,6','1,4','2021-01-11 18:34:49');

#7)
select * from customer_orders;
select * from driver_order;
select * from ingredients;
select * from driver;
select * from rolls;
select * from rolls_recipes;

#VVVVVVVVVVIIIIIIIIIIIIMMMMMMMMMMMMMMMPPPPPPPPPPPPP
#NOTE- you must give alias_name for derived table,,otherwise mysql gives error like->Every derived table must have its own alias......
#We have to do data cleaning part using sql  part?....

#Part1 ->solving queries related to this
	#A) Roll metrics
	#B)Driver and customer experience
	#C)Ingradient Optimization
	#D)Pricing and Rating

--------------------------------------------------#A)roll metrics---------------------------------------------------------------------------

#1)How many rolls were ordered?
select count(*) as Total_Orderes_Made_Till_Now from customer_orders;  
#ans->14

#2) Total orders for each roll:
SELECT rolls.roll_name, COUNT(customer_orders.order_id) AS total_orders
FROM customer_orders
JOIN rolls ON customer_orders.roll_id = rolls.roll_id
GROUP BY rolls.roll_name;

#3) Total orders for each roll with breakdown by date:
SELECT rolls.roll_name, DATE(customer_orders.order_date) AS order_date, COUNT(customer_orders.order_id) AS total_orders
FROM customer_orders
JOIN rolls ON customer_orders.roll_id = rolls.roll_id
GROUP BY rolls.roll_name, DATE(customer_orders.order_date)
ORDER BY order_date;


#4)How many Unique customer orders were made
select count(*) from (select distinct customer_id from customer_orders) as t;
#or select count(distinctcustomer_id) from customer_orders;
#ans-5 unique customers are there
select * from driver;
select * from driver_order;


#5)How many successful orders were delivered by each driver
#bcz NULL is not comparable,,thus we cant get those row i accounts,,so i used this method
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
#Note- you must give alias_name for derived table,,otherwise mysql gives error like->Every derived table must have its own alias......
            


#4)how many,each type of roll is delivered
select roll_id , count(*) from driver_order d_o, customer_orders c_o where cancellation not like '%C%' and d_o.order_id = c_o.order_id  group by roll_id;
#bcz data is not cleaned and it has many null value ,,and it is not recoganized by sql,,so above code is not give exact result,,bcz it is not considering null value at all
#but below query converting null to 'nc' string,,thus it is recognizing ,,and thus giving accurate result
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




     
#nc -> not cancelled , c-> cancelled


#5)Hom many veg and no-veg rolls are ordered by each customer
#if u use veg_roll as alias name for sum(veg_roll) then sql will give error,,so genrerally we will use different name compare to original name,,thus it will not give syntax error
select customer_id , sum(veg_roll) as veg_roll , sum(Non_veg_roll) as non_veg_roll
from
	(
	select customer_id , roll_id , if(roll_id = 1 , count(roll_id) , 0) as veg_roll , if(roll_id = 2 , count(roll_id) , 0) as Non_veg_roll
	from customer_orders 
	group by customer_id , roll_id
	) temp
group by customer_id;

or


select t1.* , t2.roll_name
from
	(
	select customer_id , roll_id , count(roll_id) count
	from customer_orders
	group by customer_id , roll_id 
	) t1
	inner join    rolls t2    on  t1.roll_id = t2.roll_id;
    
    
#VVVVVVVVVVVIIIIIIIIIIMMMMMMMMMMMMMPPPPPPPPPPPPPPP

select * from driver_order
select * from driver_order where pickup_time is not null
select * from driver_order where pickup_time is  null
select * from driver_order where cancellation = ''
select * from driver_order where cancellation is null
select * from driver_order where cancellation is not null
#VVVIIIMMPP query,,,,,why?  OR logical operator work like C language's operator (||)..ie;if condition of left operand is True then right operand is not evaluated and direct outcome is result of left,,,,,if condition of left operand is failed then only right operand is evaluated
select * from driver_order where cancellation is null or cancellation not like '%C%'
#NOTE-> '' not equal to NULL ..... or we can say  .....   empty string is not equal to NULL
#NaN is not a NULL.......it represents Not a Number(absence of number)

#7) all successfully delivered orders
select * from driver_order where cancellation in ('','NaN') or cancellation is null

#8)cancelled orders
#bcz null is not-comparable with any item like string,no,date...etc
select * from driver_order where cancellation not in ('','NaN') 

#Thats why it is very important to clean the data for analysis and training purpose...otherwise ypu cant analyze data properly...
#You can use python(pandas,nump) to clean data,,ie;delete null containing rows or impute with mean,medain,mode or remove duplicates or make data in same format
#or you can use powerBI to achieve above functionality
#or use SQL update,delete command to clean the data for visualization purpose...

#VVVVVVVVVVVVVVVVVVVVIIIIIIIIIIIIIIIIIIIIIIIIIMMMMMMMMMMMMMMMPPPPPPPPPPPPPP

#6) max_no_of_orders_made_by_each_user_and_those_are_delivered_successfully
select customer_id,count(*) max_no_of_orders_made_by_each_user_and_those_are_delivered_successfully 
from customer_orders natural join driver_order
where cancellation is null or cancellation not like '%C%'
group by customer_id
order by max_no_of_orders_made_by_each_user_and_those_are_delivered_successfully DESC;

#7) max no of rolls which are delivered in single order..(ie;on sme order_id how many rolls are ordered)
select order_id , count(*) rolls_delivered_successfully_per_order_id
from customer_orders natural join driver_order
where cancellation is null or cancellation not like '%C%'
group by order_id

-- or applying rank on rolls_delivered_successfully_per_order_id
select * , rank() over(order by rolls_delivered_successfully_per_order_id desc) rnk
from 
(
select order_id , count(*) rolls_delivered_successfully_per_order_id
from customer_orders natural join driver_order
where cancellation is null or cancellation not like '%C%'
group by order_id
) temp1;

-- highest order made id
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

#NOte-> alias name for derived table or subquery must ,,,,o/w error will come


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#PART2 (advanced queries).........here we need data in propper format,,ie;cleaned data we want,,,,
#so convert all null,NaN,'' to same conventions...ie;these 3 represent missing of info or empty value...alter
				|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
#DATA CLEANING PART
#1st clean the customer_orders table/dataset......convert   (NULL , NaN , '' )   to '0'.....  string zero bcz not_onclude_items and extra_items_included are varchar type
#so...you can change it to int,,but our use case is string,,bcz we are mentioning list of values separated with comma ,,so we keep varchar only
#Not modifying actual dataset,,instead creating temporary table,,which is cleaned..and using it for further evaluatiom
#you can create "VIEW",,,,,,but i will use "with" clause to create temporarary table ...also you can modify "original dataset" itself....alter#
#If you create temporary table(Not actually temporary table..it is common table ecperession) using "WITH"..then it can be accessiible for 1 query itself (Current executing query,,how much part you select that much only),,,and you have to copy paste it again  for further queries
#If you create  temporary table using "VIEW".. then this table is stored in data dictionary,and you can access it throught this session,,untill you exit from mysql session(Closing this software)
#If u update original dataset using update ,,then this is permanent change(actual dataset is modified),,,
#i think better option is 3rd one...one
												#modifying actual dataset

				-- select * from customer_orders
				-- update customer_orders
				-- set not_include_items = '0'
				-- where not_include_items = '' or not_include_items is null

				-- update customer_orders
				-- set extra_items_included = '0'
				-- where extra_items_included = '' or extra_items_included = 'NaN' or extra_items_included is null
	
#But in interview,,they dont allow you to updation,,you have to do using view or with,,,,,,so use with clause for creation temporary table
#This is the recommended way for interview point of view
#Using temp_customer_orders,,,you can access this table...........below in parenthesis u see it is not argument passigng like function....it is columns which are returned by query which is embedded inside with clause


#VVVVIIIMMMPPP
#NOTE-> if u are using  with clause (Common table expression) to create  common table(we can say temporaray table,,,,,this table is available for this query itself , not for this seession......if you want a temporary table throught this current seession then create VIEW
#hen you have to access it atleast one time in query,,o/w it will throw error
#ie; if you remove this select * from temp_customer_orders  query and ,,run the only -> with temp_customer_orders (c1...cn) as( // common query which is required more times in current query) then it will give error........

#1st clean customer_orders
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
select * from temp_customer_orders


#2nd clean driver_orders,,,,,in 8th query i require to clean just cancellation column/attribute
#cancellation - 0 means, no-cancellation(nc) ,,,, 1 means (cancellation)
with temp_driver_order ( order_id , driver_id , pickip_time , distance , duration , new_cancellation) as
(
	select order_id , driver_id , pickup_time , distance , duration , case 
																						when cancellation in ('cancellation','Customer Cancellation') then 1
                                                                                        when cancellation is null or cancellation ='NaN' or cancellation = '' then 0
                                                                                        else cancellation
																					 end as new_cancellation
	from driver_order
)
select * from temp_driver_order
#Internally this 0 and 1 is taken as string only.......even we given as int,,,,
#int and float can be converted implicitly converted to string
#but string with alpha and special character cant be converted to int/float implicintly
            
					||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
            
#8) for each customer , how many delivered rolls had at least 1 change and how many had no changes?
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
 ) alias_for_derived_table_it_is_must
 
 
 #VVVIIMMPP,,,,to get trick see deeply,,,ie;how you can create a column and each value of that column is made as new column
 #9) total changes made by each user out of all orders thaey made in past
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
 
 
 select customer_id , SUM(atleast_1_change_add_or_remove_ingradient) as total_changes_done_in_past  , sum(no_changes) dont_have_any_changes_in_Past , count(*) as total_orders_in_past
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
group by customer_id 


#now update the customer and driver,,,,bcz writing with clause in every query is tidious task....

		#customer_orders ,,updation
				update customer_orders
				set not_include_items = '0'
				where not_include_items = '' or not_include_items is null ;

				update customer_orders
				set extra_items_included = '0'
				where extra_items_included = '' or extra_items_included = 'NaN' or extra_items_included is NULL ;
                
                select * from customer_orders;
		
        #driver_orders
        
				update driver_order
                set distance = 0 
                where distance is null ;
                
                update driver_order
                set duration = 0
                where duration is null;
                
                update driver_order
                set cancellation = 0
                where cancellation = '' or cancellation = 'NaN' or cancellation is null;
                
                 update driver_order
                set cancellation = 1
                where cancellation in ('Cancellation' , 'Customer Cancellation');
                
                select * from driver_order
                
               --  update driver_order
--                 set pickup_time = 
--                 where pickup_time is null;
                
#Except date time data type  columns ,,,all other columns are cleaned successfully


#10)How many rolls were delivered that had both exclusion and extras?
select * from customer_orders;
select * from driver_order;

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

or

#no need to mention as,,,,,,,,but ise it increase readability,,,otherwise some times it is not readable....OKay
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


#11) what was the total no of rolls ordered for each hour of the day?

#First break the order_date in to (hour1 - hour2) format...bcz as u see order time is like 18:05:02,,which is in between 18 to 19,,,so make it (18 - 19)alter 
#then group by this (hr - hr),,and count

#VVVIIIMMMPPP
#See   (https://dev.mysql.com/doc/refman/8.4/en/date-and-time-functions.html#function_hour),,,to see date time function present in mysql

select * , concat(   hour(order_date) ,'-', hour(order_date)+1  ) as hour_range_for_order
from customer_orders;

select hour_range_for_order as hour_range_for_order  , count(*) as total_no_of_order_made_in_this_hour_range
from
(
	select * , concat(   hour(order_date) ,'-', hour(order_date)+1  ) as hour_range_for_order
	from customer_orders
) t
group by hour_range_for_order;

#as u see 18 to 22 (ie; 6pm to 9pm) more orders are done.....so chef would have to active at this time range more,,,bcz more orders coming in this range..



#12) what was the no of orders "in_total", for each day of the week ...?
select DAY_name , count(*) count
from
(
	select * , dayname(order_date) as DAY_name
	from customer_orders
) every_derived_table_must_have_alias_name_otherwise_error_will_thrown
group by DAY_name 

#from past data present in our db indicates on friday,,ie;at weekday_end , more orders are came....
#may be,,,, we have more friday related data's
#so check below query
#at what time?
select DAY_name , hour_range_for_order , count(order_id) count
from
(
	select * , dayname(order_date) as DAY_name , concat(   hour(order_date) ,'-', hour(order_date)+1  ) as hour_range_for_order
	from customer_orders
) every_derived_table_must_have_alias_name_otherwise_error_will_thrown
group by DAY_name , hour_range_for_order

#in that time range and day_name ,ow many unique users are placed order...
 
#according to our past data ,,, we can say on saturday at 9 to 10pm range,,more orders are



------------------------------------------------B.driver and customer experience----------------------------------------------------------

#13) what was the avg time in minutes it took for each  driver  to arrive  at the fassos HQ(head quarter) to pickup the order?	
#Note-> we are not talking about successful order,,,so not mention cancellation <> 1......just select those rows whose pickup_time is not null
#and u can observe ,,, cancellation = 1 only when pickup_time is null,,that means both give same result,,,cancellation <> 1 OR pickup_time is not null -> both give same result in this case
-- #select * , sum(time_gap) / count(order_id) from.......... like this also you can use arithmatic or mathamatic operator in select
#VVVVIIIMMPPP
#U can use matahamatics operator in SLECT and WHERE  , HAVING , ie;condition checking and displaying data clause...
#No

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
)sample2

#we can conclude that ,,driver_id 2,,,has average of 30 min per order for pickup the parcel ,to pickup the parcel from HQ from the time of order,,and it is more compare to other 2 drivers,,,so we have to take some action or invetigate him yo know what is cause...


#avg time taken by each driver to pickup parcel from HQ from order_time



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
																				PART-3
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


#14) is there any relation ship between no of rolls and how long the order takes to prepare
#Bcz we are nit talking about ,, successfull order,,,we are taliking about in general...ie;how much time take to prepare fot each order,so to check relationship b/n no_0f_rolls ordered on order_id and time_to_prepare_them

#truncate( number , decimal) -> decimal means ,,,no of decimal point you want to consider,,,,...........i dont want any decimal points so i have given ZERO(0)

select order_id , count(*) as No_of_rolls_ordered_on_this_order_id , truncate(sum(time_gap_between_order_and_pickup_time) / count(*) , 0 )  as AVG_time_require_to_prepare_this__order_in_minutes
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
group by order_id

#(8,	1,	52) tis is the OUTLIER,,so remove it for analysiong the relationshil between roll cnt and avf time reuire to prepare that many no of roll OR that order...


# that means,,, as u see  (1,	1,	10 Minute)  this is the first tuple (order_id , no_of_roll_in_this_order , avg_time_require_to_prepare_this_order),,,order_id has only ordered for 1 roll...
# (3,	2,	14  Minute) ->  for order_id 3 ,, 2 rolls are given to prepare and on_an_avg time require to prepare this order is 14 min

#Now represent the relationship between  roll count and avg time to prepare them , per order..........in EXCEL....

#as u see,,,for preapring 1 roll,,,on an avg 10 min is require,,,,if work is "serially"........ 

#Result From Excel we get............
#As u see,,there exist a Linear Relationship Between roll_count and avg_time_to_prepare_order,,,ie;if no of rolls increase in order then ,, time to prepare that order is also increased,,,(Positive Correlation)….and avg time to preapre 1 roll is around around 10 min


#15) what was the average distance travelled for each customer?
#Data Cleaning Part is here...........................
#removing cancelled orders,,,which is noise in our data,,and can cause some wrong analysis....
#decimal(4,2),,,,,atmost 4 values come before decimal point and atmost 2 point come after decimal point

#A)Avg distance travelled by each driver
select driver_id , avg(decimal_distanec_in_km)
from
(
select * , cast(trim(replace(lower(d1.distance) , 'km' , '')) as decimal(4,2) ) as decimal_distanec_in_km
from driver_order d1
where cancellation <> 1
) temp
group by driver_id

#B)Avg distance Travelled for each customer

select customer_id , avg(decimal_distanec_in_km)
from
(
select * , cast(trim(replace(lower(d1.distance) , 'km' , '')) as decimal(4,2) ) as decimal_distanec_in_km
from driver_order d1 natural join customer_orders
where cancellation <> 1
) temp
group by customer_id

#For customer 105 ,,,, Our delivery boyz or driver traveled on an average 25km from HQ/restaurant.............
#thus we have to shift our resto such that , it can connect all customers nearly  or we can open another one resto in such way that it shoul nearer to 105 customer......(only if many customers are from that position,,otherwise for single customer we will not do,,LOL..........HAAAAAAA)


# 16) what was the difference bn longest and shortest delivery times for all orders?
#Data Cleaning require...............as u see in duration  'mins' , 'minutes' , 'minute' is present ,,how will you clean it to get only numeric value...........
#SELECT LEFT("SQL Tutorial", 5) AS ExtractString;  -> SQL T    ,,,,extract string from left position to count =5
#SELECT POSITION("3" IN "W3Schools.com") AS MatchPosition;   -> 2
#decimal can represent both int and float,,,thats why in mysql int and float keywords are not present,,use decimal itself,,,and use round or decimal(no_of_numerica_value_you_want_before_the_decimal_point , no_of_values_you_want_after_the_decimal_point)

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
group by driver_id

#
#Max duartion taken by order is 40min,,,,,and min duration taken by order is 10 min
select max(duration_in_minute) , min(duration_in_minute)
from
(
	select * , case
				when duration like '%min%' then cast(trim(left(duration , position('m' in  duration ) - 1 )) as decimal) 
				else cast(duration as decimal)
				end as duration_in_minute
	from driver_order
	where cancellation <> 1
) temp

#

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
where duration_in_minute in (40 , 10)

# 17) what was the avg speed for each driver for each delivery and do you notice any trend for these values?
speed = distance / time  => per minute
-- ex -> 13.4 / 20 => 0.6 km per minute,,,ie;he has to trabel with the speed of 600 meter per minute,,then he will cover 13.4 km distance in 20 minute

#duration -> time needed to reach the destination from HQ(head quarter or restaurant)
#distance -> distance of customer place from HQ in Km

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
) temp


# 18) what is successful order delivery percentage for each driver?
-- successfull_order_delivered_percentage = successfully_delivered_the_orders / count_of_orders_driver_gets


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
) temp2


#14) Most used ingredients for each roll:
				SELECT r.roll_name, i.ingredients_name
                FROM rolls_recipes rr
                JOIN rolls r ON rr.roll_id = r.roll_id
                JOIN ingredients i ON FIND_IN_SET(i.ingredients_id, rr.ingredients)
                ORDER BY r.roll_name, i.ingredients_name;
                
                

















