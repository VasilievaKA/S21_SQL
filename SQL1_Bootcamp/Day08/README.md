# Day 08 - Piscine SQL

# Scheme

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

## Exercise 00 - Simple transaction

Please for this task use the command line for PostgreSQL database (psql). You need to check how your changes will be published in the database for other database users. Actually, we need two active sessions (meaning 2 parallel sessions in the command lines).    
Take a look at the steps below.

**Session #1**
- update of rating for “Pizza Hut” to 5 points in a transaction mode .
- check that you can see a changes in session #1

**Session #2**
- check that you can’t see a changes in session #2

**Session #1**
- publish your changes for all parallel sessions.

**Session #2**
- check that you can see a changes in session #2

## Exercise 01 - Lost Update Anomaly

Please for this task use the command line for PostgreSQL database (psql). You need to check how your changes will be published in the database for other database users. Actually, we need two active sessions (meaning 2 parallel sessions in the command lines). Before a task, make sure you are at a default isolation level in your database. Just run the next statement `SHOW TRANSACTION ISOLATION LEVEL;` and the result should be “read committed”;

Please check a rating for “Pizza Hut” in a transaction mode for both Sessions and after that make `UPDATE` of rating to 4 value in session #1 and make `UPDATE` of rating to 3.6 value in session #2 (in the same order as in the picture). 

## Exercise 02 - Lost Update for Repeatable Read

Please for this task use the command line for PostgreSQL database (psql). You need to check how your changes will be published in the database for other database users. 
Please check a rating for “Pizza Hut” in a transaction mode for both Sessions and after that make `UPDATE` of rating to 4 value in session #1 and make `UPDATE` of rating to 3.6 value in session #2 (in the same order as in the picture). 

## Exercise 03 - Non-Repeatable Reads Anomaly

Please for this task use the command line for PostgreSQL database (psql). You need to check how your changes will be published in the database for other database users. 
Please check a rating for “Pizza Hut” in a transaction mode for session #1 and after that make `UPDATE` of rating to 3.6 value in session #2 (in the same order as in the picture). 

## Exercise 04 - Non-Repeatable Reads for Serialization

Please for this task use the command line for PostgreSQL database (psql). You need to check how your changes will be published in the database for other database users. 
Please check a rating for “Pizza Hut” in a transaction mode for session #1 and after that make `UPDATE` of rating to 3.0 value in session #2 (in the same order as in the picture). 

## Exercise 05 - Phantom Reads Anomaly

Please for this task use the command line for PostgreSQL database (psql). You need to check how your changes will be published in the database for other database users. 
Please summarize all ratings for all pizzerias in a transaction mode for session #1 and after that make `UPDATE` of rating to 1 value for “Pizza Hut” restaurant in session #2 (in the same order as in the picture). 

## Exercise 06 - Phantom Reads for Repeatable Read

Please for this task use the command line for PostgreSQL database (psql). You need to check how your changes will be published in the database for other database users. 
Please summarize all ratings for all pizzerias in a transaction mode for session #1 and after that make `UPDATE` of rating to 5 value for “Pizza Hut” restaurant in session #2 (in the same order as in the picture). 

## Exercise 07 - Deadlock

Please for this task use the command line for PostgreSQL database (psql). You need to check how your changes will be published in the database for other database users. 
Please write any SQL statement with any isolation level (you can use default setting) on the `pizzeria` table to reproduce this deadlock situation.

