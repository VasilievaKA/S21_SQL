-- Session #1
begin;
-- Session #1
set transaction isolation level read committed;
-- Session #2
begin;
-- Session #2
set transaction isolation level read committed;
-- Session #1
select * from pizzeria;
-- Session #2
update pizzeria set rating = 3.5 where name = 'Pizza Hut';
commit;
-- Session #1
select * from pizzeria;
commit;
select * from pizzeria;
-- Session #2
select * from pizzeria;