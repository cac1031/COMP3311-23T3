# Relational Algebra
A procedural query language used for manipulating relations.\
It gives a step by step process on how to obtain a query.

### Operations
#### General Syntax:
```
Operation[operands](Table)
```
<br>

**Rename**
```
Res = Rename[Res(A,B,C)](R)
```
- Res = new table name
- (A,B,C) = names of new attributes
- R = original table
<br><br>

**Selection**
```
Sel[cond](R)
```
The *where* clause in SQL\
Returns satisfying *rows*
- cond = some satisfying condition. E.g., B = 0, C > D
<br><br>

**Projection**
```
Proj[A,B,C](R)
```
The *select* clause in SQL\
Returns satisfying *columns*
- A,B,C = columns we want
- returns a set, not a bag
<br><br>

**Union, Intersect, Except**
```
T union U
T intersect U
T except U
```
Note that all relations must have same schema
- returns a set, not a bag
- if want a bag, use *union all*
<br><br>

**Product**
```
R x S
```
Returns Cartesian product from two relations
- Size = |R| x |S| ← referring to number of rows in each table
<br><br>

**Natural Join**
```
R join S
```
Think of *natural join* in SQL
- Join on the column with the same name across two tables
- The column that we are joining on will only be returned once
<br><br>

**Theta Join**
```
R join[cond] S
```
- Think of the *join...on* used in SQL
- Variants include *Left Outer Join*, *Right Outer Join* and *Full Outer Join*
<br><br>


**Division**
```
R / S
R Div S
```
Used when we want to find entities that are interacting with *all* entities of another set
<br><br>

# Transaction Processing
### Some Definitions
- Serializability = The property that describes a transaction being able to finish before another one starts. In other words, no concurrency happening.
- Transaction = An atomic unit of work in an application which may require multiple database changes. Such changes may include read (select statements) and write operations (insert operation), as well as computations.

### Conflict-Serializable Schedule
A schedule is conflict-serializable if it can be transformed into a serial schedule by swapping non-conflicting operations.
1. Build a Precendence Graph
    - each node represents transactions
    - order of operations that matters between transactions (on the same data item):
        - reading → writing
        - writing → reading
        - writing → writing
2. If there is a cycle in the graph, it is <u><b>NOT</b></u> conflict serializable.


### View Serializable Schedule
If something is *conflict serializable*, then it is *view serializable.*\
If something is NOT *conflict serializable*, it may still be *view serializable*\
To check view serializability, we need to find a serial schedule (finding an order of transactions) that satisfy ALL of the following:

Suppose we have 2 schedules S and S' on T1,...,Tn. They are view equivalent iff <u><b>for each shared data item X</b></u>:
- In S, Tj reads initial X value
- In S', Tj reads initial X value
<br><br>
- In S, Tj reads X written by Tk
- In S', Tj reads X written by Tk
<br><br>
- In S, Tj does the final write of X
- In S', Tj does the final write of X

The main idea in view serializability is that the *view* of each read operation has to be the same. That is, we read the result of the same write operation in all schedules.

So, if we have a schedule that is NOT conflict serializable but view serializable, there exists a conflict in the schedules but the "view" of the database in each read is still preserved.\
If the conflicting operations do not change the view of the database, it means we are performing what is called a **blind write**. A blind write is when a transaction writes a value without reading it. We have a write operation followed immediately by another write operation.
