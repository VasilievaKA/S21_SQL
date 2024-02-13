insert into menu values ((select max(id) + 1 from menu),
                         (select id from pizzeria where name like 'Domi%'),
                         'sicilian pizza', 900);
select * from biancara.public.menu order by 1 desc limit 1;