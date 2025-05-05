#----------------------------------Q1. SELECT clause with WHERE, AND, DISTINCT, Wild Card (LIKE)--------------------------------------
use classicmodels;
select * from employees;

# a.Fetch the employee number, first name and last name of those employees who are working as Sales Rep reporting to employee with employeenumber 1102
select employeeNumber, firstName, lastName from employees where jobtitle= "Sales Rep" and reportsTo = 1102;

# b.Show the unique productline values containing the word cars at the end from the products table.
select distinct productLine from products where productLine like "%cars";



#----------------------------------------Q2. CASE STATEMENTS for Segmentation-----------------------------------------------

#a. Using a CASE statement, segment customers into three categories based on their country:(Refer Customers table) "North America" for customers from USA or Canada, "Europe" for customers from UK, France, or Germany, "Other" for all remaining countries. Select the  customerNumber, customerName, and the assigned region as "CustomerSegment".

select customerNumber, customerName, 
case 
when country in ("USA", "Canada") then "North America"
when country in ("UK", "France","Germany") then "Europe"
else "Other"
end as CustomerSegment
from customers
;


#----------------------Q3. Group By with Aggregation functions and Having clause, Date and Time functions-------------------------

# a.Using the OrderDetails table, identify the top 10 products (by productCode) with the highest total order quantity across all orders.
select productCode, sum(quantityordered) as total_order from orderdetails group by productCode order by total_order desc limit 10  ;

#b.	Company wants to analyse payment frequency by month. Extract the month name from the payment date to count the total number of payments for each month and include only those months with a payment count exceeding 20. Sort the results by total number of payments in descending order.

select monthname(paymentdate) as payment_month, count(*) as num_payments 
from payments
group by payment_month 
having count(*) > 20
order by num_payments desc
;


#--------------------Q4. CONSTRAINTS: Primary, key, foreign key, Unique, check, not null, default-------------------------------------

# a. 
create database Customers_Orders;
use customers_orders;
create table Customers (customer_id int primary key auto_increment, first_name varchar(50) not null,last_name varchar(50) not null, email varchar(255) unique, phone_number varchar(20));
desc customers;

# b.
create table Orders(order_id int primary key auto_increment, customer_id int, foreign key (customer_id) references Customers(customer_id), order_date date, total_amount decimal(10,2) check (total_amount >= 0) );
desc orders;



#----------------------------------------------Q5. JOINS-------------------------------------------------------------------------------
#a. List the top 5 countries (by order count) that Classic Models ships to. (Use the Customers and Orders tables)
select * from customers;
select * from orders;
select customers.country as country , count(orders.orderNumber) as order_count from customers inner join orders on customers.customerNumber= orders.customerNumber group by country order by order_count desc limit 5;



#------------------------------------------------Q6. SELF JOIN-------------------------------------------------------------------------

create table project(EmployeeID int primary key auto_increment, FullName varchar(50), Gender varchar(10) check (Gender in ("Male", "Female")), ManagerID int );

insert into project (FullName, Gender, ManagerID) values ("Pranaya","Male",3), 
                                                         ("Priyanka","Female",1),
                                                         ("Preety","Female", null),
                                                         ("Anurag","Male",1),
                                                         ("Sambit","Male",1),
                                                         ("Rajesh","Male",3),
                                                         ("Hina","Female",3);
select * from project;
select p1.FullName as `Manager Name`, p2.FullName as `Emp name` from project as p1 inner join project as p2 on p1.EmployeeID=p2.ManagerID order by `manager name`; 



#------------------------------------Q7. DDL Commands: Create, Alter, Rename----------------------------------------------------------

create table facility(Facility_id int , name varchar(100)  , State varchar(100), Country varchar(100));
alter table facility modify column Facility_ID int primary key auto_increment;
alter table facility add column City varchar(100) not null after name;
desc facility;



#-----------------------------------------Q8. Views in SQL-----------------------------------------------------------------------------

create view product_category_sales as
select 
productlines.productLine as productline,
sum(orderdetails.quantityordered * orderdetails.priceEach) as total_sales,
count(distinct orders.ordernumber) as number_of_orders
from products
join
productlines on products.productline = productlines.productline
join
OrderDetails on products.productCode = OrderDetails.productCode
join
Orders  ON OrderDetails.orderNumber = orders.orderNumber
group by
productLines.productLine
;
select * from product_category_sales;


#------------------------------Q9. Stored Procedures in SQL with parameters------------------------------------------
/*
CREATE DEFINER=`root`@`localhost` PROCEDURE `Get_Country_Payments`(`Mention_Year` int, `Mention_Country` varchar(20))
BEGIN
WITH CTE as
(select year(paymentDate) as `Year`, country  , amount 
from customers c join payments p on c.customerNumber = p.customerNumber)
select `Year` , country, concat(round(sum(amount)/1000),"K") as TotalAmount from CTE 
group by `Year`, country having `Year` = `Mention_Year` and country = `Mention_Country`;
END
*/
call get_country_payments(2003,"France");

#------------------------------Q10. Window functions - Rank, dense_rank, lead and lag-----------------------------------
# a) Using customers and orders tables, rank the customers based on their order frequency

WITH CTE AS 
(SELECT c.customername, COUNT(o.ordernumber) AS order_count FROM customers as c 
JOIN orders as o ON c.customernumber = o.customernumber
GROUP BY c.customernumber, c.customername )
SELECT customername, order_count, dense_RANK() OVER (ORDER BY order_count DESC) AS order_frequency_rnk
FROM CTE ORDER BY order_count DESC;


#b) Calculate year wise, month name wise count of orders and year over year (YoY) percentage change. Format the YoY values in no decimals and show in % sign.

WITH CTE as
(select year(orderDate) as `Year`, monthname(orderDate) as `Month`, count(CustomerNumber) as `total order` from orders 
group by year(orderDate), monthname(orderDate))
select `Year`, `Month`,`total order`, concat(round((`total order` - lag(`total order`) over(Partition by `Year`))*100/lag(`total order`) over(Partition by `Year`)), "%") as `% YOY change` from CTE;

#------------------------------------Q11.Subqueries and their applications--------------------------------------------

# a) Find out how many product lines are there for which the buy price value is greater than the average of buy price value. Show the output as product line and its count.

SELECT productline, COUNT(DISTINCT productcode) AS product_count FROM products
WHERE buyprice > (SELECT AVG(buyprice) FROM products)
GROUP BY productline order by product_count desc;


#---------------------------------Q12. ERROR HANDLING in SQL----------------------------------------------
create table emp_eh (empid int primary key, empname varchar(10), emailaddress varchar(50));
/*
CREATE DEFINER=`root`@`localhost` PROCEDURE `pro_empEH`(eid int, ename varchar(10), email varchar(50))
BEGIN
declare continue handler for 1062
begin 
select "Error occurred" as Message;
end;
insert into emp_eh (empid, empname, emailaddress) values (eid, ename,email);
END
*/
call pro_empEH(1,"vaishu","vaish@gmail.com");


#----------------------------------------Q13. TRIGGERS----------------------------------------------

create table emp_bit (name varchar(100), occupation varchar(50), working_date date, working_hours int);
desc emp_bit;
select * from emp_bit;
INSERT INTO Emp_BIT VALUES ('Robin', 'Scientist', '2020-10-04', 12),  
						('Warner', 'Engineer', '2020-10-04', 10),  
                        ('Peter', 'Actor', '2020-10-04', 13),  
                        ('Marco', 'Doctor', '2020-10-04', 14),  
                        ('Brayden', 'Teacher', '2020-10-04', 12),  
                        ('Antonio', 'Business', '2020-10-04', 11);  
/*
CREATE DEFINER=`root`@`localhost` TRIGGER `emp_bit_BEFORE_INSERT` BEFORE INSERT ON `emp_bit` FOR EACH ROW BEGIN
if new.working_hours <0 then 
set new.working_hours = -(new.working_hours);
end if;
END
*/          
insert into emp_bit value ("Robert","Doctor", "2024-3-04", -17);