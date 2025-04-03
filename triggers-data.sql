-- rchaney@pdx.edu

-- drop schema if exists triggers cascade;
create schema if not exists triggers;


-- drop table triggers.students cascade;
create table if not exists triggers.students (
	student_id	int primary key
	, gname		text
	, fname		text
);

-- drop table triggers.classes cascade;
create table if not exists triggers.classes (
	class_id		int primary key
	, class_name	text
	, class_credits		int
);

-- a many-to-many relationship
-- drop table triggers.registrations cascade;
create table if not exists triggers.registrations (
	class_id		int references triggers.classes (class_id)
	, student_id	int references triggers.students (student_id)
	, primary key (class_id, student_id)
	
);

-- truncate table triggers.students;
insert into triggers.students (student_id, gname, fname)
values
	(1, 'Jesse', 'Chaney')
	, (2, 'Kevin', 'McGrath')
	, (3, 'Mark', 'Jones')
	, (4, 'Karla', 'Fant')
	, (5, 'Wu-chang', 'Feng')
	, (6, 'Stephanie', 'Allen')
	, (7, 'Michael', 'Wilson')
;

-- truncate table triggers.classes;
insert into triggers.classes (class_id, class_name, class_credits)
values
	(1, 'cs161', 4)
	, (2, 'cs162', 4)
	, (3, 'cs163', 4)
	, (4, 'cs205', 4)
	, (5, 'cs250', 4)
	, (6, 'cs251', 4)
	, (7, 'cs302', 4)
	, (8, 'cs305', 2)
	, (9, 'cs314', 4)
	, (10, 'cs333', 4)
	, (11, 'cs350', 4)
	, (12, 'cs358', 4)
	, (13, 'cs486', 4)
;

-- truncate table triggers.registrations;
insert into triggers.registrations (student_id, class_id)
values
	(1, 4)
	, (1, 8)
	, (1, 10)
	, (1, 13)
;

CREATE OR REPLACE PROCEDURE triggers.register1(
    IN p_student_id INT,
    IN p_class_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO triggers.registrations (student_id, class_id)
    VALUES (p_student_id, p_class_id);
END;
$$;

call triggers.register1(2, 10);
call triggers.register1(2, 11);
call triggers.register1(2, 12);
call triggers.register1(2, 13);

SELECT
    s.gname
    ,s.fname 
    ,c.class_name
    ,c.class_credits
FROM
    triggers.students s
JOIN
    triggers.registrations r ON s.student_id = r.student_id
JOIN
    triggers.classes c ON r.class_id = c.class_id
ORDER BY
    s.gname, s.fname, c.class_name, c.class_credits;

DROP VIEW IF EXISTS triggers.student_classes;
CREATE OR REPLACE VIEW triggers.student_classes AS
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
ORDER BY
    s.gname, s.fname, c.class_name, c.class_credits;

----question 5----------
select * from triggers.student_classes
where  gname = 'Jesse' and fname = 'Chaney';

------question 6-----------
CREATE OR REPLACE FUNCTION triggers.student_classes_func1(p_student_id INT)
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
$$ LANGUAGE plpgsql;

select * from triggers.student_classes_func1(1);

----question 7 -----------
CREATE OR REPLACE FUNCTION triggers.student_classes_func2(p_student_id INT)
RETURNS TABLE (
    gname TEXT,
    fname TEXT,
    class_name TEXT,
    class_credits INT
) AS $$
BEGIN
    IF p_student_id = 0 THEN
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
            triggers.classes c ON r.class_id = c.class_id;
    ELSE
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
    END IF;
END;
$$ LANGUAGE plpgsql;

select * from triggers.student_classes_func2(2);

select * from triggers.student_classes_func2(0);

----question 8 -------

CREATE OR REPLACE FUNCTION triggers.get_student_id(p_gname TEXT, p_fname TEXT)
RETURNS INT AS $$
DECLARE
    v_student_id INT;
BEGIN
    SELECT student_id INTO v_student_id
    FROM triggers.students
    WHERE gname = p_gname AND fname = p_fname;

    RETURN v_student_id;
END;
$$ LANGUAGE plpgsql;

select * from triggers.get_student_id('Jesse', 'Chaney');

select * from triggers.student_classes_func1(
triggers.get_student_id('Jesse', 'Chaney'));


----question 9 -------
SELECT
    s.gname,
    s.fname,
    SUM(c.class_credits) AS total_credits
FROM
    triggers.students s
JOIN
    triggers.registrations r ON s.student_id = r.student_id
JOIN
    triggers.classes c ON r.class_id = c.class_id
GROUP BY
    s.gname, s.fname
ORDER BY
    s.gname, s.fname, total_credits;

-----question 10 ------
CREATE OR REPLACE FUNCTION triggers.student_credits_func1(p_student_id INT)
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
$$ LANGUAGE plpgsql;


select * from triggers.student_credits_func1(2);
select * from triggers.student_credits_func1(triggers.get_student_id('Jesse','Chaney'));
select * from triggers.student_credits_func1(0);

----question 11-----
CREATE OR REPLACE PROCEDURE triggers.register2(
    IN p_student_id INT,
    IN p_class_id INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_existing_credits INT;
    v_new_class_credits INT;
    v_num_registered_classes INT;
BEGIN
    -- Get existing credits for the student
    SELECT SUM(c.class_credits)::INT
    INTO v_existing_credits
    FROM triggers.students s
    JOIN triggers.registrations r ON s.student_id = r.student_id
    JOIN triggers.classes c ON r.class_id = c.class_id
    WHERE s.student_id = p_student_id;

    -- Get credits for the new class
    SELECT triggers.student_credits_func1(p_student_id)
    INTO v_new_class_credits
    WHERE p_student_id = p_student_id;

    -- Check if student is already registered for the class
    SELECT COUNT(*)
    INTO v_num_registered_classes
    FROM triggers.registrations
    WHERE student_id = p_student_id AND class_id = p_class_id;

    IF v_existing_credits + v_new_class_credits > 18 THEN
        RAISE EXCEPTION 'Student cannot register due to too many credits.';
    ELSIF v_num_registered_classes > 0 THEN
        RAISE EXCEPTION 'Student is already registered for this class.';
    ELSE
        INSERT INTO triggers.registrations (student_id, class_id)
        VALUES (p_student_id, p_class_id);
    END IF;
END;
$$;

call triggers.register2(3, 1);

call triggers.register2(3, 2);

call triggers.register2(4, 1);

call triggers.register2(2, 1); -- this one should fail

call triggers.register2(1, 1); -- this one should fail

select * from triggers.student_classes_func2(0);
