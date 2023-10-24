/*
COMP3311 - Wk7 Tut (Assertions, Triggers, Aggregates)

Admin:
• Assignment 1 has been marked - check the marks via `give`
• Quiz 4 due on Friday 27 October @ 11.59pm

Question Distribution:
• Q1-2 – Assertions
• Q3-5 – Triggers Theory
• Q6-8 – More Triggers
• Q9-12 – Triggers with Concrete Databases (9, 11)
• Q13-15 – Aggregates
*/
--------------------------------------
-- 1,2 → 13,14 → 3,4,5 → 6,7 → 9,11 --
--------------------------------------

-- Q1. Consider a schema for an organisation
---------------------------------------------------------------------------
Employee(id:integer, name:text, works_in:integer, salary:integer, ...) 
Department(id:integer, name:text, manager:integer, ...)
---------------------------------------------------------------------------
-- Ensure manager must work in the Department they manage
create or replace assertion manager_works_in_department check
    (not exists
        (select *
         from Employee e
            join Department d on (d.manager = e.id)
         where e.works_in != d.id
        )
);

-- Q2.
create or replace assertion employee_manager_salary check
    (not exists
        (select *
         from Employee e
            join Department d on (e.works_in = d.id)
            join Employee m on (m.id = d.manager)
         where e.salary > m.salary
        )
);

-- Q6.
create table R (
    a int, 
    b int, 
    c text, 
    primary key(a,b)
);

create table S (
    x int primary key, 
    y int
);

create table T (
    j int primary key, 
    k int references S(x)
);

-- a] primary key constraint on relation R
-- unique
-- not null
create or replace function R_pk_check() returns trigger
as $$
begin
    -- not null
    if (new.a is null or new.b is null) then
        raise exception 'Primary key cannot be null';
    end if;

    if (TG_OP = 'UPDATE' and old.a = new.a and old.b = new.b) then
        return new;
    end if;

    -- unique
    perform *
    from R
    where a = new.a and b = new.b;

    if (found) then
        raise exception 'Primary key must be unique';
    end if;

    return new;
end;
$$ language plpgsql;

create or replace trigger R_pk_trigger
before insert or update
on R
for each row
execute procedure R_pk_check();

-- b] foreign key constraint between T.k and S.x
-- T.k is the foreign key referring to primary key S.x

-- Foreign Key: not null/referential integrity
create or replace function T_fk_check() returns trigger
as $$
declare

begin
    perform *
    from S
    where S.x = new.k;

    if (not found) then
        raise exception 'Invalid reference to S.x';
    end if;

    return new;
end;
$$ language plpgsql;

create or replace trigger T_fk_trigger
before insert or update
on T
for each row
execute procedure T_fk_check();

create or replace function S_fk_check() returns trigger
as $$
begin
    if (TG_OP = 'UPDATE' and old.x = new.x) then
        return new;
    end if;

    perform *
    from T
    where k = old.x

    if (found) then
        raise exception 'There are references to x';
    end if;

    return new;
end;
$$ language plpgsql;

create or replace trigger S_fk_trigger
before delete or update
on S
for each row
execute procedure S_fk_check();

-- Q7. Difference
create trigger updateS1 after update on S
for each row execute procedure updateS();

create trigger updateS2 after update on S
for each statement execute procedure updateS();
-- Assume that S contains primary keys (1,2,3,4,5,6,7,8,9).
-- a] update S set y = y + 1 where x = 5;
-- Only have 1 row being affected by the trigger
-- Row: fires once
-- Statement: fires once

-- b] update S set y = y + 1 where x > 5;
-- Row: fires four times
-- It will perform an update then fire the trigger
-- Statement: fires once
-- It will perform ALL updates then fire the trigger ONCE at the end

-- Q9. 
Emp(empname:text, salary:integer, last_date:timestamp, last_usr:text)
-- ensure any time a row is inserted/updated, current user name and time are stamped into row
-- ensure employee's name is given & salary is positive
create or replace function emp_check() returns trigger
as $$
begin
    if (new.empname is null) then
        raise exception 'Employee name can''t be empty';
    end if;

    if (new.salary < 0) then
        raise exception 'Salary can''t be negative';
    end if;

    new.last_date := now();
    new.last_usr := user();
end;
$$ language plpgsql;

create or replace trigger emp_trigger
before insert or update
on Emp
for each row
execute procedure emp_check();

-- Q11.
Shipments(id:integer, customer:integer, isbn:text, ship_date:timestamp)
Editions(isbn:text, title:text, publisher:integer, published:date,...)
Stock(isbn:text, numInStock:integer, numSold:integer)
Customer(id:integer, name:text,...)

-- insert into Shipments(customer,isbn) values (9300035,'0-8053-1755-4'); --
create or replace function new_shipment() returns trigger
as $$
declare
    shipment_id integer;
begin
    if (new.customer is null or new.isbn is null) then
        raise exception 'Customer and ISBN can''t be null';
    end if;

    perform *
    from Customer
    where new.customer = id;

    if (not found) then
        raise exception 'Invalid customer ID';
    end if;

    perform *
    from Stock
    where new.isbn = isbn;

    if (not found) then
        raise exception 'Invalid ISBN';
    end if;

    if (TG_OP = 'INSERT') then
        update Stock
        set numInStock = numInStock - 1,
            numSold = numSold + 1
        where new.isbn = isbn;
    else
        update Stock
        set numInStock = numInStock + 1
        where isbn = old.isbn;

        update Stock
        set numSold = numSold - 1
        where isbn = new.isbn;
    end if;

    select max(id)
    into shipment_id
    from Shipments;

    shipment_id := shipment_id + 1;
    new.ship_date := now;
    new.id := shipment_id;

end;
$$ language plpgsql;

create or replace trigger new_shipment_trigger
after insert or update
on Shipments
for each row
execute procedure new_shipment();

-- Q14. avg aggregate
drop type if exists SumCount cascade;
create type SumCount(sum numeric, count integer);

create or replace function compute(state SumCount, col_value numeric)
returns SumCount as
$$
begin
    if (col_value is null) then
        return state;
    end if;
    
    state.sum := state.sum + col_value;
    state.count = state.count + 1;
    return state;
end;
$$ language plpgsql;

create or replace function do_mean(state SumCount) returns numeric as
$$
begin
    if (state.count = 0) then
        return null;
    end if;

    return state.sum / state.count;
end;
$$ language plpgsql;

create or replace aggregate mean(numeric) (
    sfunc = compute,
    stype = SumCount,
    initcond = '(0,0)',    
    finalfunc = do_mean  
);
