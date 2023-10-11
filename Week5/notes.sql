---------------------------------
-- COMP3311 (Week 5) Functions --
---------------------------------

/* Function Syntax (SQL) */
-- no return statement needed
-- all query results from selct statement are returned
create or replace function FuncName(argtype1, argtype2,...)  -- arguments don't have names, access them using ${arg position number}
returns rettype
as $$

$$ language sql;


/* Function Syntax (plpgsql) */
create or replace function FuncName(argname1 argtype1, argname2 argtype2, ...)
returns rettype
as $$
declare -- where local variables are declared/ defined (use :=)
    _foo boolean;
    _bar real := 1.0;
begin
    
end;
$$ language plpgsql;


-- Distribution of Content --
/*
• Q1-6   : Simple Functions --> Q1,2,3
• Q7-11  : Beer/Bars/Drinkers Database
• Q12-13 : Bank Database
• Q14-16 : UNSW Database
*/
