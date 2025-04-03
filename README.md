# SQL practice
Practice run queries
# In Class Activity 1
* Create table statement that creates a table called students that has the following columns.
* Use a natural key as the primary key. It will need to be a composite key.
![Image](https://github.com/user-attachments/assets/015eef57-921e-45b4-9101-b8034a7b41ac)

# Join tables practice
* Run queries to join table from a list of item below:
* order_id int, order_date date, cust_id int, cust_name text, cust_state text, item_id text, item_desc text, item_quant text, item_price text, value text, primary key(order_id)
* normalization_sample.sql
SELECT o.order_id, o.order_date, c.cust_id,c.cust_name,i.item_id,i.item_desc,oi.item_quant,oi.price_paid, oi.value FROM normalization_activity.orders o JOIN normalization_activity.customers c ON o.cust_id = c.cust_id JOIN normalization_activity.order_items oi ON o.order_id = oi.order_id JOIN normalization_activity.items i ON oi.item_id = i.item_id ORDER BY o.order_date,c.cust_id,o.order_id;
![Image](https://github.com/user-attachments/assets/6dea619c-2b45-4e52-8d34-2dba1ea5e466)

I want to contact our most important customers and thank them for their business and ask how we can strengthen our relationship. I want to see a list of each customer and how much each customer has ordered.
SELECT c.cust_name,SUM(oi.value) AS cust_value FROM normalization_activity.customers c JOIN normalization_activity.orders o ON c.cust_id = o.cust_id JOIN normalization_activity.order_items oi ON o.order_id = oi.order_id GROUP BY c.cust_name ORDER BY cust_value DESC;
![3](https://github.com/user-attachments/assets/54397ed8-aaa5-41ff-a57a-247031ff299d)

Some items are more important to be sure we have enough in inventory. I want to see what items have the greatest value, how many are ordered, how many times they are ordered, and what is the value of that item.
SELECT i.item_id, i.item_desc, SUM(oi.item_quant) AS units_ordered, SUM(oi.value) AS value, COUNT(oi.order_id) AS times_ordered FROM normalization_activity.items i JOIN normalization_activity.order_items oi ON i.item_id = oi.item_id GROUP BY i.item_id, i.item_desc ORDER BY value DESC;

![9](https://github.com/user-attachments/assets/b909eb55-6f22-4979-9f67-1e4a74f51226)
