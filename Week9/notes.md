# Functional Dependencies & Closures

### Functional Dependencies
A relationship between attributes in a database, where one attribute determines the value of the other attribute.
<br>

We can denote a functional dependency as `X → Y`
- X determines Y
- Y is functionally dependent on X
<br>

For Functional Dependencies:
- 1:1 ✅
- n:1 ✅
- 1:n ❌
<br>

Inference Rules:
- **Reflexivity**
    ```
    X → X
    ```
- **Augmentation**
    ```
    X → Y ⟹ XZ → YZ
    ```
- **Transitivity**
    ```
    X → Y, Y → Z ⟹ X → Z
    ```
- **Additivity**
    ```
    X → Y, X → Z ⟹ X → YZ
    ```
- **Projectivity**
    ```
    X → YZ ⟹ X → Y, X → Z
    ```
- **Pseudotransitivity**
    ```
    X → Y, YZ → W ⟹ XZ → W
    ```

### Closures
The largest collection that can be derived from F is called the `closure` of F. We denote it as F+.

### Cover
A minimal set of functional dependencies.

**Steps for Computing the Minimal Cover:**
1. Put functional dependencies into `canonical form`.
    - this means RHS can only be a single attribute
    - E.g. if we have X → AB, we seperate it into X → A and X → B
2. Eliminate redundant attributes & redundant FDs
    - try making LHS a single attribute
    - E.g. if we have A → B and A → C and AB → C, get rid of the B in AB → C. This gives us duplicate FDs (A → C), which we can get rid of.
    <br><br>
    - get rid of cyclical/transitive FDs
    - E.g. if we have A → B and B → C and A → C, get rid of A → C
    <br><br>

# Normal Forms
Tells us how much redundancy we have in a schema.



**Some Notes about Keys**
- A `super key` is any combination of columns that uniquely identifies a row in a table.
- A `candidate key` is a super key which cannot have any columns removed from it without losing the unique identification property.
- A `primary key` is simply a candidate key chosen to be the main key. 
- A candidate key is always a super key but vice versa is not true.

### 3NF
For something to be in 3NF, all functional dependencies has to satisfy one of the following conditions:
- RHS is a single attribute part of candidate key
- LHS is a super key
- FD is trivial (X → X)
<br><br>

**To transform a schema into 3NF:**
1. Compute the `minimal cover` of the schema.
2. Each functional dependency in the minimal cover becomes a table, where the key of the table is the LHS of each FD.
3. If there is no table for candidate key (meaning the candidate key has to appear together in ONE SINGLE TABLE), then make a new table for it.

### BCNF
For something to be in BCNF, all FDs have to satisfy one of the following:
- LHS is a super key
- FD is trivial
<br><br>

**To transform a schema into BCNF:**
1. Scan through the FDs
2. Identify the dependencies which violates the BCNF definition. We consider that as X → A.
3. Decompose the schema R into {XA} and {R - A}
4. Check if both are in BCNF. If not, goto Step 3.\
(Sorta like a recursive algo)
