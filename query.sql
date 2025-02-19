-- --------CRUD Operations
use lib_management;
-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"--

insert into book 
values("978-1-60129-456-2", "To Kill a Mockingbird", "Classic", 6.00, "yes", "Harper Lee", "J.B. Lippincott & Co.");
SELECT 
    *
FROM
    book;
 
--  Task 2: Update an Existing Member's Address

UPDATE employee 
SET 
    position = 'Assistant'
WHERE
    emp_id = 'E101';
SELECT 
    *
FROM
    employee;

-- Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

DELETE FROM issue_status 
WHERE
    issued_id = 'IS121';
SELECT 
    *
FROM
    issue_status;

-- Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT 
    *
FROM
    employee
WHERE
    emp_id = 'E101';

-- Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT 
    i.issued_emp_id, COUNT(*), e.emp_name
FROM
    issue_status AS i
        JOIN
    employee AS e ON i.issued_emp_id = e.emp_id
GROUP BY i.issued_emp_id
HAVING COUNT(*) > 1;

-- Task 6. Retrieve All Books in a Specific Category:

select * from book 
where category="classic";

-- Task 7: Find Total Rental Income by Category:

SELECT 
    b.category, SUM(b.rental_price)
FROM
    book AS b
        JOIN
    issue_status ON issue_status.issued_book_isbn = b.isbn
GROUP BY category;

-- Task 8:List Members Who Registered in the Last 2 YEARS:

SELECT 
    *
FROM
    member
WHERE
    reg_date >= CURRENT_DATE() - INTERVAL 2 YEAR;

-- task 9:List Employees with Their Branch Manager's Name and their branch details:

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

-- Task 10. Create a Table of Books with Rental Price Above a Certain Threshold:

CREATE TABLE expensive_books AS SELECT * FROM
    book
WHERE
    rental_price >= 8;
SELECT 
    *
FROM
    expensive_books;

-- Task 11: Retrieve the List of Books Not Yet Returned

SELECT DISTINCT
    (ist.issued_book_name)
FROM
    issue_status AS ist
        LEFT JOIN
    return_status AS rs ON ist.issued_id = rs.issued_id
WHERE
    rs.return_id IS NULL;

-- Task 12: Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

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

-- Task 13: Update Book Status on Return
-- Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).

delimiter //
create procedure insert_data(in p_return_id varchar(10),in p_issued_id varchar(10),in p_book_quality varchar(20))
begin
declare v_isbn varchar(20);
declare v_book_name varchar(70);
insert into return_status(return_id,issued_id,return_date,book_quality)
values(p_return_id,p_issued_id,current_date(),p_book_quality);

SELECT 
    issued_book_isbn, issued_book_name
INTO v_isbn , v_book_name FROM
    issue_status
WHERE
    issued_id = p_issued_id;

UPDATE book 
SET 
    status = 'yes'
WHERE
    isbn = v_isbn;

SELECT 
    CONCAT('Thanku for returning the book',
            v_book_name);
end //
delimiter ;
call insert_data("RS138","IS135","Good");

select * from issue_status
where issued_id='IS135';
select * from return_status
where return_book_isbn='978-0-307-58837-1';
select * from return_status
where issued_id='IS135';
select * from book
where isbn='978-0-307-58837-1';

-- Task 14: Branch Performance Report
-- Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

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

-- Task 15: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

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

-- Task 16-- : Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

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

-- Task 17: Identify Members Issuing High-Risk Books
-- Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.

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

