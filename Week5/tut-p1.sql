-- Q1 (Square) plpgsql
create or replace function sqr(n numeric)
returns numeric
as $$
begin
    return n * n;
end;
$$ language plpgsql;


/*
Could we use this function in any of the following ways?
select sqr(5.0);    No
select(5.0::integer);   Yes
select sqr('5');    Yes, check out Data Precedence in SQL
*/

-- Q2 (Spread) plpgsql
create or replace function spread(phrase text)
returns text
as $$
declare
    res text := '';
    i integer := 1;
begin
    for i in 1..length(phrase) loop
        res := res || substr(phrase, i, 1) || ' ';
    end loop;
    return res;
end;
$$ language plpgsql;


-- Q3 (Seq) plpgsql
create or replace function seq(n integer) returns setof integer
as $$
declare
    i integer := 1;
begin
    if (n <= 1) then
        raise exception '% is not a valid number!', n;
    end if;
    for i in 1..n loop
        return next i;
    end loop;
end;
$$ language plpgsql;


-- Q6
create or replace function fac(n integer) returns integer
as $$
    select product(seq) from seq(n);
$$ language sql;
