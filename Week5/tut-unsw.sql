create or replace function unitName(_ouid integer)
returns text
as $$
declare
    _tname text;
    _oname text;
begin
    -- check for existence of org unit given its id
    perform *
    from OrgUnit
    where id = _ouid;

    if (not found) then
        raise exception '% is not a valid id', _ouid;
    end if;

    select t.name, u.longname
    into _tname, _oname
    from OrgUnit u
        join OrgUnitType t on (t.id = u.utype)
    where u.id = _ouid;

    -- if statements
    if (_tname = 'University') then
        return 'UNSW';
    elsif (_tname = 'Faculty') then
        return _oname;
    elsif (_tname = 'School') then
        return 'School of ' || _oname;
    elsif (_tname = 'Department') then
        return 'Department of ' || _oname;
    elsif (_tname = 'Centre') then
        return 'Centre for ' || _oname;
    elsif (_tname = 'Institute') then
        return 'Institute of ' || _oname;
    else
        return null;
    end if;
end; $$ language plpgsql;

-- Q15
create or replace function unitID(partName text) returns integer
as $$
    select id
    from OrgUnit
    where longname ilike '%' || partName || '%';
$$ language sql;
