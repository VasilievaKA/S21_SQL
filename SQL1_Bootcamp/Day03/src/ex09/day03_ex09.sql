insert into person_visits values (
                            (select max(id) + 1 from person_visits),
                            (select id from person where name like 'Den%'),
                            (select id from pizzeria where name like 'Domi%'),
                            '2022-02-24');
insert into person_visits values (
                            (select max(id) + 1 from person_visits),
                            (select id from person where name like 'Ir%'),
                            (select id from pizzeria where name like 'Domi%'),
                            '2022-02-24');
select * from person_visits order by 1 desc limit 2;