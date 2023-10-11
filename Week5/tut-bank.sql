/* Schema:
Branches(location:text, address:text, assets:real)
Accounts(holder:text, branch:text, balance:real)
Customers(name:text, address:text)
Employees(id:integer, name:text, salary:real)
*/

-- Q12c
-- names of all employees earning more than $sal
create or replace function empsWithSalary(_salary real)
returns setof text
as $$
declare
    _empname text;
begin
    for _empname in
        select name
        into _empname
        from Employees
        where salary > _salary
    loop
        return next _empname;
    end loop;
$$ end; language plpgsql;
