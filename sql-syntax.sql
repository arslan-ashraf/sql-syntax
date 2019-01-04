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