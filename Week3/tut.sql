-- SQL Recap
create table Degrees (
    did char(4) check (did ~ '[0-9]{4}'),
    primary key(did),
    name text
);

create table Students (
    zid serial primary key, -- serial gives unique integer values
    given text not null unique,
    family varchar(40),
    dob date not null,
    gender char(1) check (gender in ('M', 'F', 'X')),
    degree char(4) references Degrees(did)
);

create table P (
    id integer primary key,
    a text
);

create table R (
    id integer references P(id),
    primary key(id),
    b text
);
--------------------------------------------------------------------
-- Q5a
create table R (
    id integer primary key,
    name text,
    address text,
    d_o_b date
);

create table S (
    name text,
    address text,
    ssn char(10),
    d_o_b date,
    primary key(name, address, ssn)
);

-- Q9b
insert into R(name, d_o_b) values
    ("Foo", 111101);

r_id integer references R(id);

-- Q13
-- Relational Mappping
Supplier: name#, city
Supply: quantity, name, number
Part: number#, colour

-- SQL Create Table
create table Suppliers(
    name text,
    primary key(name),
    city text
);

create table Parts(
    number integer primary key,
    colour text
);

create table Supply(
    quantity integer,
    name text references Suppliers(name),
    part_number integer,
    foreign key part_number references Parts(number),
    primary key(name, part_number)
);

-- Q17
-- Relational Mapping

Employee: ssn#, birthdate, name, worksFor
Department: name#, phone, location, manager, mdate
Project: pnum#, title
Participation: time, ssn, pnum
Dependent: name, birthdate, ssn, relation

-- Create Table Statements
create table Employees (
    ssn serial primary key,
    birthdate date,
    name text,
    worksFor text
);

create table Departments(
    name text primary key,
    phone text check (phone ~ '04[0-9]{8}'),
    location text,
    manager integer references Employees(ssn),
    mdate date
);

Employee: ssn#, birthdate, name, worksFor
Department: name#, phone, location, manager, mdate
Project: pnum#, title
Participation: time, ssn, pnum
Dependent: name, birthdate, ssn, relation

alter table Employees add
    foreign key worksFor references Department(name);

create table Projects(
    pnum serial primary key,
    title char(40)
);

create table Participation(
    time char(4) check (time ~ '[0-9]{4}'),
    employee_ssn integer references Employees(ssn),
    projects_pnum integer references Projects(pnum),
    primary key(employee_ssn, projects_pnum)
);

create table Dependent(
    "name" text,
    birthdate date,
    employee_ssn integer references Employees(ssn),
    relation text,
    primary key(name, employee_ssn) 
);

birthdate = BIRTHdate = birthdate
"name" != "Name" != "NAME"