-- Session #1
begin transaction isolation level serializable;
-- Session #2
begin transaction isolation level serializable;
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