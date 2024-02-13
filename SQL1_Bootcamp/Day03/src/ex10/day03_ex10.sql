insert into person_order values (
                            (select max(id) + 1 from person_order),
                            (select id from person where name like 'Den%'),
                            (select id from menu where pizza_name like 'sici%'),
                            '2022-02-24');
insert into person_order values (
                            (select max(id) + 1 from person_order),
                            (select id from person where name like 'Ir%'),
                            (select id from menu where pizza_name like 'sici%'),
                            '2022-02-24');
select * from person_order order by 1 desc limit 2;