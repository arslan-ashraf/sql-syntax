-- CREATING A TABLE
	CREATE TABLE example_table (
		id INT NOT NULL PRIMARY KEY auto_increment,
		first_name CHAR(255) NOT NULL,
		last_name VARCHAR(255) NOT NULL,
		info TEXT NULL, -- nulls (missing value) okay in this column
		created_at DATE,  -- yyyy-mm-dd
		updated_at DATETIME,  -- yyyy-mm-dd hh:mm:ss
		foreign_id INT, -- foreign key in this table and primary key in some other table
		foreign key (foreign_id) references parent_table_name(primary_key_column_name)
		-- PRIMARY KEY (id) also acceptable 
		-- contraint PK_example_table PRIMARY KEY (id) => in sql server
		-- foreign_id int foreign key references parent_table_name(primary_key_column_name) => sql server
	)

-- INSERTING INTO A TABLE
	INSERT INTO example_table (id, first_name, last_name, etc) VALUES (1, 'a', 'b', etc)

-- ALTERING A TABLE
	-- Drop a column
	ALTER TABLE example_table 
	drop
	primary key;  -- drop contraint PK_example_table => in sql server

	-- Insert a new column with default value of 'unregistered_user' 
	ALTER TABLE example_table 
	ADD user_type VARCHAR(50) NOT NULL
	CONSTRAINT default_constraint_user_type DEFAULT unregistered_user

	-- Add a CHECK CONTRAINT to force values within a range
	ALTER TABLE customers_table
	ADD CONSTRAINT check_constraint_age_range CHECK (age_column >= 0 AND age_column < 120)

	-- Drop any constraint
	ALTER TABLE example_table
	DROP CONSTRAINT default_constraint_user_type

-- CREATE TEMPORARY TABLES (they get deleted when the current session is terminated)
	CREATE TEMPORARY TABLE temp_example_table as (
		SELECT * FROM some_table
	)

-- SELECT UNIQUE VALUES FROM A COLUMN
	SELECT DISTINCT column_name_1 FROM example_table



-- FILTERING
	SELECT column_name_1 FROM example_table WHERE column_name_1 > number_value -- proper type comparisons only
	
	-- filtering with wildcards, NOTE: wildcards are slower, use =, <, > when possible
	WHERE column_name_1 LIKE "%abc%"
	-- %abc% filters strings where 'abc' can have anything before and after 'abc'
	-- %abc filters strings that end with 'abc'
	-- abc% filters strings that begin with 'abc'
	-- a%c filters anything beginning with 'a' and ending with 'c'
	-- a%@gmail.com filters all strings that begin 'a' and end with '@gmail.com'
	
	-- where clause with multiple comparison values
	WHERE column_name_1 IN (a table from a subquery or some list) -- or
	WHERE column_name_1 IN (1,2,3)
	-- other conditions
	BETWEEN, !=, IN, NOT IN, OR, AND



-- AGGREGATE FUNCTIONS: SUM, MIN, MAX, AVG, COUNT
	SELECT AVG(price_column) as avg_price FROM products
	SELECT COUNT(*) as all_rows FROM example_table -- counts all rows including nulls
	SELECT COUNT(id) FROM example_table -- ignores where id is null



-- GROUPING
	SELECT column_name_1, COUNT(column_name_1)
	FROM example_table
	GROUP BY column_name_1 -- nulls in column_name_1 are grouped in its own category

-- NOTE: the WHERE clause filters data before it is grouped and 
-- the HAVING clause filters data after it is grouped
	-- the WHERE clause filters on rows, not groups, if WHERE clause is below GROUP BY,
	-- the query won't run, to filter on groups, use the HAVING clause
	SELECT column_name_1, COUNT(column_name_1)
	FROM example_table
	WHERE column_name_2 > condition
	GROUP BY column_name_1 -- nulls in column_name_1 are grouped in its own category

	-- HAVING clause can only be used on columns which are grouped
	-- column_name_1, column_name_2 in this query
	-- so putting column_name_3 in the HAVING clause won't work
	-- because HAVING filters on groups
	SELECT column_name_1, column_name_2, column_name_3, SUM(column_name_1) AS total
	FROM example_table
	GROUP BY column_name_1, column_name_2
	HAVING column_name_2 LIKE 'n%' -- or HAVING SUM(column_name_1) > 5


-- How to read uncommited data
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
	-- Another way
	SELECT * FROM inventory_table (NOLOCK) WHERE product_id = 1


/* --------------------------------------------------------------------------------------- */
/* ---------------------------------------SUBQUERIES-------------------------------------- */
/* --------------------------------------------------------------------------------------- */


Subqueries can appear in the SELECT, WHERE, FROM clauses and possibly in other clasuses as 
well. A subquery can only select a single column.
Its important to note that if a subquery is uncorrelated with the outer query, then the 
subquery can be run by itself and its results can be substituted in the outer query and this 
is efficient. But if the subquery is correlated, then for each row in the outer query, the 
subquery needs to run and this is higly inefficient.

	-- Problem: Find all customers whose shipping cost exceeds 100
	SELECT 
		customer_id, customer_name
	FROM 
		customers_table
	WHERE 
		customer_id in (
		SELECT customer_id FROM orders_table WHERE shipping_cost > 100
	)

	-- Problem: Find customer information and the total number of orders from 
	-- the orders_table for each customer
	SELECT 
		customer_name, 
		customer_state, 
		(
			SELECT COUNT(*) AS number_of_orders
			FROM orders_table 
			WHERE orders_table.customer_id = customers_table.customer_id
		) AS number_of_orders
	FROM customers_table



/* --------------------------------------------------------------------------------------- */
/* -------------------------------------END SUBQUERIES------------------------------------ */
/* --------------------------------------------------------------------------------------- */

-- JOINS
	-- CROSS JOIN (Cartesian Join): Joins each record from one table to EVERY record from
	-- another table, these joins have a O(n*m) space complexity
	SELECT 
		product_name, unit_price, company_name
	FROM 
		suppliers_table
	CROSS JOIN 
		products_table

	-- INNER JOIN: Joins only the rows that match on some column between both tables
	-- This is the same as intersection between two sets
	SELECT 
		suppliers.company_name,
		products.product_name,
		products.unit_price
	FROM 
		suppliers_table AS suppliers
	INNER JOIN 
		products_table AS products
	ON 
		suppliers.supplier_id = products.supplier_id

	-- Multiple tables joined using INNER JOIN
	-- First join orders_table and customers_table, then take the resulting joined 
	-- table and join it with employees_table
	SELECT 
		orders.order_id,
		suppliers.company_name,
		exmployees.last_name
	FROM (
		(
			orders_table AS orders
			INNER JOIN customers_table AS customers
			ON orders.customer_id = customers.customer_id
		)
		INNER JOIN employees_table AS exmployees
		ON orders.employee_id = employees.employee_id
	)

	-- Self join
	-- Problem: Find customers in the same city
	SELECT 
		a.customer_name AS customer_a,
		b.customer_name AS customer_b
		a.City
	FROM
		customers_table AS a, customers_table AS b
	WHERE 
		a.customer_id != b.customer_id AND
		a.city = b.city

	-- LEFT JOIN: everything from the first table and only matching columns from the second
	-- RIGHT JOIN - same as left except order is reversed



-- UNIONS
	-- Same number and type of columns
	SELECT city, customer_name FROM customers_table WHERE country = 'US'
	UNION
	SELECT city, customer_name FROM suppliers_table WHERE country = 'CA'


-- CLEAR QUERY CACHE AND CACHED EXECUTION PLAN
CHECKPOINT;
GO 
DBCC DROPCLEANBUFFERS; -- this clears the query cache
GO 
DBCC FREEPROCCACHE; -- this cleras the execution plan cache
GO 


/* --------------------------------------------------------------------------------------- */
/* ------------------------------------------VIEWS---------------------------------------- */
/* --------------------------------------------------------------------------------------- */

VIEW: A view is just a saved SQL query, meaning it saves the syntax, it does not store any  
data, as such every time a view is run, the SQL server engine runs the query against the 
actual database and the database can even be updated by a view, however updating tables 
using view can have strange and unintended consequences

INDEXED VIEW (MATERIALIZED VIEW in some SQL DBs): When you create an index on a view, the view 
gets materialized and then the view can store data which by default does not store any data, 
indexed views are best used in OLAP systems, where the data only changes in batches often at 
particular times or schedules 

Views of any kind cannot take in parameters, for that one can define INLINE TABLE VALUED functions
or simply use the WHERE clause when calling the view

-- Create a View
	CREATE OR REPLACE VIEW ViewCustomersAndOrders
	AS
	SELECT 
		customer_name, product_name, price
	FROM 
		customers_table
	JOIN
		products_table
	ON
		customers_table.customer_id = products_table.customer_id

	-- Run the view: a view syntax is just like a table, that's why its called a 'virtual table'
	SELECT * FROM ViewCustomersAndOrders


-- Create an Indexed or Materialized View
	-- 1: Indexed view must be created with SCHEMABINDING
	-- 2: If any aggregate function such as SUM might have null values, then a replacement must
	--	  provided
	-- 3: If GROUP BY is specified, the SELECT clause must contain a COUNT_BIG(*) expression
	-- 4: The tables must be references with 'dbo.table_name'
	-- 5: Create a clustered index on the view which will then store the results of the query
	CREATE VIEW ViewSalesAndProducts
	WITH SCHEMABINDING
	AS 
	SELECT 
		products.product_id,
		products.product_name,
		SUM(ISNULL(sales.quantity_sold * products.product_price), 0) AS total_sales,
		COUNT_BIG(*) AS total_transactions
	FROM 
		dbo.sales_table AS sales 
	JOIN 
		dbo.products_table AS products
	ON
		sales.product_id = products.product_id
	GROUP BY
		product_name

	-- Create the index to materialize the view
	CREATE UNIQUE CLUSTERED INDEX UniqueClusIdxSalesAndProducts
	ON ViewSalesAndProducts(product_id)

-- See the actual syntax saved in the view
	EXECUTE sp_helptext ViewCustomersAndOrders

	-- Alter or drop a view
	ALTER VIEW ViewCustomersAndOrders
	DROP VIEW ViewCustomersAndOrders


/* --------------------------------------------------------------------------------------- */
/* ---------------------------------------END VIEWS--------------------------------------- */
/* --------------------------------------------------------------------------------------- */

-- GET THE SCHEMA FOR A TABLE
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'customers_table'


-- CASE STATEMENTS
	SELECT
		first_name,
		last_name,
		CASE
			WHEN city = 'New York' THEN 'NYC'
			ELSE 'Other'
		END AS NYC_or_Other
	FROM 
		customers_table


-- DECLARE VARIABLES
	DECLARE @int_var INT, @date_and_time_var DATETIME, @_date DATE
	SET @_date '2023-01-01'



/* --------------------------------------------------------------------------------------- */
/* -------------------------------------DATE AND TIME------------------------------------- */
/* --------------------------------------------------------------------------------------- */

-- EXTRACT DAY, MONTH OR YEAR FROM DATE TYPES
	SELECT 
		MONTH(date_column) AS month,
		DAY(date_column) AS day,
		YEAR(date_column) AS year,
		DATAPART(YEAR, date_column) AS year
	FROM 
		orders_table

	-- Filter by date
	SELECT *
	FROM orders_table
	WHERE purchase_data > '2023-01-01'


	-- Convert data type from DATE (YYYY-MM-DD) to DATETIME (YYYY-MM-DD HH:MM:SS.MS)
	SELECT 
		CAST(order_date AS DATETIME)
	FROM
		orders_table


	SELECT DATENAME(DAY, '2023-01-11 11:11:11.123') -- Returns 11
	SELECT DATENAME(WEEKDAY, '2023-01-11 11:11:11.123') -- Returns Sunday
	SELECT DATENAME(MONTH, '2023-01-11 11:11:11.123') -- Returns 01
	SELECT DATENAME(YEAR, '2023-01-11 11:11:11.123') -- Returns 2023


	-- Get difference in years
	SELECT DATADIFF(YEAR, '1999-01-01', GETDATE()) AS int_difference_in_years


/* --------------------------------------------------------------------------------------- */
/* -----------------------------------END DATE AND TIME----------------------------------- */
/* --------------------------------------------------------------------------------------- */

-- WORKING WITH STRINGS
	-- Concatinate string columns
	SELECT CONCAT(last_name, ', ', first_name)
	FROM customers_table

	-- Another way
	SELECT last_name + ', ' + first_name
	FROM customers_table

	-- Remove blanks from front and/or end of string
	SELECT TRIM(customer_name) -- LTRIM and RTRIM for left and right trimming
	FROM customers_table

	-- Substring, the SUBSTRING function starts at the third letter starting from 1, not 0
	-- and goes four letters to the right in this query
	SELECT customer_name, SUBSTRING(customer_name, 3, 4)
	FROM customers_table



-- DEFAULT CONSTRAINT FOR ADDING DEFAULT VALUES IN A COLUMN
-- If a column can contain null values, it may be best to substitute with a default
-- value in case no data is provided for an insert
	-- Add a default constraint for the column customer_type_column with 
	-- default value of 'business_customer', note: default won't kick in if null is 
	-- explicity provided during INSERT INTO statement
	ALTER TABLE customers_table
	ADD CONSTRAINT default_constraint_customer_type
	DEFAULT business_customer FOR customer_type_column


-- Replace null values
-- COALESCE() function can also be used
	SELECT
		customer_name,
		CASE
			WHEN customer_state IS NULL THEN 'state_unknown'
			ELSE customer_state
		END
	FROM 
		customers_table

-- Another way to replace null values
	SELECT 
		customer_name,
		ISNULL(customer_state, 'state_unknown')
	FROM 
		customers_table


-- COALESCE() function: it can be passed in arbitrary number of columns and it 
-- returns the first column value for each row which is not null and returns only one value
	SELECT
		COALESCE(column_name_1, column_name_2, column_name_3)
	FROM
		example_table


/* --------------------------------------------------------------------------------------- */
/* ----------------------------------STORED PROCEDURE------------------------------------- */
/* --------------------------------------------------------------------------------------- */


-- STORED PROCEDURES: A group of SQL statements that are saved, it can return either any number
-- of PARAMETERS and types or a single RETURN value which is integer, stored procedures by default 
-- return 0 for success and 1 for failed query as its return value, RETURN values are generally
-- used to convey success or failure


When a query is issued to SQL Server, three steps take place to execute the query:
1 - The engine checks the syntax of the query
2 - Compilation of the query
3 - Generates the execution plan
	- The execution plan is what determines the most efficient steps to execute the query
	  taking into account indexes and optimizations that can be made, this is where the
	  advantage of a STORED PROCEDURE comes in, STORED PROCEDURES save the execution plan
	  indepently of inputs, so different inputs can be passed to the STORED PROCEDURE and 
	  the same execution plan is used, ad-hoc queries also cache the execution plan but even 
	  a small change renders the cached plan useless


	-- CREATE PROC also works
	CREATE PROCEDURE StoredProcedureGetEmployee
	@department_id INT = NULL -- Input with default values NULL
	@gender VARCHAR(10) = NULL -- Input
	@employee_count INT OUTPUT -- Output
	-- WITH ENCRYPTION -- This encrypts the text definition of this stored procedure
	AS 
	BEGIN
		SELECT @employee_count = COUNT(*)
		FROM employees_table 
		WHERE 
			(department_id = @department_id OR @department_id IS NULL) AND 
			(gender = @gender OR @gender IS NULL)
	END

	-- Execute a stored procedure with no output
	EXECUTE StoredProcedureGetEmployee @department_id = 1, @gender = 'Male'

	-- Execute a stored procedure with an output
	DECLARE @employee_count INT
	EXECUTE StoredProcedureGetEmployee @department_id = 1, @gender = 'Male', @employee_count OUTPUT
	PRINT @employee_count

	-- View the definition of a stored procedure
	-- The sp_ prefix is a convention to show that this is a system stored procedure
	sp_helptext StoredProcedureGetEmployee

	-- Find the dependencies of the stored procedure
	sp_depends StoredProcedureGetEmployee

	-- Alter a stored procedure
	ALTER PROCEDURE StoredProcedureGetEmployee 
	-- rest is same syntax as creating the stored procedure

	-- Drop a stored procedure
	DROP PROCEDURE StoredProcedureGetEmployee


	-- Stored Procedure with a return value
	CREATE PROCEDURE StoredProcedureGetNumEmployees
	@employee_id
	AS
	BEGIN
		RETURN (SELECT COUNT(*) FROM employees_table)
	END 

	DECLARE @num_employees INT 
	EXECUTE @num_employees = StoredProcedureGetNumEmployees @employee_id = 1
	PRINT 'Number of employees: ' + @num_employees


/* --------------------------------------------------------------------------------------- */
/* --------------------------------END STORED PROCEDURE----------------------------------- */
/* --------------------------------------------------------------------------------------- */


/* --------------------------------------------------------------------------------------- */
/* -------------------------------USER DEFINED FUNCTIONS---------------------------------- */
/* --------------------------------------------------------------------------------------- */


- There are three types of UDFs in SQL:
1 - SCALR functions: returns only a single scalar value of any type
2 - INLINE TABLE VALUED functions: returns a table, the SQL engine treats these much like
	a parameterized view and hence this option is faster than MULTI-STATEMENT, also its possible
	to update the underlying table with this function
3 - MULTI-STATEMENT TABLE VALUED functions: returns a table, the SQL engine treats these much 
	like STORED PROCEDURES, that is why these are slower than INLINE TABLE VALUED, not possible to
	update the underlying table with this function


Difference between UDFs and STORED PROCEDUREs:
- A UDF can be used inside a query in SELECT and WHERE clauses, a STORED PROCEDURE cannot 
be used that way
- STORED PROCEDUREs must be run with the EXECUTE clause


-- Syntax for creating a SCALAR UDF, see example below in CALCULATE AGE section
	CREATE FUNCTION FunctionName(@input_1 data_type, @input_2 data_type, ...)
	RETURNS return_data_type
	-- WITH ENCRYPTION -- this hides the function definition
	WITH SCHEMABINDING -- this prevents deletion and such changes to the underlying
					   -- table in the query, requires name: 'dbo.table_name'
	AS 
	BEGIN
		-- function body

		@output_var return_data_type
		... 
		SET @output_var = ...

		RETURN @output_var
	END 

	-- Running a SCALAR UDF in a table query
	SELECT column_name_1, dbo.FunctionName(column_name_3) FROM example_table	

-- Syntax for creating an INLINE TABLE VALUED UDF
	-- There is no BEGIN and END block
	CREATE FUNCTION FunctionEmployeesByGender(@gender VARCHAR(10))
	RETURNS TABLE
	AS 
	RETURN (
		SELECT employee_id, employee_name, department_id
		FROM employees_table
		WHERE gender = @gender
	)

	-- Running an INLINE TABLE VALUED UDF
	-- This type of function can be queried like any table
	SELECT * FROM dbo.FunctionEmployeesByGender('Male') WHERE department_id = 1


-- Syntax for creating a MULTI-STATEMENT TABLE VALUED UDF
	CREATE FUNCTION FunctionGetEmployeeInfo()
	RETURNS @_table TABLE (employee_id INT, employee_name VARCHAR(15), department_id INT)
	AS 
	BEGIN 
		INSERT INTO @_table
		SELECT employee_id, employee_name, department_id FROM example_table
	END 

-- Alter function and drop function
	ALTER FUNCTION FunctionName(...) ... -- Rest of syntax same as CREATE FUNCTION
	DROP FUNCTION FunctionName

/* --------------------------------------------------------------------------------------- */
/* -----------------------------END USER DEFINED FUNCTIONS-------------------------------- */
/* --------------------------------------------------------------------------------------- */


/* --------------------------------------------------------------------------------------- */
/* ------------------------------------CALCULATE AGE-------------------------------------- */
/* --------------------------------------------------------------------------------------- */

-- Create a UDF to return age in years, months, and days

	CREATE FUNCTION FunctionComputeAge(@date_of_birth DATETIME)
	RETURNS VARCHAR(50)
	AS 
	BEGIN

		DECLARE @temp_date DATETIME, @years INT, @months INT, @days INT

		-- First get the year, the CASE statement subtracts either a 1 or a 0 because
		-- 2022-12-31 subtracted from 2023-01-01 returns 1 year of difference, when actually
		-- the real difference is one day, so CASE statement will subtract 1 in this situation

		SELECT @temp_date = @date_of_birth

		SELECT @years = DATEDIFF(YEAR, @temp_date, GETDATE()) - 
					 	CASE 
					 		WHEN (MONTH(@temp_date) > MONTH(GETDATE())) OR 
					 			 (
					 			 	MONTH(@temp_date) = MONTH(GETDATE()) AND 
					 			  	DAY(@temp_date) > DAY(GETDATE())
					 			  )
					 		THEN 1
					 	ELSE
					 		0
					 	END

		SELECT @temp_date = DATEADD(YEAR, @years, @temp_date)

		-- Same logic of subtracting a month off as before with the year
		SELECT @months = DATEDIFF(MONTH, @temp_date, GETDATE()) - 
					 	 CASE 
					 	 	WHEN DAY(@temp_date) > DAY(GETDATE()) THEN 1
					 	 ELSE 
					 	 	0
					 	 END

		SELECT @temp_date = DATEADD(MONTH, @months, @temp_date)

		SELECT @days = DATEDIFF(DAY, @temp_date, GETDATE())

		DECLARE @age VARCHAR(50)
		SET @age = CAST(@years AS VARCHAR(4)) + ' Years ' + 
				   CAST(@months AS VARCHAR(2)) + ' Months and ' + 
				   CAST(@days AS VARCHAR(2)) + ' Days Old'
		RETURN @age
	END

	-- Add an extra column of age by calling the function for computing age
	SELECT 
		employee_name, 
		date_of_birth, 
		dbo.FunctionComputeAge(date_of_birth) AS age
	FROM 
		employees_table

/* --------------------------------------------------------------------------------------- */
/* ----------------------------------END CALCULATE AGE------------------------------------ */
/* --------------------------------------------------------------------------------------- */



/* --------------------------------------------------------------------------------------- */
/* ---------------------------------------INDEXES----------------------------------------- */
/* --------------------------------------------------------------------------------------- */

There are two types of indexes in SQL:
1 - Clustered Index: This index determines the physical order in which the data is stored
	and for this reason, a table can only have one clustered index. This index is similar 
	to a phone book, where the data and index are both stored in the same location. The 
	PRIMARY KEY constraint automatically creates a clustered index on the column with 
	PRIMARY KEY, however the clustered index can be created on multiple columns
2 - Nonclustered Index: This index is stored separately from the data and is similar the index 
	at the end of a book or table of contents at the beginning of a book. The data and the 
	index are stored separately and for this reason a a table can have multiple nonclustered 
	indexes. But this index also require more space.


-- Syntax for creating a clustered index
	CREATE CLUSTERED INDEX index_name 
	ON table_name (column_name ASC)
	-- ON table_name (column_name_1 DESC, column_name_2 ASC) -- clustered index on multiple columns

-- Syntax for creating a unique nonclustered index
	CREATE UNIQUE NONCLUSTERED INDEX index_name
	ON example_table (column_name_1 ASC)

-- Drop index
	DROP INDEX example_table.IndexExampleTableIdx

-- Find all the indexes for a specific table
	EXECUTE sp_Helpindex example_table

/* --------------------------------------------------------------------------------------- */
/* -------------------------------------END INDEXES--------------------------------------- */
/* --------------------------------------------------------------------------------------- */


/* --------------------------------------------------------------------------------------- */
/* ---------------------------------------TRIGGERS---------------------------------------- */
/* --------------------------------------------------------------------------------------- */

Triggers can be considered special STORED PROCEDUREs.  Triggers are executed automatically
in reponse to various types of events. In SQL server, there are three kinds of triggers:
1: Data Manipulation Language (DML) Triggers - These triggers are fired automatically in 
   response to DML events (INSERT, UPDATE, DELETE), they can be classified in to two types:
	1 - AFTER Triggers: These fire after DML(INSERT, UPDATE, DELETE) statements complete execution
	2 - INSTEAD OF Triggers: These triggers fire instead of DML(INSERT, UPDATE, DELETE) statements,
		these are useful when updating the underlying tables using views
2: (DDl) Triggers 
3: LOGON Triggers


-- Create DML AFTER Trigger for the INSERT action
	-- Problem: After a new record is stored in the employee_table, insert a record in the
	-- employee_audit_table
	CREATE TRIGGER Trigger_Employee_Insert
	ON employees_table
	FOR INSERT  -- the trigger is for INSERT action
	AS 
	BEGIN
		DECLARE @employee_id INT 
		-- The 'INSERTED' table is a table the SQL engine creates in memory specifically for
		-- triggers, and its only available within the context of a triggle, this in memory
		-- table contains the row(s) to which data was added
		SELECT @employee_id = employee_id FROM INSERTED
		INSERT INTO example_audit_table 
			(
				employee_id, 
				description
			)
		VALUES 
			(
				@employee_id,
				'New employee with ID = ' + CAST(@employee_id AS VARCHAR(5))
			)
	END

-- Create DML AFTER Trigger for the DELETE action
	-- Problem: After a record is deleted in the employee_table, delete a record in the
	-- employee_audit_table with the same employee_id
	CREATE TRIGGER Trigger_Employee_Delete
	ON employees_table
	FOR DELETE  -- the trigger is for DELETE action
	AS 
	BEGIN
		DECLARE @employee_id INT 
		-- The 'DELETED' table is a table the SQL engine creates in memory specifically for
		-- triggers, and its only available within the context of a triggle, this in memory
		-- table contains the row(s) which were deleted
		SELECT @employee_id = employee_id FROM DELETED
		DELETE FROM example_audit_table 
		WHERE employee_id = @employee_id
	END

-- DML AFTER Trigger for the UPDATE action makes use of both in memory tables created during
-- triggers, the INSERTED and DELETED tables


-- Create DML INSTEAD OF Trigger for the INSERT action
	-- Problem: Correctly update the underlying tables of view, INSTEAD OF updatign the view 
	-- itself which either throws an error or might have incorrect or undesired result
	CREATE TRIGGER Trigger_InsteadOf_View_Employee_Details
	ON View_Employee_Details -- on this table
	INSTEAD OF INSERT
	AS
	BEGIN
		DECLARE @department_id INT
		-- First verify that input is correct and conforms to schema
		SELECT @department_id = department_id
		FROM department_table
		JOIN INSERTED	-- in memory table for triggers
		ON department_table.department_name = INSERTED.department_name

		-- If department_id is null, throw error
		IF (@department_id IS NULL)
		BEGIN 
			RAISERROR('Invalid department name, statement terminated', 16, 1)
			RETURN
		END 

		-- Now update underlying table after verify correct information
		INSERT INTO employees_table (employee_id, employee_name, gender, department_id)
		SELECT department_id, employee_name, gender, @department_id
		FROM INSERTED 
	END 

-- Create a DML INSTEAD OF Trigger for the UPDATE action
	CREATE TRIGGER Trigger_InsteadOf_View_Employee_Details
	ON View_Employee_Details -- on this table
	INSTEAD OF UPDATE
	AS 
	BEGIN 
		-- First verify correctness of the update using the SQL UPDATE() function
		IF (UPDATE(department_id))
		BEGIN 
			RAISERROR('Department ID cannot be changed', 16, 1)
			RETURN 
		END

		IF (UPDATE(department_name))
		BEGIN 
			DECLARE @department_id INT 
		
			SELECT @department_id = department_id
			FROM department_table
			JOIN INSERTED
			ON department_table.department_name = INSERTED.department_name
		END 

		IF (@department_id IS NULL)
		BEGIN 
			RAISERROR('Invalid department name', 16, 1)
			RETURN
		END 

		UPDATE employees_table 
		SET department_id = @department_id
		FROM INSERTED
		JOIN employees_table
		ON employees_table.employee_id = INSERTED.employee_id
	END 


/* --------------------------------------------------------------------------------------- */
/* -------------------------------------END TRIGGERS-------------------------------------- */
/* --------------------------------------------------------------------------------------- */


/* --------------------------------------------------------------------------------------- */
/* -------------------------------COMMON TABLE EXPRESSIONS-------------------------------- */
/* --------------------------------------------------------------------------------------- */

A CTE is a temporary in memory result of a query which is specified in the 'AS' block, if the
CTE is based on multiple base tables, only one underlying table can be updated using a CTE, 
but much like views, the update can have unintended consequences

-- Syntax for creating a CTE
	WITH name_of_common_table_expression (column_name_1, column_name_2)
	AS (
		SELECT column_name_1, column_name_2 FROM example_table
	)
	SELECT column_name_1, column_name_2 FROM name_of_common_table_expression


-- Updating a table using a CTE
	WITH name_of_common_table_expression (column_name_1, column_name_2)
	AS (
		SELECT column_name_1, column_name_2 FROM example_table
	)
	UPDATE name_of_common_table_expression
	SET column_name_1 = 'example'
	WHERE column_name_2 = 1


/* --------------------------------------------------------------------------------------- */
/* ------------------------------END COMMON TABLE EXPRESSIONS----------------------------- */
/* --------------------------------------------------------------------------------------- */



/* --------------------------------------------------------------------------------------- */
/* ------------------------------------PIVOT OPERATOR------------------------------------- */
/* --------------------------------------------------------------------------------------- */

A pivot operator is a SQL Server operator that can be used to turn unique values from a 
column in one table into multiple columns in a new table, effectively transposing a table.
The number of unique row values become columns in the new table.

-- Problem: In the sales_table, there are countries and sales_agent along with sales_generated,
-- turn the unique countries in sales_table to columns in the pivot table, note: pivot table 
-- does not work if there are additional columns not used in the pivot table, 
-- hence, a derived table is used to get only the desired columns
	SELECT sales_agent, US, UK, CA 
	FROM (
		SELECT sales_agent, country, sales_generated
		FROM sales_table
	) AS derived_table
	PIVOT (
		SUM(sales_generated) FOR country in ([US], [UK], [CA])
	) AS pivot_table

/* --------------------------------------------------------------------------------------- */
/* ----------------------------------END PIVOT OPERATOR----------------------------------- */
/* --------------------------------------------------------------------------------------- */



/* --------------------------------------------------------------------------------------- */
/* -------------------------------------TRANSACTIONS-------------------------------------- */
/* --------------------------------------------------------------------------------------- */

A transaction is an atomic group of commands that make changes to the database, e.g. CRUD
commands. Atomic here means, that either all commands succeed or they all fail. This ensures
integrity in ACID.

-- Create store procedure with transactions
	CREATE PROCEDURE StoredProcedureUpdateEmployee
	AS 
	BEGIN 

		BEGIN TRY 
			UPDATE employees_table
			SET department_name = 'Engineering'
			WHERE department_id = 1

			UPDATE employees_audit_table
			SET department_name = 'Engineering'
			WHERE department_id = 1
		END TRY 

		BEGIN CATCH 
			ROLLBACK TRANSACTION
		END CATCH 
	END 


/* --------------------------------------------------------------------------------------- */
/* -----------------------------------END TRANSACTIONS------------------------------------ */
/* --------------------------------------------------------------------------------------- */



/* --------------------------------------------------------------------------------------- */
/* --------------------------------------PERFORMANCE-------------------------------------- */
/* --------------------------------------------------------------------------------------- */

JOINS VS SUBQUERIES: Which is faster or more efficient?
In principal, if the subquery is uncorrelated with the outer query, then joins and subqueries,
should have roughly the same performance.  But if the subquery is correlated with the outer
query, then joins run faster.  In reality, it all depends on the execution plan that the SQL
Server engine generates, but generally, joins are faster. Best option is to to turn on SQL Server
client statistics and execution plan to see the performance of each option to see which is better.

/* --------------------------------------------------------------------------------------- */
/* ------------------------------------END PERFORMANCE------------------------------------ */
/* --------------------------------------------------------------------------------------- */


/* --------------------------------------------------------------------------------------- */
/* -----------------------------------WINDOW FUNCTIONS------------------------------------ */
/* --------------------------------------------------------------------------------------- */

Window functions are functions over "windows" of a table.  These functions are largely used
for analytics purposes.  The functions fall in to three general categories:
1: Aggregate functions - AVG, SUM, COUNT, MIN, MAX, etc.
2: Ranking functions - RANK, DENSE_RANK, ROW_NUMBER, etc.
3: Analytics functions - LEAD, LAG, FIRST_VALUE, LAST_VALUE, etc.
The OVER() clause defines the "window", it accepts three possible arguments: 
	ORDER BY: 		defines the logical order of the rows
	PARTITION BY: 	divides the query result in to partitions and the window function is applied 
				  	to each partition separately
	ROWS/RANGE: 	limits the rows within the partition by specifying the start and end points
			    	within a partition


Problem: Calculate the running total for a sales column which returns a table containing 
the total sales so far for each row
	-- This query sorts the output by the sales_generated column and attaches another column
	-- which calculates the running total so far
	SELECT 
		quantity_sold, 
		customer_name,
		SUM(sales_generated) OVER (
			ORDER BY sales_generated
		) AS total_sales_so_far
	FROM 
		sales_table

Problem: Calculate the running total for a sales column for each day which returns a table
containing the total sales so far for each day
	-- This query sorts the output by the primary key id column, partitions the data by the 
	-- date column and attaches another column which creates paritions of the table by date, 
	-- calculates the running total so far for each date
	SELECT 
		product_id,
		sale_date,
		sales_generated,
		SUM(sales_generated) OVER(
			PARTITION BY sale_date
			ORDER BY product_id
		) AS total_sales_so_far
	FROM 
		sales_table


ROW_NUMBER(): This function is used for ordering data
Problem: Rank each sales record (each row) starting from 1 to n for each day, if there are
10 sales made in one day, then the first row will have 1, and the second 2, and so on until 
the tenth row which will have 10 and then the ranking will start all over again for the next day.
	SELECT 
		product_id,
		sale_date, 
		ROW_NUMBER() OVER(
			PARTITION BY sale_date 
			ORDER BY product_id
		) AS _rank_for_each_day
	FROM 
		sales_table


RANK(): This function is used for ranking data
Difference between RANK() AND DENSE_RANK(): If two rows have the same "ranking" (same salary
in this example), then both functions will assign it the same rank, but for the next row,
RANK() will skip a number (such as 1, 1, 3) but DENSE_RANK() will not (such as 1, 1, 2)
Problem: Rank the employees by highest salary to lowest salary in each department
	SELECT
		employee_id,
		employee_name,
		department_name,
		salary,
		RANK() OVER(
			PARTITION BY department_name
			ORDER BY salary DESC
		) AS _rank 
	FROM
		employees_table


/* --------------------------------------------------------------------------------------- */
/* ---------------------------------END WINDOW FUNCTIONS---------------------------------- */
/* --------------------------------------------------------------------------------------- */