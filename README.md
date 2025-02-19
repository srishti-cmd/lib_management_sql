# Library Management System

## Overview
The Library Management System is a SQL-based project designed to manage book inventory, employee records, members, and book transactions efficiently. It includes database setup, CRUD operations, and advanced SQL queries for analysis.

## Objectives
1.Set up the Library Management System Database: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2.CRUD Operations: Perform Create, Read, Update, and Delete operations on the data.
3.CTAS (Create Table As Select): Utilize CTAS to create new tables based on query results.
4.Advanced SQL Queries: Develop complex queries to analyze and retrieve specific data.

### Task 1: Database Setup
![erd](https://github.com/user-attachments/assets/5809487f-226d-45f9-b847-c556340ac552)


## Task 2: Table Creation
The following tables are created to manage the library system:

- **branch**: Stores branch details, including the branch manager and contact info.
- **employee**: Stores details of employees working in different branches.
- **book**: Stores book information, including category, author, publisher, and rental price.
- **member**: Stores member details and registration date.
- **issue_status**: Manages book issuance records.
- **return_status**: Tracks book returns.

Foreign key constraints are set to maintain data integrity.

## Task 3: CRUD Operations

### 1. Create a New Book Record
```sql
INSERT INTO book 
VALUES("978-1-60129-456-2", "To Kill a Mockingbird", "Classic", 6.00, "yes", "Harper Lee", "J.B. Lippincott & Co.");
```

### 2. Update an Employee's Position
```sql
UPDATE employee 
SET position = 'Assistant' 
WHERE emp_id = 'E101';
```

### 3. Delete an Issued Book Record
```sql
DELETE FROM issue_status WHERE issued_id = 'IS121';
```

### Task 4: Retrieve All Books Issued by a Specific Employee
```sql
SELECT * FROM issue_status WHERE issued_emp_id = 'E101';
```

### Task 5: List Members Who Have Issued More Than One Book
```sql
SELECT i.issued_member_id, COUNT(*) AS total_issued, m.member_name
FROM issue_status AS i
JOIN member AS m ON i.issued_member_id = m.member_id
GROUP BY i.issued_member_id
HAVING COUNT(*) > 1;
```

### Task 6: Retrieve Books in a Specific Category
```sql
SELECT * FROM book WHERE category = "Classic";
```

### Task 7: Calculate Total Rental Income by Category
```sql
SELECT b.category, SUM(b.rental_price) AS total_income
FROM book AS b
JOIN issue_status AS i ON i.issued_book_isbn = b.isbn
GROUP BY b.category;
```

### Task 8: List Members Who Registered in the Last 2 YEARS:
```sql
SELECT 
    *
FROM
    member
WHERE
    reg_date >= CURRENT_DATE() - INTERVAL 2 YEAR;
```

### Task 9:List Employees with Their Branch Manager's Name and their branch details:
```sql
SELECT 
    e.emp_id,
    e.emp_name,
    e.position,
    b.manager_id,
    e2.emp_name AS manager_name
FROM
    employee AS e
        JOIN
    branch AS b ON e.branch_id = b.branch_id
        JOIN
    employee AS e2 ON e2.emp_id = b.manager_id;
```

### Task 10. Create a Table of Books with Rental Price Above a Certain Threshold:
```sql
CREATE TABLE expensive_books AS SELECT * FROM
    book
WHERE
    rental_price >= 8;
SELECT 
    *
FROM
    expensive_books;
```

### Task 11: Retrieve the List of Books Not Yet Returned
```sql
SELECT DISTINCT
    (ist.issued_book_name)
FROM
    issue_status AS ist
        LEFT JOIN
    return_status AS rs ON ist.issued_id = rs.issued_id
WHERE
    rs.return_id IS NULL;

```
### Task 12: Identify Members with Overdue Books (Over 30 Days)
```sql
SELECT 
    m.member_id,
    m.member_name,
    iss.issued_book_name AS book_title,
    iss.issued_date,
    DATEDIFF(CURRENT_DATE(), iss.issued_date) AS over_due_period
FROM
    issue_status AS iss
        JOIN
    member AS m ON iss.issued_member_id = m.member_id
        LEFT JOIN
    return_status AS rs ON rs.issued_id = iss.issued_id
WHERE
    (rs.return_date IS NULL
        AND DATEDIFF(CURRENT_DATE(), iss.issued_date) > 30)
ORDER BY m.member_name;
```

### Task 13: Update Book Status on Return
```sql
DELIMITER //
CREATE PROCEDURE update_book_status(IN p_issued_id VARCHAR(10))
BEGIN
    DECLARE v_isbn VARCHAR(20);
    
    SELECT issued_book_isbn INTO v_isbn FROM issue_status WHERE issued_id = p_issued_id;
    
    UPDATE book SET status = 'yes' WHERE isbn = v_isbn;
END //
DELIMITER ;
call insert_data("RS138","IS135","Good");

select * from issue_status
where issued_id='IS135';
select * from return_status
where return_book_isbn='978-0-307-58837-1';
select * from return_status
where issued_id='IS135';
select * from book
where isbn='978-0-307-58837-1';
```

### Task 14: Generate a Branch Performance Report
```sql
CREATE TABLE branch_report AS SELECT b.branch_id,
    COUNT(ist.issued_id) AS no_of_issued_books,
    COUNT(rs.return_id) AS no_of_returned_books,
    COUNT(bk.rental_price) AS revenue_generated FROM
    issue_status AS ist
        JOIN
    employee AS e ON ist.issued_emp_id = e.emp_id
        JOIN
    branch AS b ON b.branch_id = e.branch_id
        LEFT JOIN
    return_status AS rs ON rs.issued_id = ist.issued_id
        JOIN
    book AS bk ON ist.issued_book_isbn = bk.isbn
GROUP BY b.branch_id;
SELECT 
    *
FROM
    branch_report;
```

### Task 15: CTAS: Create a Table of Active Members:Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.
```sql
CREATE TABLE active_members AS SELECT * FROM
    member
WHERE
    member_id IN (SELECT DISTINCT
            issued_member_id
        FROM
            issue_status
        WHERE
            issued_date >= CURRENT_DATE() - INTERVAL 2 MONTH);
SELECT 
    *
FROM
    active_members;
```

### Tak 16: Identify Employees with the Most Book Issues Processed
```sql
SELECT 
    e.emp_name,
    COUNT(ist.issued_member_id) AS books_processed,
    e.branch_id
FROM
    employee AS e
        JOIN
    issue_status AS ist ON ist.issued_emp_id = e.emp_id
        JOIN
    branch AS b ON e.branch_id = b.branch_id
GROUP BY e.emp_name
ORDER BY COUNT(ist.issued_member_id) DESC
LIMIT 3;
```

### Task 17: Identify High-Risk Book Issuers
```sql
SELECT 
    m.member_name,
    ist.issued_book_name,
    COUNT(ist.issued_id) AS damaged_item
FROM
    issue_status AS ist
        JOIN
    member AS m ON ist.issued_member_id = m.member_id
        JOIN
    return_status AS rs ON rs.issued_id = ist.issued_id
WHERE
    rs.book_quality = 'damaged'
GROUP BY m.member_name
HAVING COUNT(ist.issued_id) > 2;
```

## Conclusion
This Library Management System provides an effective way to manage library operations, including book rentals, member tracking, employee management, and data analytics through SQL queries.
