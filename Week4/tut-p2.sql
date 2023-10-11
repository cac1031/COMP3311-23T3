create table Suppliers (
    sid     integer primary key,
    sname   text,
    address text
);

create table Parts (
    pid     integer primary key,
    pname   text,
    colour  text
);

create table Catalog (
    sid     integer references Suppliers(sid),
    pid     integer references Parts(pid),
    cost    real,
    primary key (sid,pid)
);

-- Q12
select s.sname
from Suppliers s
    join Catalog c on (s.sid = c.sid)
    join Parts p on (p.pid = c.pid)
where p.colour = 'red';

-- Q14
-- union
select s.sid
from Suppliers s
    join Catalog c on (s.sid = c.sid)
    join Parts p on (p.pid = c.pid)
where p.colour = 'red'
union
select sid
from Suppliers s
where address = '221 Packer Street';

-- Subquery
select s1.sid
from Suppliers s1
    join Catalog c on (s1.sid = c.sid)
    join Parts p on (p.pid = c.pid)
where p.colour = 'red' or s1.sid in (
    select s2.sid
    from Suppliers s2
    where address = '221 Packer Street'
);

select s1.sid
from Suppliers s1
    join Catalog c on (s1.sid = c.sid)
    join Parts p on (p.pid = c.pid)
where p.colour = 'red' or s1.address = '221 Packer Street';

-- Q16
select s.sid
from Suppliers s
where not exists ((select p.pid from Parts p)
                except
                (select c.pid from Catalog c where s.sid = c.sid));

select c.sid
from Catalog c
group by c.sid 
having count(c.cid) = (select count(*) from Parts);


-- Catalog
-- (1, p1)
-- (1, p2)
-- (2, p3)
-- (2, p2)

-- sid-1 = {p1, p2}
-- sid-2 = {p3, p2}

-- Q22
-- select parts and cost by the Supplier 'Yosemite Sham'
create or replace view YosemiteSupplies(partsId, partsCost)
as 
select p.pid, c.cost
from Parts p
    join Catalog c on (p.pid = c.pid)
    join Suppliers s on (c.sid = s.sid)
where s.sname = 'Yosemite Sham';

select partsId
from YosemiteSupplies
where partsCost = (select max(partsCost) from YosemiteSupplies);

-- Q19
every red parts
every green part

create or replace view RedPartSuppliers
as
select s.sid
from Suppliers s
where not exists ((select p.pid from Parts p where colour = 'red')
                  except
                (select c.pid from Catalog c where s.sid = c.sid));

create or replace view GreenPartSuppliers
as
select s.sid
from Suppliers s
where not exists ((select p.pid from Parts p where colour = 'green')
                  except
                (select c.pid from Catalog c where s.sid = c.sid));

select s.sid
from    RedPartSuppliers          
union
select s.sid
from    GreenPartSuppliers;          
