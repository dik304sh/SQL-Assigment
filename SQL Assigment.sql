-- -------------------------------------------------------------SQL ASSIGNMENT---------------------------------------------------------------------------------------------

create database classicmodels;
use classicmodels;
-- ------------------Q1--------------------------------------
-- Q1. SELECT clause with WHERE, AND, DISTINCT, Wild Card (LIKE)
-- a.Fetch the employee number, first name and last name of those employees who are working as Sales Rep reporting to employee with employeenumber 1102 (Refer employee table)

select employeeNumber,firstName,lastName
from employees
where jobTitle='Sales Rep' and reportsTo=1102; 

-- Q1 b.	Show the unique productline values containing the word cars at the end from the products table.-----

select distinct productLine
from products
where productLine LIKE '%Cars';

-- ------------------Q2--------------------------------------
-- Q2. CASE STATEMENTS for Segmentation
SELECT customerNumber, customerName,
       CASE
         WHEN country IN ('USA', 'Canada') THEN 'North America'
         WHEN country IN ('UK', 'France', 'Germany') THEN 'Europe'
         ELSE 'Other'
       END AS CustomerSegment
FROM customers;

-- ------------------Q3--------------------------------------
-- Q3 (A). Group By with Aggregation functions and Having clause, Date and Time functions-----
SELECT productCode, SUM(quantityOrdered) AS total_quantity
FROM orderdetails
GROUP BY productCode
ORDER BY total_quantity DESC
LIMIT 10;

-- Q3 (B)-----
SELECT MONTHNAME(paymentDate) AS month_name,
       COUNT(*) AS total_payments
FROM payments
GROUP BY MONTHNAME(paymentDate)
HAVING COUNT(*) > 20
ORDER BY total_payments DESC;

-- ------------------Q4--------------------------------------
-- Q4. CONSTRAINTS: Primary, key, foreign key, Unique, check, not null, default
-- (A)
CREATE DATABASE Customers_Orders;
USE Customers_Orders;

-- Customers table
CREATE TABLE Customers (
  customer_id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  email VARCHAR(255) UNIQUE,
  phone_number VARCHAR(20)
);
select * from Customers;

-- (B) Orders table
CREATE TABLE Orders  (
  order_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT,
  order_date DATE,
  total_amount DECIMAL(10,2),
  CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
  CONSTRAINT chk_amount CHECK (total_amount > 0)
);
select * from Orders;
-- ------------------Q5--------------------------------------
-- Q5. JOINS
-- (a)
use classicmodels;
SELECT c.country, COUNT(o.orderNumber) AS order_count
FROM customers c
JOIN orders o 
ON c.customerNumber = o.customerNumber
GROUP BY c.country
ORDER BY order_count DESC
LIMIT 5;

-- ------------------Q6--------------------------------------
-- Q6. SELF JOIN
CREATE TABLE project (
  EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
  FullName VARCHAR(50) NOT NULL,
  Gender ENUM('Male','Female'),
  ManagerID INT
);

-- INSERT THE VLUES--------
INSERT INTO project (FullName, Gender, ManagerID) VALUES
('Pranaya', 'Male', 3),        
('Priyanka', 'Female', 1),        
('Preety', 'Female', null),            
('Anurag', 'Male', 1),          
('Sambit', 'Male', 1),
('Rajesh', 'Male', 3),
('Hina', 'Female', 3);           

select * from project;

SELECT e.FullName AS Employee, m.FullName AS Manager
FROM project e
LEFT JOIN project m
ON e.ManagerID = m.EmployeeID ;

-- ------------------Q7--------------------------------------
-- Q7. DDL Commands: Create, Alter, Rename

drop table facility;
CREATE TABLE facility (
  Facility_ID INT,
  Name VARCHAR(100),
  State VARCHAR(100),
  Country VARCHAR(100)
);

ALTER TABLE facility
  MODIFY Facility_ID INT AUTO_INCREMENT PRIMARY KEY;

ALTER TABLE facility
  ADD city VARCHAR(100) NOT NULL AFTER Name;

desc facility;
-- ----------------- Q8----------------------------------------------------------------------------------------
-- Q8. Views in SQL
CREATE VIEW product_category_sales AS
SELECT 
    pl.productLine,
    SUM(od.quantityOrdered * od.priceEach) AS total_sales,
    COUNT(DISTINCT o.orderNumber) AS number_of_orders
FROM productlines pl
JOIN products p ON pl.productLine = p.productLine
JOIN orderdetails od ON p.productCode = od.productCode
JOIN orders o ON od.orderNumber = o.orderNumber
GROUP BY pl.productLine;

SELECT * FROM product_category_sales;

-- --------------------Q9----------------------------------------------------------------------------
-- Q9. Stored Procedures in SQL with parameters
DELIMITER //
drop PROCEDURE Get_country_payments;
CREATE PROCEDURE Get_country_payments(IN in_year INT, IN in_country VARCHAR(50))
BEGIN
    SELECT 
        YEAR(p.paymentDate) AS Year,
        c.country,
        CONCAT(ROUND(SUM(p.amount)/1000,0), 'K') AS total_amount
    FROM Customers c
    JOIN Payments p ON c.customerNumber = p.customerNumber
    WHERE YEAR(p.paymentDate) = in_year
      AND c.country = in_country
    GROUP BY YEAR(p.paymentDate), c.country;
END //

DELIMITER ;

CALL Get_country_payments(2003, 'France');

-- -----------------------------10-----------------------------------------
-- Q10. Window functions - Rank, dense_rank, lead and lag
-- (A)
SELECT 
    c.customerName,
    COUNT(o.orderNumber) AS order_count,
    RANK() OVER (ORDER BY COUNT(o.orderNumber) DESC) AS rank_position,
    DENSE_RANK() OVER (ORDER BY COUNT(o.orderNumber) DESC) AS dense_rank_position
FROM Customers c
JOIN Orders o ON c.customerNumber = o.customerNumber
GROUP BY c.customerName;


-- (B)
with MonthlyOrders as (
select 
year(orderdate) as YearOrder, month(orderdate) as MonthNum, monthname(orderdate) as MonthOrder, count(ordernumber) as TotalOrders
from Orders
group by year(orderdate), month(orderdate), monthname(orderdate)
)
select YearOrder as Year, MonthOrder as Month,TotalOrders,
coalesce(concat(round(( (TotalOrders - lag(TotalOrders) over (order by YearOrder, MonthNum)) * 100.0/ nullif(lag(TotalOrders) over (order by YearOrder, MonthNum), 0) ), 0), '%'
),'null') as MoM_Change
from MonthlyOrders
order by YearOrder, MonthNum;

-- ----------------------------------Q11------------------------------------------------------------
-- Q11.Subqueries and their applications
SELECT productLine, COUNT(*) AS product_count
FROM products
WHERE buyPrice > (SELECT AVG(buyPrice) FROM products)
GROUP BY productLine
ORDER BY product_count desc;

-- ----------------------------------Q12---------------------------------------------------------
-- Q12. ERROR HANDLING in SQL
drop table emp_EH;
CREATE TABLE Emp_EH (
    EmpID INT PRIMARY KEY,
    EmpName VARCHAR(50),
    EmailAddress VARCHAR(100)
);

SELECT * FROM Emp_EH;

DELIMITER //

DROP PROCEDURE IF EXISTS InsertEmpEH;
CREATE PROCEDURE InsertEmpEH(
    IN in_EmpID INT,
    IN in_EmpName VARCHAR(50),
    IN in_Email VARCHAR(100)
)
BEGIN
    -- Error handler
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        SELECT 'Error occurred' AS Message;
    END;

    -- Insert statement
    INSERT INTO Emp_EH (EmpID, EmpName, EmailAddress)
    VALUES (in_EmpID, in_EmpName, in_Email);

    -- Success message
    SELECT 'Inserted Successfully' AS Message;
END //

DELIMITER ;

CALL InsertEmpEH(1, 'John Doe', 'john@example.com'); -- Inserted Sucessfully
CALL InsertEmpEH(1, 'Jane Doe', 'jane@example.com'); -- Error Occured

-- -------------------------------------------------------Q13-----------------------------------------------------------
-- Q13. TRIGGERS
CREATE TABLE Emp_BIT (
    Name VARCHAR(50),
    Occupation VARCHAR(50),
    Working_date DATE,
    Working_hours INT
);

INSERT INTO Emp_BIT VALUES
('Robin', 'Scientist', '2020-10-04', 12),  
('Warner', 'Engineer', '2020-10-04', 10),  
('Peter', 'Actor', '2020-10-04', 13),  
('Marco', 'Doctor', '2020-10-04', 14),  
('Brayden', 'Teacher', '2020-10-04', 12),  
('Antonio', 'Business', '2020-10-04', 11);

SELECT * FROM Emp_BIT;

DELIMITER //

CREATE TRIGGER trg_before_insert_EmpBIT
BEFORE INSERT ON Emp_BIT
FOR EACH ROW
BEGIN
    -- If Working_hours is negative, convert it to positive
    IF NEW.Working_hours < 0 THEN
        SET NEW.Working_hours = ABS(NEW.Working_hours);
    END IF;
END //

DELIMITER ;

INSERT INTO Emp_BIT VALUES ('Chris', 'Nurse', '2020-10-05', -9);
SELECT * FROM Emp_BIT;

use classicmodels;
select * from customers;
desc customers;
-- Find all customers from the USA:
select *
from customers 
where country="USA";

-- Customers with creditLimit > 100000
select * from customers
where creditLimit > 100000;

-- Customers whose city is 'Paris' or 'Lyon':
select * from customers 
where city IN('Paris' , 'Lyon');

-- Customers whose customerName starts with 'Mini
select customerName from customers
where customerName like 'Mini%';

-- Top 5 customers with highest credit limit
select customerName ,creditlimit
from customers
order by creditLimit desc
limit 5;

-- Customers sorted by country and then by city
select customerName ,country,city from customers
order by country,city asc;

desc customers;
-- Total credit limit per country:
select sum(creditLimit), country 
from customers
group by country;


-- Average credit limit per country
select country,avg(creditLimit) as avg_credit
from customers
group by country;

-- Number of customers per country:
select country,count(*) from customers
group by country;

-- Customers with maximum credit limit
select customerName,creditLimit
from customers
order by creditLimit desc
limit 1;

-- or

select max(creditLimit) from customers
where creditLimit=(select max(creditLimit) from customers);


-- Customers with credit limit higher than average
select customerName,creditLimit from customers
where creditLimit>(select avg(creditLimit) from customers);

-- Customers from countries ending with a vowel:

SELECT *
FROM customers
WHERE country LIKE '%a'
   OR country LIKE '%e'
   OR country LIKE '%i'
   OR country LIKE '%o'
   OR country LIKE '%u';

-- Customers whose phone starts with '+49' (Germany):
select * from customers
where phone LIKE '+49%';

-- Customers whose name contains 'Gift':
select * from customers
where customerName LIKE '%Gift%';

-- Second highest credit limit
select max(creditLimit) from customers
where creditLimit<(select max(creditLimit) from customers);

-- or

select creditLimit from customers
order by creditLimit desc
limit 1 offset 1;

-- Top 3 customers by country based on credit limit
SELECT *
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY country ORDER BY creditLimit DESC) AS rn
    FROM Customers
) AS sub
WHERE rn <= 3;
