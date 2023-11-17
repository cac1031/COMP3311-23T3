# COMP3311 - Week 10 Tutorial
```
Question Overview
• Relational Algebra Theory: Q1,2
• Relational Algebra, small DB: Q3,4
• Constructing Relational Algebra Operations: Q7,8,9
----------------------------------------------------
• Transaction Def: Q10
• Serializability: Q11,12,13,14
```

## Relational Algebra
### Q1
**Relational algebra operators can be composed. What precisely does this mean? And why is it important?**\
The result from an operation can be used as an operand for the subsequent operation.\
Having intermediate results allows us to slowly build complex queries, instead of using one nested query.

### Q2
**What is the difference between the above natural join and theta join?**\
Natural Join = takes one column from the joining attribute\
Theta Join = joining attribute appears as two columns

### Q3
```
                PCs
Model	Speed	RAM	    Disk	Price
1001	700	    64	    10	    799
1002	1500	128	    60	    2499
1003	1000	128	    20	    1499
1004	1000	256	    40	    1999
1005	700	    64	    30	    999
```
**Consider a projection of this relation on the processor speed attribute, i.e. `Proj[speed](PCs).`**

**a. Value of the projection as a set?**\
{700,1000,1500}

**b. Value of the projection as a bag?**\
{700,1500,1000,1000,700}

**e. Is the minimum/maximum speed different between the bag and set representation?**\
No. Because a set is a subset of a bag, so min and max will be the same in both.

### Q4
```
    R                 S
A	B	C           B   C
a1	b1	c1          b1  c1
a1	b2	c2          b2  c2
a2	b1	c1
```
<br>

**a. `R Div S`**
```
For division, order of rows in divisor does not matter, as long as all entries of the divisor exists in the dividend.
R
A
--
a1
```
<br>

**b. `R Div (Sel[B != b1](S))`**
```
Temp = Sel[B != b1](S)
  S
B   C
------
b2  c2

Res = R Div Temp
R
A
--
a1
```
<br>

**c. `R Div (Sel[B != b2](S))`**
```
Temp = Sel[B != b2](S)
  S
B   C
------
b1  c1

Res = R Div Temp
R
A
--
a1
a2
```
<br>

**d. `(R × S) - (Sel[R.C=S.C](R Join[B=B] S)`**
```
Temp1 = R Join[B=B] S
--5 columns--
R.A R.B R.C S.B S.C 
a1  b1  c1  b1  c1
a1  b2  c2  b2  c2
a2  b1  c1  b1  c1

Temp2 = Sel[R.C=S.C](Temp1)
R.A R.B R.C S.B S.C 
a1  b1  c1  b1  c1
a1  b2  c2  b2  c2
a2  b1  c1  b1  c1

Temp3 = R x S
--5 columns, 6 rows--
R.A R.B R.C S.B S.C 
a1  b1  c1  b1  c1
a1  b1  c1  b2  c2
a1  b2  c2  b1  c1
a1  b2  c2  b2  c2
a2  b1  c1  b1  c1
a2  b1  c1  b2  c2

Res = Temp3 - Temp2
R.A R.B R.C S.B S.C 
a1  b1  c1  b2  c2
a1  b2  c2  b1  c1
a2  b1  c1  b2  c2
```
<br>

### Q7
Suppliers(**sid**, sname, address)\
Parts(**pid**, pname, colour)\
Catalog(***supplier***, ***part***, cost)
<br>

Rough ER: ```[Supplier]---<Catalog>---[Parts]```

**a. Find the names of suppliers who supply some red part.**
```
1. Join Catalog to Suppliers
2. Join Parts to Catalog
3. Selection of red rows
4. Projection of sname column

Temp1 = Catalog Join[catalog.supplier = supplier.sid] Suppliers
sid | sname | address | supplier | part | cost

Temp2 = Parts Join[parts.pid = temp1.part] Temp1
sid | sname | address | supplier | part | cost | pid | pname | colour

Temp3 = Sel[colour='red'](Temp2)
sid | sname | address | supplier | part | cost | pid | pname | colour

Res = Proj[sname](Temp3)
sname
```
<br>

**c. Find the sids of suppliers who supply some red part or whose address is 221 Packer Street.**
```
1. Join all tables together (similar to Q7a)
2. Selection on red parts and 221 Packer Street
3. Choose only to output the column of sids

Temp1 = Catalog Join[catalog.supplier = supplier.sid] Suppliers
sid | sname | address | supplier | part | cost

Temp2 = Parts Join[parts.pid = temp1.part] Temp1
sid | sname | address | supplier | part | cost | pid | pname | colour

Temp3 = Sel[colour='red' or address='221 Packer Street'](Temp2)
sid | sname | address | supplier | part | cost | pid | pname | colour

Res = Proj[sid](Temp3)
sid
```
<br>

**f. Find the sids of suppliers who supply every part.**
```
This is division
1. Find all parts ID
2. Find all supplier IDs with the corresponding parts they supply (use Catalog Table)
3. Divide

PartsIds = Proj[pid](Parts)
pid

SuppliersAndPartsIds = Proj[supplier,part](Catalog)
supplier | part

SuppliersAndPartsIds = Rename[supplier, pid](SuppliersAndPartsIds)
supplier | pid

AllPartsSuppliers = SuppliersAndPartsIds Div PartsIds
```
<br>

**k. Find the pids of the most expensive part(s) supplied by suppliers named "Yosemite Sham".**\
https://stackoverflow.com/questions/5493691/how-can-i-find-max-with-relational-algebra
```sql
create or replace view YosemiteShamParts as
select c.part, c.cost
from Suppliers s
join Catalog c on (s.sid = c.supplier)
where s.sname = 'Yosemite Sham';

select part
from YosemiteShamParts
where cost = (select max(cost) from YosemiteShamParts);
```

```
Let's try to follow the SQL query above
The first step is to simply find the parts supplied by Yosemite Sham and each of its associated cost.

YSParts = Proj[part,cost](Sel[sname='Yosemite Sham'](Suppliers Join[suppliers.sid = catalog.supplier] Catalog))
⇒ if the above looks too nested, the sub-operations are basically a Join → Selection → Projection

########################################
# Now the challenge is to find the max #
########################################
What we can do is find the cross product of the result with itself.
To do this, we create another duplicate table called YSParts2.
Then do a selection where every YSParts.cost < YSParts2.cost.
This gives us all rows that have all but the maximum cost.
Then we do a set difference with the original YSParts table.

## To do the cross product, first we need to duplicate the table
YSParts2 = YSParts

## Now perform the cross product
NotExpensiveYSParts = Proj[YSParts.part](Sel[YSParts.cost < YSParts2.cost](YSParts x YSParts2))

## Then we do the set difference
Res = Proj[part](YSParts) - Proj[part](NotExpensiveYSParts)

## To show an example on why it works, let's suppose we have YSParts (parts supplied by Yosemite Sham with the associated cost) be a table with entries:
part   cost
------------
100     20
200     20
300     10

## Then, when we find the cross product with the table above with itself:
1.part   1.cost   2.part   2.cost
----------------------------------
100        20      100       20
100        20      200       20
100        20      300       10
200        20      100       20
200        20      200       20
200        20      300       10
300        10      100       20
300        10      200       20
300        10      300       10

## Now, we filter out entries where 1.cost < 2.cost
1.part   1.cost   2.part   2.cost
----------------------------------
300        10      100       20
300        10      200       20

## Then, we project only the 1.part column
part [This is Table 1]
----
300
300
300

## Looking at the original YSParts table, let's also project only the part column
part [This is Table 2]
----
100
200
300

## Now we perform a Set Difference of Table 2 - Table 1
part
----
100
200

This table corresponds to the pids of the most expensive parts supplied by Yosemite Sham.


Bonus: can you modify the Relational Algebra statements to instead find the pids for the cheapest items supplied?
```
<br>

## Transaction Processing

### Q11
```
T1:      R(A) W(Z)                C  
T2:                R(B) W(Y)        C  
T3: W(A)                     W(B)     C 
```
T3 → T1: W(A) → R(A)\
T2 → T3: R(B) → W(B)\
The precedence graph is a path graph of T2 → T3 → T1.

### Q13
❗❗Take a look at the `notes.md` for conflict and view serializability first, especially the very last paragraph of the page.

**a.**
```
T1: R(X)      W(X)
T2:      R(X)      W(X)
```
- Conflict Serializable?
    - T1 → T2: R(X) → W(X)
    - T2 → T1: W(X) → W(X)
    - There is a cycle that exists in the precedence graph
    - Therefore it is not conflict serializable
- View Serializable?
    - For data item **X**: T1 does the initial read. T2 does the final write.
    - The read operation performed by T1 has to come before T2, making T2;T1 invalid.
    - So, let's try T1;T2
    - ```
        T1: R(X) W(X)
        T2:           R(X) W(X)
        The read in T2 does not have the same 'view' as the concurrent schedule because we have wrote to it in T1 already.  
       ```
    - Therefore it is not view serializable

**b.**
```
T1: W(X)      R(Y)
T2:      R(Y)      R(X)
```
- Conflict Serializable?
    - T1 → T2: W(X) → R(X)
    - No cycles detected in the precedence graph. Therefore it is conflict serializable with ordering T1;T2
- View Serializable?
    - If it's conflict serializable, it is view serializable.
    - For **X**: T1 does the initial read. T2 does the final write. The read of X has to come after the write to preserve the 'view'
    - For **Y**: T1 does the initial read. But in the concurrent schedule, since there are no write operations being performed to Y, the read operation order does not matter between transactions
    - Let's do T1;T2
    - ```
        T1: W(X) R(Y)
        T2:           R(Y) R(X) 
       ```
    - The concurrent schedule is view equivalent to T1;T2. Therefore it is view serializable

**c.**
```
T1: R(X)                R(Y)
T2:      R(Y)      R(X)
T3:           W(X)
```
- Conflict Serializable?
    - T1 → T3: R(X) → W(X)
    - T3 → T2: W(X) → R(X)
    - Since no cycles are detected, it is conflict serializable with schedule T1;T3;T2.

- View Serializable?
    - Since it is conflict serializable, it is view serializable.
    - For **X**: T1 does the initial read, T3 does the final write. We also must have T3 → T2 as to maintain the 'view' when T2 reads T3's write.
    - For **Y**: T2 does initial read. Again, since we are not writing to Y, the order of reading does not matter between transactions.
    - We'll try T1;T3;T2
    - ```
        T1: R(X) R(Y)
        T2:                R(Y) R(X)
        T3:           W(X) 
       ```
    - All conditions are fulfilled. Therefore the concurrent schedule is view equivalent to T1;T3;T2

**d.**
```
T1: R(X) R(Y) W(X)          W(X)
T2:                R(Y)          R(Y)
T3:                     W(Y)
```
- Conflict Serializable?
    - T1 → T3: R(Y) → W(Y)
    - T3 → T2: R(Y) → W(Y)
    - T2 → T3: W(Y) → R(Y)
    - Cycle detected. Therefore it is not conflict serializable
- View Serializable?
    - For **X**: T1 does the initial read. T1 does the final write.
    - For **Y**: T1 does the initial read. T3 does the final write. T3 → T2 as the final read in T2 is preceded by a write from T3.
    - From looking closer at the concurrent schedule, it is not possible for any arrangement of transactions to be view equivalent. This is because in the last three operations relating to data item Y in T2 and T3, we have T2 reading Y before T3 writes to it, then T2 reads the updated version after the write. So in order to maintain this 'view' of before and after writing to it, we need concurrency.
    - Therefore it is not view serializable

**e.**
```
T1: R(X)      W(X)
T2:      W(X)      
T3:                W(X)
```
- Conflict Serializable?
    - T1 → T2: R(X) → W(X)
    - T2 → T1: W(X) → W(X)
    - T2 → T3: W(X) → W(X)
    - Cycle detected above between T1 and T2. Therefore not conflict serializable
- View Serializable?
    - For **X**: T1 does the initial read. T3 does the final write
    - We know T1 has to be first in the serial schedule as it performs a read before any changes (write operations) occur
    - Let's try T1;T2;T3
    - ```
        T1: R(X) W(X)
        T2:           W(X)
        T3:                W(X) 
       ```
    - This works as for the last three write operations, they are blind writes. If you want to know what blind writes are, check out notes.md
    <br><br>
    - Let's try T1;T3;T2
    - ```
        T1: R(X) W(X)
        T2:               W(X)
        T3:           W(X) 
       ```
    - This also works as the read in T1 has the same 'view' of the data item X as the concurrent schedule
    - Therefore the concurrent schedule is view equivalent to T1;T2;T3 and T1;T3;T2.
