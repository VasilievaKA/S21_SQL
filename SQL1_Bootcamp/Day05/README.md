# Day 05 - Piscine SQL

## Scheme

1. **pizzeria** table (Dictionary Table with available pizzerias)
- field id - primary key
- field name - name of pizzeria
- field rating - average rating of pizzeria (from 0 to 5 points)
2. **person** table (Dictionary Table with persons who loves pizza)
- field id - primary key
- field name - name of person
- field age - age of person
- field gender - gender of person
- field address - address of person
3. **menu** table (Dictionary Table with available menu and price for concrete pizza)
- field id - primary key
- field pizzeria_id - foreign key to pizzeria
- field pizza_name - name of pizza in pizzeria
- field price - price of concrete pizza
4. **person_visits** table (Operational Table with information about visits of pizzeria)
- field id - primary key
- field person_id - foreign key to person
- field pizzeria_id - foreign key to pizzeria
- field visit_date - date (for example 2022-01-01) of person visit 
5. **person_order** table (Operational Table with information about persons orders)
- field id - primary key
- field person_id - foreign key to person
- field menu_id - foreign key to menu
- field order_date - date (for example 2022-01-01) of person order 

## Exercise 00 - Let’s create indexes for every foreign key

Please create a simple BTree index for every foreign key in our database. The name pattern should satisfy the next rule “idx_{table_name}_{column_name}”. For example, the name BTree index for the pizzeria_id column in the `menu` table is `idx_menu_pizzeria_id`.

## Exercise 01 - How to see that index works?

Before further steps please write a SQL statement that returns pizzas’ and corresponding pizzeria names. Please take a look at the sample result below (no sort needed).

| pizza_name | pizzeria_name | 
| ------ | ------ |
| cheese pizza | Pizza Hut |
| ... | ... |

Let’s provide proof that your indexes are working for your SQL.
The sample of proof is the output of the `EXPLAIN ANALYZE` command. 
Please take a look at the sample output command.
```    
    ...
    ->  Index Scan using idx_menu_pizzeria_id on menu m  (...)
    ...
```

## Exercise 02 - Formula is in the index. Is it Ok?

Please create a functional B-Tree index with name `idx_person_name` for the column name of the `person` table. Index should contain person names in upper case. 

## Exercise 03 - Multicolumn index for our goals

Please create a better multicolumn B-Tree index with the name `idx_person_order_multi` for the SQL statement below. The `EXPLAIN ANALYZE` command should return the next pattern. Please pay attention to "Index Only Scan" scanning!
`Index Only Scan using idx_person_order_multi on person_order ...` 

## Exercise 04 - Uniqueness for data

Please create a unique BTree index with the name `idx_menu_unique` on the `menu` table for  `pizzeria_id` and `pizza_name` columns. 

## Exercise 05 - Partial uniqueness for data

Please create a partial unique BTree index with the name `idx_person_order_order_date` on the `person_order` table for `person_id` and `menu_id` attributes with partial uniqueness for `order_date` column for date ‘2022-01-01’.
The `EXPLAIN ANALYZE` command should return  the next pattern `Index Only Scan using idx_person_order_order_date on person_order …`

## Exercise 06 - Let’s make performance improvement

Please take a look at SQL below from a technical perspective (ignore a logical case of that SQL statement). Create a new BTree index with name `idx_1` which should improve the “Execution Time” metric of this SQL.

Sample of my improvement:

**Before**:

    Sort  (cost=26.08..26.13 rows=19 width=53) (actual time=0.247..0.254 rows=19 loops=1)
    "  Sort Key: m.pizza_name, (max(pz.rating) OVER (?))"
    Sort Method: quicksort  Memory: 26kB
    ->  WindowAgg  (cost=25.30..25.68 rows=19 width=53) (actual time=0.110..0.182 rows=19 loops=1)
            ->  Sort  (cost=25.30..25.35 rows=19 width=21) (actual time=0.088..0.096 rows=19 loops=1)
                Sort Key: pz.rating
                Sort Method: quicksort  Memory: 26kB
                ->  Merge Join  (cost=0.27..24.90 rows=19 width=21) (actual time=0.026..0.060 rows=19 loops=1)
                        Merge Cond: (m.pizzeria_id = pz.id)
                        ->  Index Only Scan using idx_menu_unique on menu m  (cost=0.14..12.42 rows=19 width=22) (actual time=0.013..0.029 rows=19 loops=1)
                            Heap Fetches: 19
                        ->  Index Scan using pizzeria_pkey on pizzeria pz  (cost=0.13..12.22 rows=6 width=15) (actual time=0.005..0.008 rows=6 loops=1)
    Planning Time: 0.711 ms
    Execution Time: 0.338 ms

**After**:

    Sort  (cost=26.28..26.33 rows=19 width=53) (actual time=0.144..0.148 rows=19 loops=1)
    "  Sort Key: m.pizza_name, (max(pz.rating) OVER (?))"
    Sort Method: quicksort  Memory: 26kB
    ->  WindowAgg  (cost=0.27..25.88 rows=19 width=53) (actual time=0.049..0.107 rows=19 loops=1)
            ->  Nested Loop  (cost=0.27..25.54 rows=19 width=21) (actual time=0.022..0.058 rows=19 loops=1)
                ->  Index Scan using idx_1 on …
                ->  Index Only Scan using idx_menu_unique on menu m  (cost=0.14..2.19 rows=3 width=22) (actual time=0.004..0.005 rows=3 loops=6)
    …
    Planning Time: 0.338 ms
    Execution Time: 0.203 ms

