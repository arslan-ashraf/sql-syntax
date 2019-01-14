-- create table
	create table table_name_foo (
		id int not null primary key auto_increment,
		firstname char(255),
		last_name varchar(255),
		info text,
		created_at DATE,  -- yyyy-mm-dd
		updated_at DATETIME,  -- yyyy-mm-dd hh:mm:ss
		bar_id int,
		foreign key (bar_id) references table_name_bar(id)
		-- PRIMARY KEY (id) also acceptable 
		-- contraint PK_table_name_foo PRIMARY KEY (id) => in sql server
		-- bar_id int foreign key references table_name_bar(id) => sql server
	)

-- insert into table
	insert into table_name_foo values ()

-- alter table
	alter table table_name_foo 
	drop 
	primary key;  -- drop contraint PK_table_name_foo => in sql server

	alter table table_name_foo 
	add -- add contraint PK_table_name_foo => sql server
	primary key (id);



select * from table_name;

-- writing queries
select column_name_1, column_name_2, column_name_3 from table_name_foo;

-- queries with conditions
select column_name_1 from table_name_foo where column_name_1 > number_value -- proper type comparisons only
-- where clause with unknown string values comparison
where column_name_1 like "%string%"
-- where clause with multiple comparison values
where column_name_1 in (list of values or table from subquery)
other conditions
between, wildcards

-- joins
select a.column_name_1, b.column_name_2 
from table_name_foo as a join table_name_bar as b
on a.id = b.column_name_1.id 
left join - everything from left and only matching columns from right 
right join - same as left except all right and only matching left

-- unions
select a.column_name_1, ... from table_name_foo as a
union -- same number of column names
select b.column_name_2, ... from table_name_bar as b

create index
create index index_name on table_name (column_name_1)

common table expressions

create views
create view view_name as 
select column_name_1, column_name_2, column_name_3, ...
from table_name
where condition = ?	

-- create store procedure
create procedure sp_store_procedure_name @variable int
as
begin
sql_query go
end;

execute sp_store_procedure_name;

-- create function
create function fn_function_name @variable int, @variable_str char(50)
returns int 
as
begin
sql_query
end

-- execute fn_function_name(number, 'string')