# Constraints
• Impose a condition on data in a table\
• Can be column or table level

**Types of Constraints:**
- Attribute Constraints (affects a single column)\
`check, unique, not null, like, default`

- Table Constraints (affects entire table)\
`primary key`\
`constraint NameOfConstraint <some check>`

- Referential Integrity Constraint (ensures connection between tables is valid)\
`foreign key`

<br/>

# Assertions
• Constraints only work on a relation level (1 table)\
• If we want to specify restrictions for > 1 table, we use ASSERTIONS\
• Assertions are a schema level constraint (entire database)

**Syntax**
```sql
create or replace assertion AssertionName check (condition);
```

The condition checks for violations
Therefore, we typically write our statement like this:

```sql
create or replace assertion AssertionName check
    (not exists
        (violating condition, which is an SQL Statement)
);
```

Assertions == 🤑🤑\
Every time we make changes to the tables specified in the assertion's condition, we have to perform a check.\
Very 🐢🕓

<br/>

# Triggers
• Triggers are stored procedures in a database\
• They are *triggered* when there are database events (insert, update, delete)

**Syntax**
```sql
create or replace trigger TriggerName
(before | after) operation -- e.g. before insert or update
on TableName
[for each row] -- If present, then it's a row trigger. Trigger is fired once for every modified tuple
               -- If absent, then it's a statement trigger. Trigger only fired once after all tuples are modified, just before change is committed
execute procedure FuncName(args...);
```

```sql
create or replace function FuncName() returns trigger   -- always returns trigger
as $$
declare
...
begin
...
end;
$$ language plpgsql;
```

```sql
drop trigger TriggerName on TableName;
```

### Activity Sequence
[Before Triggers] → [Standard Constraint Check] → [After Triggers] → Commit

### Before Triggers
- `new` contains "proposed" value of tuple for INSERT/UPDATE operations
- Modifying `new` in before-triggers causes different value to be placed in DB
- `old` contains initial content of tuple value for UPDATE/DELETE operations

### After Triggers
- `new` contains current value of changed tuple (value is already stored in table)
- `old` contains previous value of changed tuple (value is no longer stored in table)
- constraint checking has been done for `new`

### Notes about old and new
- both are data type RECORD
- `new` does not exist for delete operations
- `old` does not exist for insert operations
- If exception is raised, no change occurs

<br/>

# Aggregates
• Reduces a collection of values into one single result\
• Existing aggregates in SQL: `count`, `max`, `min`, `sum`, `avg`\
• BaseType = starting type\
• StateType = intermediate type\
• ResultType = final result type

**Syntax for User-Defined Aggregates**
```sql
create or replace aggregate AggName(BaseType) (
    sfunc = UpdateStateFunction,
    stype = StateType,
    initcond = InitialValue,    -- for custom types, wrap it in ''
    finalfunc = MakeFinalFunction,  -- optional
    sortop = OrderingOperator   -- optional
);
```
- An AGGREGATE maps a COLUMN of values of BaseType to a single value of type ResultType
- `sfunc` is a function that takes in 2 parameters, one of type StateType and one of type BaseType, returns StateType
- `finalfunc` takes in StateType and returns ResultType
