# SQL practice
Practice run queries
# In Class Activity 1
* Create table statement that creates a table called students that has the following columns.
* Use a natural key as the primary key. It will need to be a composite key.
![Image](https://github.com/user-attachments/assets/015eef57-921e-45b4-9101-b8034a7b41ac)

# Join tables practice
* Run normalization_sample.sql and create queries to join table from a list of item below:
* order_id int, order_date date, cust_id int, cust_name text, cust_state text, item_id text, item_desc text, item_quant text, item_price text, value text, primary key(order_id)
> `SELECT o.order_id, o.order_date, c.cust_id,c.cust_name,i.item_id,i.item_desc,oi.item_quant,oi.price_paid, oi.value FROM normalization_activity.orders o JOIN normalization_activity.customers c ON o.cust_id = c.cust_id JOIN normalization_activity.order_items oi ON o.order_id = oi.order_id JOIN normalization_activity.items i ON oi.item_id = i.item_id ORDER BY o.order_date,c.cust_id,o.order_id;`

![Image](https://github.com/user-attachments/assets/6dea619c-2b45-4e52-8d34-2dba1ea5e466)

* I want to contact our most important customers and thank them for their business and ask how we can strengthen our relationship. I want to see a list of each customer and how much each customer has ordered.
> `SELECT c.cust_name,SUM(oi.value) AS cust_value FROM normalization_activity.customers c JOIN normalization_activity.orders o ON c.cust_id = o.cust_id JOIN normalization_activity.order_items oi ON o.order_id = oi.order_id GROUP BY c.cust_name ORDER BY cust_value DESC;`

![3](https://github.com/user-attachments/assets/54397ed8-aaa5-41ff-a57a-247031ff299d)

* Some items are more important to be sure we have enough in inventory. I want to see what items have the greatest value, how many are ordered, how many times they are ordered, and what is the value of that item.
> `SELECT i.item_id, i.item_desc, SUM(oi.item_quant) AS units_ordered, SUM(oi.value) AS value, COUNT(oi.order_id) AS times_ordered FROM normalization_activity.items i JOIN normalization_activity.order_items oi ON i.item_id = oi.item_id GROUP BY i.item_id, i.item_desc ORDER BY value DESC;`

![9](https://github.com/user-attachments/assets/b909eb55-6f22-4979-9f67-1e4a74f51226)

# Practice Trigger
* A trigger is a specification that the database should
automatically execute a particular function whenever a
certain type of operation is performed.
Triggers can be attached to tables, views, and foreign
tables.
![1](https://github.com/user-attachments/assets/959ebb84-55a7-4a87-bf86-9b497d8d74f2)

> `CREATE OR REPLACE PROCEDURE triggers.register1(
    IN p_student_id INT,
    IN p_class_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO triggers.registrations (student_id, class_id)
    VALUES (p_student_id, p_class_id);
END;
$$;`

* Write a select statement that will show all the students and the classes to which they are registered. The output should look as below. Order the rows by gname, fname, and class_name.

> `SELECT
    s.gname AS First_Name,
    s.fname AS Last_Name,
    c.class_name AS Class_Name,
    c.class_credits AS Class_Credits
FROM
    triggers.students s
JOIN
    triggers.registrations r ON s.student_id = r.student_id
JOIN
    triggers.classes c ON r.class_id = c.class_id
ORDER BY
    s.gname, s.fname, c.class_name, c.class_credits;`

* Create a new view called triggers.student_classes that uses the same query as you wrote above.
`CREATE OR REPLACE VIEW triggers.student_classes AS
SELECT s.gname AS First_Name, s.fname AS Last_Name, c.class_name AS Class_Name, c.class_credits AS Class_Credits
FROM triggers.students s
JOIN triggers.registrations r ON s.student_id = r.student_id
JOIN triggers.classes c ON r.class_id = c.class_id
ORDER BY s.gname, s.fname, c.class_name, c.class_credits;`

*	Write a function called triggers.student_classes_func1 that returns a table
utilizing the command `select * from triggers.student_classes_func1(1);`
`CREATE OR REPLACE FUNCTION triggers.student_classes_func1(p_student_id INT)
RETURNS TABLE (
    gname TEXT,
    fname TEXT,
    class_name TEXT,
    class_credits INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.gname,
        s.fname,
        c.class_name,
        c.class_credits
    FROM
        triggers.students s
    JOIN
        triggers.registrations r ON s.student_id = r.student_id
    JOIN
        triggers.classes c ON r.class_id = c.class_id
    WHERE
        s.student_id = p_student_id;
END;
$$ LANGUAGE plpgsql;`

* Write a function called triggers.student_credits_func1 that returns a table that takes a single parameter. If the value of the parameter is zero, it shows the total credits for all students. If the value of the parameter is non-zero, if shows the total credits for the given student_id. Utilizing the command:
`select * from triggers.student_credits_func1(2);
select * from triggers.student_credits_func1(triggers.get_student_id('Jesse', 'Chaney'));
select * from triggers.student_credits_func1(0);`

`CREATE OR REPLACE FUNCTION triggers.student_credits_func1(p_student_id INT)
RETURNS TABLE (
    gname TEXT,
    fname TEXT,
    total_credits INT
) AS $$
BEGIN
    IF p_student_id = 0 THEN
        RETURN QUERY
        SELECT
            s.gname,
            s.fname,
            SUM(c.class_credits)::INT AS total_credits
        FROM
            triggers.students s
        JOIN
            triggers.registrations r ON s.student_id = r.student_id
        JOIN
            triggers.classes c ON r.class_id = c.class_id
        GROUP BY
            s.gname, s.fname;
    ELSE
        RETURN QUERY
        SELECT
            s.gname,
            s.fname,
            SUM(c.class_credits)::INT AS total_credits
        FROM
            triggers.students s
        JOIN
            triggers.registrations r ON s.student_id = r.student_id
        JOIN
            triggers.classes c ON r.class_id = c.class_id
        WHERE
            s.student_id = p_student_id
        GROUP BY
            s.gname, s.fname;
    END IF;
END;
$$ LANGUAGE plpgsql;`
