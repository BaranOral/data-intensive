#! /bin/bash
docker-compose up
#https://github.com/datacharmer/test_db
# EXECUTE THIS IN MASTER
SHOW VARIABLES LIKE 'server_id';

CREATE USER 'replication'@'%' IDENTIFIED WITH mysql_native_password BY 'replication';
SHOW databases;

GRANT REPLICATION SLAVE ON *.* TO 'replication'@'%';
SHOW GRANTS for replication@'%';

SHOW MASTER STATUS\G;
#COPY FILE AND POSITION NAME FOR MASTER

##EXECUTE THIS FOR BOTH SLAVE
SHOW VARIABLES LIKE 'server_id';
SET GLOBAL server_id=21; #for one of them
SET GLOBAL server_id=37; #for the other one

#COPY FILE AND POSITION FROM MASTER TO LAST TWO
CHANGE MASTER TO
MASTER_HOST='master',
MASTER_USER='replication',
MASTER_PASSWORD='replication',
MASTER_LOG_FILE='binlog.000002',
MASTER_LOG_POS=674;

START SLAVE;

SHOW SLAVE STATUS\G;

#INDEX OLUSTIR
USE employees;

CREATE INDEX employees_name_index ON employees (first_name, last_name);
CREATE INDEX employees_hire_date_index ON employees (hire_date);

CREATE INDEX departments_index ON departments (dept_name);

CREATE INDEX dept_manager_index ON dept_manager (emp_no, dept_no, from_date);

CREATE INDEX dept_emp_index ON dept_emp (emp_no, dept_no, from_date);

CREATE INDEX titles_index ON titles (emp_no, title, from_date);

CREATE INDEX salaries_index ON salaries (emp_no, from_date);
CREATE INDEX employees_emp_no_index ON employees (emp_no);

SHOW INDEXES FROM employees;

# Insert some sample data into the tables of the employee database
INSERT INTO employees (emp_no, birth_date, first_name, last_name, gender, hire_date)
VALUES (1, '1998-01-01', 'Baran', 'Oral', 'M', '2000-01-01');

INSERT INTO departments (dept_no, dept_name)
VALUES ('d001', 'Sales');

INSERT INTO dept_manager (emp_no, dept_no, from_date, to_date)
VALUES (1, 'd001', '2000-01-01', '2010-01-01');

INSERT INTO dept_emp (emp_no, dept_no, from_date, to_date)
VALUES (1, 'd001', '2000-01-01', '2010-01-01');

INSERT INTO titles (emp_no, title, from_date, to_date)
VALUES (1, 'Manager', '2000-01-01', '2010-01-01');

INSERT INTO salaries (emp_no, salary, from_date, to_date)
VALUES (1, 50000, '2000-01-01', '2010-01-01');

# Run a query against the employee database and measure the performance
EXPLAIN SELECT * FROM employees WHERE first_name = 'Baran';

# Create an index on the employees table
CREATE INDEX employees_name_index ON employees (first_name);

# Run the same query against the employee database again and measure the performance
EXPLAIN SELECT * FROM employees WHERE first_name = 'Baran';

#-- Delete the index from the employees table
DROP INDEX employees_name_index ON employees;

# Run the same query against the employee database again and measure the performance
EXPLAIN SELECT * FROM employees WHERE first_name = 'John';

#BUNU TUT
SELECT BENCHMARK(1000000, (SELECT COUNT(*) FROM employees WHERE first_name = 'John'));
SELECT * FROM employees WHERE hire_date BETWEEN '2000-01-01' AND '2000-12-31';

SELECT BENCHMARK(100000, (SELECT COUNT(*) FROM dept_emp WHERE from_date > '2000-01-01'));

SELECT BENCHMARK(1000000, (SELECT e.first_name, e.last_name, SUM(s.salary) FROM employees e
INNER JOIN dept_emp de ON e.emp_no = de.emp_no
INNER JOIN departments d ON de.dept_no = d.dept_no
INNER JOIN titles t ON e.emp_no = t.emp_no
INNER JOIN salaries s ON e.emp_no = s.emp_no
WHERE t.title = 'Manager'
GROUP BY e.emp_no));


EXPLAIN SELECT SQL_NO_CACHE e.first_name, e.last_name, SUM(s.salary) FROM employees e
INNER JOIN dept_emp de ON e.emp_no = de.emp_no
INNER JOIN departments d ON de.dept_no = d.dept_no
INNER JOIN titles t ON e.emp_no = t.emp_no
INNER JOIN salaries s ON e.emp_no = s.emp_no
GROUP BY e.emp_no; 


