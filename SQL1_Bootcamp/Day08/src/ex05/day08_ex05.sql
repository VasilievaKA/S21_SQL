-- Session #1
begin;
set transaction isolation level read committed;
-- Session #2
begin transaction isolation level read committed;
-- Session #1
select SUM(rating) from pizzeria;
-- Session #2
update pizzeria set rating = 1 where name like '% Hut';
commit;
-- Session #1
select SUM(rating) from pizzeria;
commit;
select SUM(rating) from pizzeria;
-- Session #2
select SUM(rating) from pizzeria;