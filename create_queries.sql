create database lib_management;
use lib_management;

-- -------table creation

create table branch(
branch_id varchar(10) primary key,
manager_id varchar(10),
branch_address	varchar(50),
contact_no varchar(10));

create table employee(
emp_id varchar(10) primary key,
emp_name varchar (20),
position varchar(15),
salary int ,
branch_id varchar(10));

create table book(
isbn varchar(20) primary key,
book_title varchar(60),
category varchar(20),
rental_price float,
status	varchar (5),
author varchar(25),
publisher varchar(30));

create table member(
member_id varchar(10) primary key,
member_name	varchar(20),
member_address varchar(50),
reg_date date);

create table issue_status(
issued_id varchar(10) primary key,
issued_member_id varchar(10),
issued_book_name varchar(30),
issued_date	date,
issued_book_isbn varchar(20),
issued_emp_id varchar(10));

create table return_status(
return_id varchar(10) primary key,
issued_id varchar(10),
return_book_name varchar(30),
return_date date,
return_book_isbn varchar(20));

-- ------foreign key

alter table issue_status
add constraint fk_members
foreign key (issued_member_id)
references member(member_id);

alter table issue_status
add constraint fk_book
foreign key (issued_book_isbn)
references book(isbn);

alter table issue_status
add constraint fk_employee
foreign key (issued_emp_id)
references employee(emp_id);

alter table employee
add constraint fk_branch_id
foreign key (branch_id)
references branch(branch_id);

alter table return_status
add constraint fk_issue_status
foreign key (issued_id)
references issue_status(issued_id);
