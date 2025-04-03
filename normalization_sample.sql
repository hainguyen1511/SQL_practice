drop schema if exists normalization_activity cascade;

-- question 1
create schema if not exists normalization_activity ;


-- drop table if exists normalization_activity.cust_orders;
/*
create table normalization_activity.cust_orders (
	order_id int
	, order_date date
	, cust_id int
	, cust_name text
	, cust_state text
	, item_id text
	, item_desc text
	, item_quant text
	, item_price text
	, value text
	, primary key(order_id)
);

insert into normalization_activity.cust_orders 
	(order_id, order_date, cust_id, cust_name, cust_state, item_id, item_desc, item_quant, item_price, value)
values
	(1001, '10/13/2023', 1004, 'Mo', 'OR', '6531,7814,2305', 'Tape,Paper,Pens', '4,5,12', '2.00,10.00,6.00', '8.00,50.00,72.00')
	, (1002, '10/12/2023', 2005, 'Larry', 'CA', '7814,7301', 'Paper,Erasers', '10,5', '10.00,1.00', '100.00,5.00')
	, (1003, '10/17/2023', 3006, 'Curly', 'WA', '4234,2305', 'Pencils,Pens', '12,9', '6.00,6.00', '72.00,54.00')
	, (1004, '10/19/2023', 1004, 'Mo', 'OR', '6531,2305', 'Tape,Pens', '5,9', '2.00,6.00', '10.00,54.00')
;
*/
-- select * from normalization_activity.cust_orders;

-- drop table normalization_activity.states cascade;

create table normalization_activity.states (
	state_id int primary key generated always as identity
	, state_abbrev text not null unique
	, state_name text not null unique
);

-- drop table normalization_activity.customers cascade;

create table normalization_activity.customers (
	cust_id int primary key -- generated always as identity
	, cust_name text not null
	, state_id int references normalization_activity.states (state_id)
);

-- drop table normalization_activity.orders cascade;

create table normalization_activity.orders (
	order_id int primary key -- generated always as identity
	, order_date date not null
	, cust_id int references normalization_activity.customers (cust_id)
);

-- drop table normalization_activity.items cascade ;

create table normalization_activity.items (
	item_id int primary key -- generated always as identity
	, item_desc text not null
	, item_price real default 0 not null
);

-- drop table normalization_activity.order_items;

create table normalization_activity.order_items (
	order_id int references normalization_activity.orders (order_id)
	, item_id int references normalization_activity.items (item_id)
	, item_quant int
	, price_paid real
	, item_order int
	, value real generated always as (item_quant * price_paid) stored
	, constraint order_items_pk primary key (order_id, item_id)
);

insert into normalization_activity.states 
	(state_abbrev, state_name)
values
	('OR', 'Oregon')
	, ('CA', 'California')
	, ('WA', 'Washington')
	, ('NV', 'Nevada')
	, ('ID', 'Idaho')
;

insert into normalization_activity.customers 
	(cust_id, cust_name, state_id)
values
	(1004, 'Mo', 1)
	, (2005, 'Larry', 2)
	, (3006, 'Curly', 3)
    , (4007, 'Laurel', 1)
    , (4008, 'Hardy', 1)
    , (5001, 'Bert', 2)
    , (5002, 'Ernie', 2)
    , (6001, 'Burns', 2)
    , (6002, 'Allen', 2)
;

insert into normalization_activity.items 
	(item_id, item_desc, item_price)
values
	(6531, 'Tape', 2)
	, (7814, 'Paper', 10)
	, (2305, 'Pens', 6)
	, (7301, 'Erasers', 1)
	, (4234, 'Pencils', 6)
	, (7302, 'Trash can', 15)
	, (4235, 'Index cards', 3)
	, (4236, 'Post-it notes', 7)
	, (4237, 'Scissors', 12)
;

insert into normalization_activity.orders 
	(order_id, order_date, cust_id)
values
	(1001, '10/13/2023', 1004)
	, (1002, '10/12/2023', 2005)
	, (1003, '10/17/2023', 3006)
	, (1004, '10/19/2023', 1004)
;

insert into normalization_activity.order_items 
	(order_id, item_id, item_quant, price_paid, item_order)
values
	(1001, 6531, 4, 2, 1)
	, (1001,7814, 5, 10, 2)
	, (1001, 2305, 12, 6, 3)
	, (1002, 7814, 10, 10, 1)
	, (1002, 7301, 5, 1, 2)
	, (1003, 4234, 12, 6, 1)
	, (1003, 2305, 9, 2, 2)
	, (1004, 6531, 5, 2, 1)
	, (1004, 2305, 9, 6, 2)
;

SELECT o.order_id, o.order_date, c.cust_id,c.cust_name,i.item_id,i.item_desc,oi.item_quant,oi.price_paid, oi.value
FROM normalization_activity.orders o
JOIN normalization_activity.customers c ON o.cust_id = c.cust_id
JOIN normalization_activity.order_items oi ON o.order_id = oi.order_id
JOIN normalization_activity.items i ON oi.item_id = i.item_id
ORDER BY o.order_date,c.cust_id,o.order_id;

SELECT c.cust_name,o.order_id,o.order_date,SUM(oi.value) AS order_value
FROM normalization_activity.customers c
JOIN normalization_activity.orders o ON c.cust_id = o.cust_id
JOIN normalization_activity.order_items oi ON o.order_id = oi.order_id
GROUP BY c.cust_name, o.order_id, o.order_date
ORDER BY o.order_date;

SELECT c.cust_name,SUM(oi.value) AS cust_value
FROM normalization_activity.customers c
JOIN normalization_activity.orders o ON c.cust_id = o.cust_id
JOIN normalization_activity.order_items oi ON o.order_id = oi.order_id
GROUP BY c.cust_name
ORDER BY cust_value DESC;

SELECT s.state_abbrev, SUM(oi.value) AS state_value
FROM normalization_activity.states s
JOIN normalization_activity.customers c ON s.state_id = c.state_id
JOIN normalization_activity.orders o ON c.cust_id = o.cust_id
JOIN normalization_activity.order_items oi ON o.order_id = oi.order_id
GROUP BY s.state_abbrev
ORDER BY state_value DESC;

SELECT i.item_id, i.item_desc, SUM(oi.item_quant) AS units_ordered, SUM(oi.value) AS value, COUNT(oi.order_id) AS times_ordered
FROM normalization_activity.items i
JOIN normalization_activity.order_items oi ON i.item_id = oi.item_id
GROUP BY i.item_id, i.item_desc
ORDER BY value DESC;

SELECT s.state_abbrev, s.state_name
FROM normalization_activity.states s
LEFT JOIN normalization_activity.customers c ON s.state_id = c.state_id
WHERE c.cust_id IS NULL;

SELECT i.item_id, i.item_desc, i.item_price
FROM normalization_activity.items i
LEFT JOIN normalization_activity.order_items oi ON i.item_id = oi.item_id
WHERE oi.order_id IS NULL;

SELECT s.state_abbrev, s.state_name, c.cust_name
FROM normalization_activity.states s
JOIN normalization_activity.customers c ON s.state_id = c.state_id
LEFT JOIN normalization_activity.orders o ON c.cust_id = o.cust_id
WHERE o.order_id IS NULL
