
select * from customer
select * from Transactions
select * from prod_cat_info


--q1 Total number of rows in each of three tables in database--
select 'Customer' as tbl_name,
count(*) as no_of_records
from customer
union all
select 'transactions' as tbl_name,
count (*) as no_of_records from transactions
union all
select 'prod_cat_info' as tbl_name,
count (*) as no_of_records from prod_cat_info

---q2Total number of transactions that have a return--
select
count(transaction_id) as [COUNT OF TRANSACTION IDs]
from Transactions
where CAST(TOTAL_amt as float) <0

--q3 Conevert date variables into valid date formats--
SELECT 
CONVERT(DATE,Tran_date,105) as [new tran date] from Transactions
select 
 CONVERT (DATE,DOB,105) AS [NEW DOB]
from customer



--q4Show time range of data for analysis in different columns as days, months, years--
SELECT 
CONVERT(DATE,Tran_date,103) as new_tran_date ,
Datepart(DAY,CONVERT(DATE,Tran_date,103)) as days_differnce,
Datepart(month,CONVERT(DATE,Tran_date,103)) as months_difference,
Datepart(year,CONVERT(DATE,Tran_date,103)) as years_difference
from Transactions



--q5Which product category does sub categpry 'DIY ' beloo=ngs to ?--
select prod_cat
from prod_cat_info
where prod_subcat = 'DIY'

--DATA ANALYSIS--

--Q1Most frequently used channel for transactions--
SELECT top 1* from 
( select 
store_type,
count(store_type) as count_of_channels from Transactions
group by store_type)
as tbl_1
order by
count_of_channels desc



--q2 Count of male female customers in database?--
SELECT 
CASE WHEN GENDER ='M' THEN COUNT(city_code) END AS MALE_COUNT,
CASE WHEN GENDER ='F' THEN COUNT(city_code) END AS FEMALE_COUNT
FROM CUSTOMER
GROUP BY Gender


--Q3 From which city we have maximum customers and how many? --
Select top 1 * from (select
city_code,
count(city_code) as no_of_customers from Customer
group by city_code) as tbl_1
order by no_of_customers desc

--q4 How many sub categories under books category --
select 
count(prod_subcat) from prod_cat_info
where prod_cat = 'Books'

--q5 Maximum quantty of products ever ordered? --
select
max(Qty) as highest_qty
from Transactions

--Q6 Net toal revenue generated in ELectronics and Books--


Select 
t1.prod_cat_code,t2.prod_cat, sum(convert(float,abs(total_amt))) as net_revenue
from Transactions as t1
left join prod_cat_info as t2 on t1.prod_cat_code =t2.prod_cat_code and t1.prod_subcat_code = t2.prod_sub_cat_code
group by
t1.prod_cat_code, t2.prod_cat
having
t2.prod_cat= 'electronics' or t2.prod_cat='books'


--q7 How many customers have greter than 10 tranx exlcuding returns? --

Select 
cust_id,
count(transaction_id) as order_count
from transactions
where cast(total_amt as float) >0
group by cust_id
having count(transaction_id) > 10

--q8 What is combined revenue from 'Electronic& Clothing from flagship stores --
Select
sum(convert(float, (total_amt))) as combined_revenue
from Transactions
where Store_type ='Flagship store' and (prod_cat_code = '1' or prod_cat_code = '3')

--q9 Total revenue from 'Male ' customrs in 'Electronics category.--
Select t1.prod_cat,t1.prod_subcat,Gender,sum(convert(float,(total_amt))) as total_revenue from prod_cat_info as t1
inner join Transactions as t2 on t1.prod_cat_code= t2.prod_cat_code and t1.prod_sub_cat_code = t2.prod_subcat_code
inner join Customer as t3 on t2.cust_id = t3.customer_Id
group by t1.prod_cat,t1.prod_subcat,t3.Gender
having 
prod_cat='Electronics' and Gender = 'M'

--q10 Percentage fo sales & returns by prouct sub category display only top 5?--
Select TOP 5
t1.prod_subcat,
Sum(convert(float,abs(total_amt)))/(select sum(convert(float,abs(total_amt))) as total_sales from transactions where Qty>0) as sales_ptg,
Sum(convert(float,abs(total_amt)))/(select sum(convert(float,abs(total_amt))) as total__sales from Transactions where Qty<0) as returns_ptg
from transactions as t2
Left join prod_cat_info as t1 on t2.prod_cat_code= t1.prod_cat_code and t2.prod_subcat_code = t1.prod_sub_cat_code
group by 
t1.prod_subcat
order by
sum(convert(float, abs(total_amt))) desc 


--q11 Net revenue generaated by customers from age group 25-35 years in last 30 days of transactions?--
	Select 
	sum(convert(float,total_amt)) as total_revenue
	from 
	Customer as t1
	left join Transactions as t2 on t1.customer_Id = t2.cust_id
	where
	DATEDIFF(year,convert(Date,DOB,105),GETDATE()) <=35 and DATEDIFF(year,convert(date,DOB,105),GETDATE()) >=25
	and
	DATEDIFF(day,convert(date,tran_date,105),(select max(convert(date,tran_date,105))from Transactions)) <=30

	--q12 Which category has seen max value of returns in last three months of trnasactions?--
	Select 
	distinct prod_cat
	from prod_cat_info as tbl1
	inner join ( 
	Select top 1
	prod_cat_code as catg_code,
	ABS(sum(cast(Qty as INT))) as return_count
	from 
	Transactions
	where 
	Qty<0 and 
	DATEDIFF(MONTH,CONVERT(DATE,Tran_date,105), (select max(convert(Date,tran_date,105)) from Transactions))<3
	group by
	prod_cat_code
	order by
	return_count desc)

	as calc_tbl on prod_cat_code = catg_code

--q13 Which store type has max products by value of sales amount and quantitysold? --

SELECT top 1
store_type, sum(convert(float,total_amt)) as sales_amount,
sum(convert(float,Qty)) as sold_qty 
from 
Transactions
group by Store_type
order by sales_amount desc , sold_qty desc

--q14 What categories have average revenue abpve overall average --
select 
prod_cat , AVG(convert(float,total_amt)) as average_revenue
from prod_cat_info as tbl1
left join
 Transactions as tbl2 on tbl1.prod_cat_code= tbl2.prod_cat_code
 group by
 prod_cat
 having AVG(convert(float,total_amt)) > (select AVG(convert(float, total_amt)) from Transactions)

 --q15 For top 5 categories interms of quantity sold what is average and total revwnuw by each subcategory--
select 
prod_subcat_code , prod_cat_code,
 abs(AVG(convert(float,total_amt))) as average_revenue, SUM(convert(float, total_amt )) as total_revenue
from Transactions
where prod_cat_code in (
Select top 5 tbl1.prod_cat_code
from Transactions as tbl1
left join 
prod_cat_info as tbl2 on tbl1.prod_subcat_code = tbl2.prod_sub_cat_code and tbl1.prod_cat_code =tbl2.prod_cat_code
group by
tbl1.prod_cat_code
order by
SUM(convert(int,tbl1.Qty)) desc)
group by
prod_cat_code, prod_subcat_code

