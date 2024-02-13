insert into person_order
select (res.idm + id) as id,
       id as person_id,
       idp as menu_id,
       '2022-02-25' as order_date from person, (select max(id) as idm from person_order) as res,
                                       (select id as idp from menu where pizza_name = 'greek pizza') as m;

select * from person_order