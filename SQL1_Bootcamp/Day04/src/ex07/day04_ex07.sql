insert into person_visits values ((select id from person_visits order by 1 desc limit 1) + 1,
                                  (select id as person_id from person where name like 'Dmi%'), 3, '2022-01-08');
refresh materialized view mv_dmitriy_visits_and_eats;
select * from mv_dmitriy_visits_and_eats;