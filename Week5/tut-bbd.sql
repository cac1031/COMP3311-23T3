/* Schema:
Beers(name:string, manufacturer:string)
Bars(name:string, address:string, license#:integer)
Drinkers(name:string, address:string, phone:string)
Likes(drinker:string, beer:string)
Sells(bar:string, beer:string, price:real)
Frequents(drinker:string, bar:string)
*/

-- Q7
-- Write a PLpgSQL function called hotelsIn() that 
-- takes a single argument giving the name of a suburb, 
-- and returns a text string containing the names 
-- of all hotels in that suburb, one per line.
create or replace function hotelsIn(_addr text) 
returns text
as $$
declare
    hotel_names text := '';
begin
    select string_agg(name, E'\n')
    into hotel_names
    from Bars
    group by addr
    having addr ilike _addr;

    return hotel_names;
end; $$ language plpgsql;


-- Q9
-- Write a PLpgSQL procedure happyHourPrice that accepts the 
-- name of a hotel, the name of a beer and the 
-- number of dollars to deduct from the price, 
-- and returns a new price. 
-- The procedure should check for the following errors:
-- • non-existent hotel (invalid hotel name)
-- • non-existent beer (invalid beer name)
-- • beer not available at the specified hotel
-- • invalid price reduction (e.g. making reduced price negative)
create or replace function happyHourPrice(_hotel text, _beer text, _discount numeric)
returns text as $$
declare
    nprice numeric;
begin
    -- non-existent bar (invalid bar name)
    perform *
    from Bars
    where name = _hotel;

    if (not found) then
        return 'There is no hotel called ''' || _hotel || '''';
    end if;

    -- non-existent beer (invalid beer name)
    perform *
    from Beers
    where name = _beer;

    if (not found) then
        return 'There is no beer called ''' || _beer || '''';
    end if;

    -- beer not available at the specified hotel
    perform *
    from Sells
    where beer = _beer and bar = _hotel;

    if (not found) then
        return 'The ' || _hotel || ' does not serve ' || _beer;
    end if;

    -- invalid price reduction (e.g. making reduced price negative)
    select price
    into nprice
    from Sells
    where beer = _beer and bar = _hotel;

    if (nprice - _discount < 0) then
        return 'Price reduction is too large; ' || _beer ||  ' only costs ' || to_char(nprice, '$9.99');
    else 
        return 'Happy hour price for ' || _beer || ' at ' || _hotel || ' is ' || to_char(nprice - _discount, '$9.99');
    end if;


end; $$ language plpgsql;


-- Q11 (PLpgSQL Version)
create function hotelsIn2(_addr text) returns setof Bars
as $$
declare
    _matched_bar record;
    _returning_bar Bars;
begin
    for _matched_bar in
        select * -- name, addr, license
        from Bars
        where addr ilike _addr
    loop
        _returning_bar.name := _matched_bar.name;
        _returning_bar.addr := _matched_bar.addr;
        _returning_bar.license := _matched_bar.license;
        return next _returning_bar;
    end loop;
end; $$ language plpgsql;
