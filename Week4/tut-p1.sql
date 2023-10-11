/*
COMP3311 - Week 4 Tut

## Admin
1. Quiz 3 due on Friday (6 October) on 11.59pm Sydney time
2. Assignment 1 
5. Please set up vxdb2 if you haven't

## Tut Questions
• Q1-11: focus on creating/adding/removing from database
• Q12-24: querying a database

## Syntax
insert into TableName(attr)
values (Tuple)

delete from TableName
where Condition

update TableName
set attrChange
where Condition
*/
-----------------------------------------------------------

create table Employees (
    eid     integer,
    ename   text,
    age     integer,
    salary  real,
    primary key (eid)
);

create table Departments (
    did     integer,
    dname   text,
    budget  real,
    manager integer references Employees(eid),
    primary key (did)
);

create table WorksIn (
    eid     integer references Employees(eid),
    did     integer references Departments(did),
    percent real,
    primary key (eid,did)
);
-----------------------------------------------------------
-- Q1
-- Yes it does. 

-- Q2
update Employee
set salary = salary * 0.8
where age < 25;

-- Q3
update Employee
set salary = salary * 1.1
where eid in (select w.eid
              from WorksIn w
              join Departments d on (w.did = d.did)
              where d.dname = 'Sales');

/*
Names
id | name
1  | Alice
2  | Bob
3  | Carol

Degrees
id | degree
1  | Computer Science
2  | Commerce
4  | Food Science
*/

select n.name, d.degree
from Names n
    outer join Degrees d on (n.id = d.id);

name  | degree
Alice | Computer Science
Bob   | Commerce
Carol | null
null  | Food Science


-- Q4
create table Departments (
    did     integer,
    dname   text,
    budget  real,
    manager integer not null references Employees(eid),
    primary key (did)
);

-- Q5
create table Employees (
    eid     integer,
    ename   text,
    age     integer,
    salary  real check (salary >= 15000),
    primary key (eid)
);

-- Q7
create table Departments (
    did     integer,
    dname   text,
    budget  real,
    manager integer references Employees(eid),
    primary key (did)
    constraint ManagerCheck
        check 1.00 = (select w.percent
                      from WorksIn w
                      where w.eid = manager);
);


-- Q10
-- 1. Default behaviour: disallow the delete
-- 2. on delete cascade
create table WorksIn (
    eid     integer references Employees(eid),
    did     integer references Departments(did) on delete cascade,
    percent real,
    primary key (eid,did)
);

-- 3. on delete set default
create table WorksIn (
    eid     integer references Employees(eid),
    did     integer references Departments(did) on delete set default,
    percent real,
    primary key (eid,did)
);

create table Departments (
    did     integer default 14,
    dname   text,
    budget  real,
    manager integer references Employees(eid),
    primary key (did)
);

-- Departments

-- (13, "IT", 2000000)
-- (14, "Accounting", 30000)

-- WorksIn
-- (3, 14, 0.8)
-- (2, 13, 0.9)
-- (2, 14, 0.1)

-- Q11
/*
EID ENAME             AGE     SALARY
----- --------------- ----- ----------
    1 John Smith         26      25000
    2 Jane Doe           40      55000
    3 Jack Jones         55      35000
    4 Superman           35      90000
    5 Jim James          20      20000

  DID DNAME               BUDGET  MANAGER
----- --------------- ---------- --------
    1 Sales               500000        2
    2 Engineering        1000000        4
    3 Service             200000        4

  EID   DID  PCT_TIME
----- ----- ---------
    1     2      1.00
    2     1      1.00
    3     1      0.50
    3     3      0.50
    4     2      0.50
    4     3      0.50
    5     2      0.75

On delete cascade
EID ENAME             AGE     SALARY
----- --------------- ----- ----------
    1 John Smith         26      25000
    2 Jane Doe           40      55000
    3 Jack Jones         55      35000
    4 Superman           35      90000
    5 Jim James          20      20000

  DID DNAME               BUDGET  MANAGER
----- --------------- ---------- --------
    1 Sales               500000        2
    3 Service             200000        4

  EID   DID  PCT_TIME
----- ----- ---------
    2     1      1.00
    3     1      0.50
    3     3      0.50
    4     3      0.50

on delete set default 
EID ENAME             AGE     SALARY
----- --------------- ----- ----------
    1 John Smith         26      25000
    2 Jane Doe           40      55000
    3 Jack Jones         55      35000
    4 Superman           35      90000
    5 Jim James          20      20000

  DID DNAME               BUDGET  MANAGER
----- --------------- ---------- --------
    1 Sales               500000        2
    3 Service             200000        4

  EID   DID  PCT_TIME
----- ----- ---------
    1     1      1.00 -- 
    2     1      1.00
    3     1      0.50
    3     3      0.50
    4     1      0.50 -- 
    4     3      0.50
    5     1      0.75 --

*/